"""Build docs/case2/data.json for the web dashboard from the Case 2 Excel files.

Applies the same cleaning as the Power Query steps in power_query.m:
  - combine every file in Data Sources/Facts (Other/ holds a duplicate of Sing_Sales and is skipped)
  - IDCity = file-name prefix before "_" (e.g. "NY_Results.xlsx" -> "NY")
  - drop fully blank rows (Lon_Sales has 366)
  - join Products for List Price / Category, Geo for City / Country / Continent

Usage:
  python powerbi_case2/build_data.py "<path to 'Modelling and DAX/Data Sources'>"
"""
import glob
import json
import os
import sys

import pandas as pd

SRC = sys.argv[1]
OUT = os.path.join(os.path.dirname(__file__), "..", "docs", "case2", "data.json")

dim = pd.read_excel(os.path.join(SRC, "Dim", "Dim.xlsx"), sheet_name=None)
products = dim["Products"]
geo = dim["Geo"]

frames = []
for path in sorted(glob.glob(os.path.join(SRC, "Facts", "*.xlsx"))):
    df = pd.read_excel(path).dropna(how="all")
    df["IDCity"] = os.path.basename(path).split("_")[0]
    frames.append(df)
fact = pd.concat(frames, ignore_index=True)
fact["List Amount"] = fact["Quantity"] * fact["Product ID"].map(
    products.set_index("Code")["List Price"])


def agg(date_col):
    d = fact[date_col]
    g = (fact.assign(y=d.dt.year, m=d.dt.month)
         .groupby(["y", "m", "IDCity", "Product ID"], as_index=False)
         .agg(s=("Sales Amount", "sum"), q=("Quantity", "sum"), l=("List Amount", "sum")))
    return [[int(r.y), int(r.m), r.IDCity, r._3, round(float(r.s)), int(r.q), round(float(r.l))]
            for r in g.itertuples(index=False)]


coverage = fact.groupby("IDCity")["Order Date"].agg(["min", "max"])
cities = []
for r in geo.itertuples(index=False):
    has = r.IDCity in coverage.index
    cities.append({
        "id": r.IDCity, "city": r.City, "country": r.Country, "continent": r.Continent,
        "first": coverage.loc[r.IDCity, "min"].strftime("%Y-%m-%d") if has else None,
        "last": coverage.loc[r.IDCity, "max"].strftime("%Y-%m-%d") if has else None,
    })

data = {
    "fields": ["year", "month", "city", "product", "sales", "units", "list_amount"],
    "by_order_date": agg("Order Date"),
    "by_payment_date": agg("Payment Date"),
    "products": [{"id": r.Code, "name": r._1, "category": r._2, "list_price": int(r._3)}
                 for r in products.itertuples(index=False)],
    "cities": cities,
    "meta": {
        "orders": int(len(fact)),
        "blank_rows_removed": int(sum(len(pd.read_excel(p)) for p in
                                      glob.glob(os.path.join(SRC, "Facts", "*.xlsx"))) - len(fact)),
        "first_order": fact["Order Date"].min().strftime("%Y-%m-%d"),
        "last_order": fact["Order Date"].max().strftime("%Y-%m-%d"),
        "median_payment_lag_days": float((fact["Payment Date"] - fact["Order Date"]).dt.days.median()),
    },
}

os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, "w") as f:
    json.dump(data, f, separators=(",", ":"))
print(f"wrote {OUT}: {len(data['by_order_date'])} order rows, meta={data['meta']}")
