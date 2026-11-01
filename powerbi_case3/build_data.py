"""Build docs/case3/data.json for the web dashboard from the Case 3 Excel files.

Applies the same cleaning as the Power Query steps in README.md:
  - drop sales rows with junk keys (Business Line no. = "#", Product No = "'")
  - keep Sales Qty as a decimal (the source has fractional units)
  - List Price DKK "#" -> 0; Launch Date is dd.mm.yyyy text
  - map ISO week -> month with Calendar.xlsx (only used for the monthly view)

Usage:
  python powerbi_case3/build_data.py "<folder with the 5 Case 3 Excel files>"
"""
import json
import os
import sys

import pandas as pd

SRC = sys.argv[1]
OUT = os.path.join(os.path.dirname(__file__), "..", "docs", "case3", "data.json")


def read(name, sheet=0):
    return pd.read_excel(os.path.join(SRC, name), sheet_name=sheet, dtype=object)


sales = read("SalesOverview.xlsx")
products = read("Product.xlsx")
lines = read("BusinessLine.xlsx")
calendar = read("Calendar.xlsx", "Calendar")
rates = read("ExchangeRate.xlsx", "Exchange Rate")

raw_rows = len(sales)
sales["pn"] = pd.to_numeric(sales["Product No"], errors="coerce")
sales["bl"] = pd.to_numeric(sales["Business Line no."], errors="coerce")
bad = sales[sales["pn"].isna() | sales["bl"].isna()]
sales = sales.drop(bad.index)
sales["pn"] = sales["pn"].astype(int)
sales["bl"] = sales["bl"].astype(int)
sales["q"] = sales["Sales Qty"].astype(float)
sales["s"] = sales["Sales Amount DKK"].astype(float)
sales["yr"] = sales["Year Week Number"].str[-4:].astype(int)
sales["wk"] = sales["Year Week Number"].str[:2].astype(int)
sales = sales[(sales["q"] != 0) | (sales["s"] != 0)]

lines["no"] = lines["Business Line No"].astype(int)
bl_list = lines.sort_values("Business Line Name", key=lambda s: s.str[3:].astype(int))
bl_idx = {no: i for i, no in enumerate(bl_list["no"])}
countries = sorted(lines["Country"].unique())
country_of_bl = dict(zip(lines["no"], lines["Country"]))
sales["c"] = sales["bl"].map(lambda b: countries.index(country_of_bl[b]))

products["pn"] = products["Product No"].astype(int)
products["lp"] = pd.to_numeric(products["List Price DKK"], errors="coerce").fillna(0)
products["launch"] = products["Launch Date"].astype(str).str[-4:].astype(int)
subcats = sorted(products["SubCategory"].unique())
sub_of = dict(zip(products["pn"], products["SubCategory"]))
sales["sub"] = sales["pn"].map(lambda p: subcats.index(sub_of[p]) if p in sub_of else -1)


def pack(df, keys):
    g = df.groupby(keys, as_index=False).agg(s=("s", "sum"), q=("q", "sum"))
    return [[int(v) for v in r[:-2]] + [round(float(r[-2])), round(float(r[-1]), 1)]
            for r in g.itertuples(index=False)]


sales["w53"] = (sales["wk"] == 53).astype(int)
cal = calendar.astype(int)
cal = cal[cal["calendar_year"].between(2018, 2020)]

data = {
    "weekly": pack(sales, ["yr", "wk", "c", "sub"]),
    "lines": pack(sales, ["yr", "bl", "sub", "w53"]),
    "products": pack(sales, ["yr", "c", "pn", "w53"]),
    "countries": countries,
    "subcats": subcats,
    "business_lines": [{"no": int(r.no), "name": r._2, "country": r.Country}
                       for r in bl_list.itertuples(index=False)],
    "product_info": {int(r.pn): [r._1, r.SubCategory, int(r.launch), float(r.lp)]
                     for r in products.itertuples(index=False)},
    "week_month": {f"{r.calendar_year}-{r.iso_week}": int(r.iso_month)
                   for r in cal.itertuples(index=False)},
    "rates": {cur: {str(r.Year): float(r._3) for r in g.itertuples(index=False)}
              for cur, g in rates[rates["Currency"] != "FJD"].groupby("Currency")},
    "meta": {
        "raw_rows": raw_rows,
        "junk_key_rows": int(len(bad)),
        "zero_rows_dropped": int(raw_rows - len(bad) - len(sales)),
        "unknown_product_sales_dkk": round(float(sales.loc[sales["sub"] == -1, "s"].sum())),
    },
}
# "BGP" is a typo for GBP in the source
data["rates"]["GBP"] = data["rates"].pop("BGP")

os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, "w") as f:
    json.dump(data, f, separators=(",", ":"))
print(f"wrote {OUT}: weekly={len(data['weekly'])} lines={len(data['lines'])} "
      f"products={len(data['products'])} meta={data['meta']}")
