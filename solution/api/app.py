import os
from pathlib import Path

from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware

from api.database import read

app = FastAPI(title="Capibara dashboard API", version="1.0.0")
origins = os.getenv(
    "API_CORS_ORIGINS",
    "http://localhost:5173,http://127.0.0.1:5173,http://localhost:3000,http://127.0.0.1:3000",
).split(",")
app.add_middleware(
    CORSMiddleware, allow_origins=origins, allow_methods=["GET"], allow_headers=["*"]
)


@app.get("/api/overview")
def overview():
    return read("SELECT * FROM mart.overview")


@app.get("/api/sales/monthly")
def monthly():
    return read("SELECT * FROM mart.monthly_sales ORDER BY month")


@app.get("/api/sellers")
def sellers(
    limit: int = Query(10, ge=1, le=100), offset: int = Query(0, ge=0, le=10000)
):
    return read(
        (Path(__file__).parent / "seller_query.sql").read_text(), (limit, offset)
    )


@app.get("/api/categories")
def categories():
    return read("SELECT * FROM mart.category_sales ORDER BY revenue DESC,category_name")


@app.get("/api/customers/repeat")
def repeat():
    return read("SELECT * FROM mart.customer_repeat")
