import logging
import os
from contextlib import closing
from datetime import date, datetime
from decimal import Decimal

import psycopg2
from psycopg2.extras import RealDictCursor
from fastapi import HTTPException
from fastapi.responses import JSONResponse


def exact(value):
    if isinstance(value, Decimal):
        return str(value)
    if isinstance(value, (date, datetime)):
        return value.isoformat()
    if isinstance(value, dict):
        return {k: exact(v) for k, v in value.items()}
    if isinstance(value, list):
        return [exact(v) for v in value]
    return value


def read(query, params=()):

    try:
        with closing(
            psycopg2.connect(
                host="127.0.0.1",
                port=5433,
                dbname="marketplace",
                user="capibara_dashboard",
                password=os.environ["API_DB_PASSWORD"],
                connect_timeout=3,
            )
        ) as conn:
            conn.set_session(readonly=True)
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute("SET LOCAL statement_timeout='15s'")
                cur.execute("SET LOCAL lock_timeout='2s'")
                cur.execute(query, params)
                data = [dict(r) for r in cur.fetchall()]
            conn.rollback()
        return JSONResponse(
            {
                "data": exact(data),
                "meta": {
                    "currency": "BRL",
                    "decimal_encoding": "string",
                    "sales_status": "delivered",
                    "rating_status": "all",
                    "rating_label": "Оценка однопродавцовых заказов",
                },
            }
        )
    except (psycopg2.Error, KeyError):
        logging.exception("Dashboard database read failed")
        raise HTTPException(
            status_code=503, detail="Database temporarily unavailable"
        ) from None
