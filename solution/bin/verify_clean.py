#!/usr/bin/env python3

from pathlib import Path
import subprocess
import uuid

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "results/v2"
OUT.mkdir(parents=True, exist_ok=True)
name = "capibara_verify_" + uuid.uuid4().hex[:12]


def pg(*args, input=None):
    return subprocess.run(
        ["docker", "compose", "exec", "-T", "postgres", *args],
        cwd=ROOT,
        input=input,
        text=True,
        capture_output=True,
        check=True,
    ).stdout


pg("createdb", "-U", "hack", name)
try:
    dump = pg(
        "pg_dump",
        "-U",
        "hack",
        "-d",
        "marketplace",
        "-n",
        "raw",
        "--no-owner",
        "--no-privileges",
    )
    pg(
        "psql",
        "-X",
        "-q",
        "-v",
        "ON_ERROR_STOP=1",
        "-U",
        "hack",
        "-d",
        name,
        input=dump,
    )
    files = sorted((ROOT / "model").glob("*.sql")) + [
        ROOT / "model/verify/01_checks.sql"
    ]
    script = "BEGIN;\n" + "\n".join(f.read_text() for f in files) + "\nCOMMIT;\n"
    result = pg(
        "psql",
        "-X",
        "-q",
        "--csv",
        "-v",
        "ON_ERROR_STOP=1",
        "-U",
        "hack",
        "-d",
        name,
        input=script,
    )
    (OUT / "clean-build-checks.csv").write_text(result)
    for query in sorted((ROOT / "queries").glob("*.sql")):
        result = pg(
            "psql",
            "-X",
            "-q",
            "--csv",
            "-v",
            "ON_ERROR_STOP=1",
            "-U",
            "hack",
            "-d",
            name,
            input=query.read_text(),
        )
        assert (
            result == (ROOT / "results/answers" / f"{query.stem}.csv").read_text()
        ), query.name
    result = pg(
        "psql",
        "-X",
        "-v",
        "ON_ERROR_STOP=1",
        "-U",
        "hack",
        "-d",
        name,
        input=(ROOT / "model/verify/02_rating_fixture.sql").read_text(),
    )
    (OUT / "clean-rating-fixture.log").write_text(result)
    (OUT / "clean-build-result.txt").write_text(
        "PASS: empty core build, all five answers identical, rating fixture passed. Disposable database removed.\n"
    )
    print("Clean build and five answers passed")
finally:
    pg("dropdb", "-U", "hack", name)
