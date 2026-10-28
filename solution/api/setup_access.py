import secrets
from pathlib import Path
from contextlib import closing
import psycopg2
from psycopg2 import sql

ROOT = Path(__file__).resolve().parent
path = ROOT / ".env"
if path.exists():
    config = dict(
        line.split("=", 1) for line in path.read_text().splitlines() if "=" in line
    )
    password = config["API_DB_PASSWORD"]
else:
    password = secrets.token_urlsafe(32)
with closing(
    psycopg2.connect(
        host="127.0.0.1", port=5433, dbname="marketplace", user="hack", password="hack"
    )
) as conn:
    with conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1 FROM pg_roles WHERE rolname='capibara_dashboard'")
            if not cur.fetchone():
                cur.execute(
                    "CREATE ROLE capibara_dashboard LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT"
                )
            cur.execute(
                sql.SQL("ALTER ROLE capibara_dashboard PASSWORD {}").format(
                    sql.Literal(password)
                )
            )
            cur.execute(
                "ALTER ROLE capibara_dashboard SET default_transaction_read_only=on"
            )
            cur.execute("ALTER ROLE capibara_dashboard SET statement_timeout='15s'")
            cur.execute("GRANT CONNECT ON DATABASE marketplace TO capibara_dashboard")
            cur.execute("GRANT USAGE ON SCHEMA mart TO capibara_dashboard")
            for view in [
                "overview",
                "monthly_sales",
                "seller_sales",
                "seller_rating",
                "category_sales",
                "customer_repeat",
            ]:
                cur.execute(
                    sql.SQL("GRANT SELECT ON mart.{} TO capibara_dashboard").format(
                        sql.Identifier(view)
                    )
                )
if not path.exists():
    path.touch(mode=0o600)
    path.write_text("API_DB_PASSWORD=" + password + "\n")
path.chmod(0o600)
print(
    "Dashboard login ready on solution:5433. Secret stored in api/.env (not printed)."
)
