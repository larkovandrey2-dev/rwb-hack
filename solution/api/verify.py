import json
import os
import time
import urllib.request
import urllib.error
from contextlib import closing
from pathlib import Path
import psycopg2
from psycopg2.extras import RealDictCursor
from api.database import exact

ROOT = Path(__file__).resolve().parent.parent
(ROOT / "results/v2").mkdir(parents=True, exist_ok=True)
password = dict(
    line.split("=", 1) for line in (ROOT / "api/.env").read_text().splitlines()
)["API_DB_PASSWORD"]
base = os.getenv("API_BASE_URL", "http://127.0.0.1:8004")
queries = {
    "/api/overview": "SELECT * FROM mart.overview",
    "/api/sales/monthly": "SELECT * FROM mart.monthly_sales ORDER BY month",
    "/api/sellers": (ROOT / "api/seller_query.sql")
    .read_text()
    .replace("%s", "10", 1)
    .replace("%s", "0", 1),
    "/api/categories": "SELECT * FROM mart.category_sales ORDER BY revenue DESC,category_name",
    "/api/customers/repeat": "SELECT * FROM mart.customer_repeat",
}
report = {}
with closing(
    psycopg2.connect(
        host="127.0.0.1", port=5433, dbname="marketplace", user="hack", password="hack"
    )
) as conn:
    conn.set_session(readonly=True)
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        for path, query in queries.items():
            started = time.monotonic()
            with urllib.request.urlopen(base + path, timeout=20) as response:
                payload = json.load(response)
            cur.execute(query)
            expected = exact([dict(r) for r in cur.fetchall()])
            assert payload["data"] == expected, path
            if path == "/api/overview":
                assert payload["data"][0]["revenue"] == "13221498.11"
                assert isinstance(payload["data"][0]["revenue"], str)
                assert payload["data"][0]["delivered_orders"] == 96478
            if path == "/api/sales/monthly":
                assert len(payload["data"]) == 24
                assert all(isinstance(row["revenue"], str) for row in payload["data"])
            report[path] = {
                "status": 200,
                "rows": len(expected),
                "matches_mart": True,
                "seconds": round(time.monotonic() - started, 3),
            }
            (
                ROOT / "results/v2" / ("api-" + path.rsplit("/", 1)[-1] + ".json")
            ).write_text(json.dumps(payload, ensure_ascii=False, indent=2))
    conn.rollback()
for path, method, expected_status in [
    ("/api/sellers?limit=101", "GET", 422),
    ("/api/sellers?offset=-1", "GET", 422),
    ("/api/sql", "GET", 404),
    ("/api/overview", "POST", 405),
]:
    try:
        urllib.request.urlopen(
            urllib.request.Request(base + path, method=method), timeout=20
        )
    except urllib.error.HTTPError as exc:
        assert exc.code == expected_status, (path, exc.code)
        report[path + ":" + method] = {"status": exc.code, "expected": True}
    else:
        raise AssertionError(path)
req = urllib.request.Request(
    base + "/api/overview", headers={"Origin": "http://localhost:5173"}
)
with urllib.request.urlopen(req, timeout=20) as r:
    assert r.headers["Access-Control-Allow-Origin"] == "http://localhost:5173"
    report["cors_dev_origin"] = True
with closing(
    psycopg2.connect(
        host="127.0.0.1",
        port=5433,
        dbname="marketplace",
        user="capibara_dashboard",
        password=password,
    )
) as conn:
    for name, query in [
        ("raw_denied", "SELECT count(*) FROM raw.orders"),
        ("core_write_denied", "DELETE FROM core.orders WHERE false"),
    ]:
        try:
            with conn.cursor() as cur:
                cur.execute(query)
        except psycopg2.Error as exc:
            assert exc.pgcode in {"42501", "25006"}, exc.pgcode
            conn.rollback()
            report[name] = True
        else:
            raise AssertionError(name)
(ROOT / "results/v2/api-checks.json").write_text(json.dumps(report, indent=2))
print(json.dumps(report, indent=2))
