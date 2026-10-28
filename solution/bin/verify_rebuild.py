#!/usr/bin/env python3

import csv
import io
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "results/core-build"
OUT.mkdir(exist_ok=True)


def sql(query):
    r = subprocess.run(
        [
            "docker",
            "compose",
            "exec",
            "-T",
            "postgres",
            "psql",
            "-X",
            "-q",
            "--csv",
            "-v",
            "ON_ERROR_STOP=1",
            "-U",
            "hack",
            "-d",
            "marketplace",
        ],
        input=query,
        text=True,
        capture_output=True,
        cwd=ROOT,
        check=True,
    )
    return r.stdout


relations = list(
    csv.DictReader(
        io.StringIO(
            sql(
                "SELECT table_schema,table_name FROM information_schema.tables WHERE table_schema IN ('raw','core','mart') ORDER BY 1,2;"
            )
        )
    )
)


def snapshot():
    queries = []
    for r in relations:
        relation = r["table_schema"] + "." + r["table_name"]
        queries.append(
            f"SELECT '{relation}' AS relation,count(*) AS rows,md5(string_agg(h,'' ORDER BY h)) AS fingerprint FROM (SELECT md5(to_jsonb(t)::text) h FROM {relation} t) x"
        )
    return sql("\nUNION ALL\n".join(queries) + " ORDER BY relation;")


before = snapshot()
(OUT / "before-rebuild.csv").write_text(before)
r = subprocess.run(["bash", "bin/build.sh"], cwd=ROOT, text=True, capture_output=True)
(OUT / "second-build.log").write_text(r.stdout + r.stderr)
r.check_returncode()
after = snapshot()
(OUT / "after-rebuild.csv").write_text(after)
assert before == after, "Rebuild changed relation contents"
(OUT / "repeat-check.json").write_text(
    json.dumps(
        {
            "identical": True,
            "relations": len(relations),
            "method": "row counts + sorted per-row MD5; MD5 is a regression fingerprint, not a cryptographic proof",
        },
        indent=2,
    )
)
(OUT / "checks.csv").write_text(
    sql("BEGIN;\n" + (ROOT / "model/verify/01_checks.sql").read_text() + "\nROLLBACK;")
)
(OUT / "monthly.csv").write_text(sql((ROOT / "queries/01_monthly.sql").read_text()))
print(after)
print("Repeat build identical; evidence in results/core-build/")
