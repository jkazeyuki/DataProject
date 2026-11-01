# Power BI Case 2 — Nordic Flip-flop Sales Dashboard

**Live web version:** `https://jkazeyuki.github.io/DataProject/case2/` (see [Publish](#5-publish-the-link-for-your-resume))

Nordic Flip-flop is an e-commerce business selling clothes, food and alcohol in several markets.
Management wants to understand **sales performance across markets, top-selling products and sales
development**. Required: YTD / MTD / SPLY sales, Sales by Order Date vs Payment Date, Discount %
(actual vs list price), ASP, a storytelling dashboard, and an explanation of the method.

| File | What it is |
|---|---|
| [`power_query.m`](power_query.m) | All Power Query (M) queries: combine the market files, clean, extend the calendar |
| [`measures.dax`](measures.dax) | Every DAX measure + the relationships to create |
| [`case2_theme.json`](case2_theme.json) | Report theme (same palette as the web version) |
| [`build_data.py`](build_data.py) | Rebuilds `docs/case2/data.json` for the web dashboard from the Excel files |
| [`../docs/case2/index.html`](../docs/case2/index.html) | Interactive web dashboard (the resume link) |
| `Nordic_Flipflop.pbix` | *(you create this)* the Power BI report |
| `screenshots/` | *(you create this)* one PNG per report page |

The raw Excel files are course material and are **not** committed; keep them locally.

---

## 1. Data audit (what I found before modelling)

| Issue | Impact | Fix |
|---|---|---|
| City is not a column, only in the **file name** (`NY_Results.xlsx`) | Can't join to `DimGeo` | Power Query: `IDCity = Text.BeforeDelimiter([Name], "_")` |
| `Other/Sing_Sales.xlsx` is a byte-identical copy of `Facts/Sing_Sales.xlsx` | Singapore double-counted | Only load the `Facts` folder |
| `Lon_Sales.xlsx` has **366 fully blank rows** | Wrong row counts | Filter out null `Product ID` |
| Data ends **17 Dec 2017**; San Francisco ends 16 Nov 2017, Vancouver 14 Oct 2017 | Full-year 2017 looks −3.2% vs 2016 | Compare **like-for-like** (Jan–Sep) |
| London starts 23 Feb 2016, Vancouver 26 Apr 2016 | Their YoY growth is overstated | Flag with `*` |
| 143 orders are **paid in Jan–Feb 2018**, but `DimCalendar` stops at 31 Dec 2017 | 6.2M missing from Sales by Payment Date | Append 2018 dates to the calendar in Power Query |
| Copenhagen, Montreal, Hanoi exist in `DimGeo` but have **no sales** | Empty rows in visuals | Mention as "markets not yet live"; hide blanks |
| Singapore's average price is **3.4× list**, Rome/Paris **70–75% below** | Discount % is negative for 5 of 7 cities | Report as a finding; ask whether amounts are in one currency |

19,748 order lines after cleaning; total sales 1.03B (currency not specified in the source).

## 2. Model (star schema)

```
 DimProducts[Code] 1 ──* FactSales[Product ID]
 DimGeo[IDCity]    1 ──* FactSales[IDCity]
 DimCalendar[Dates] 1 ──* FactSales[Order Date]     (active)
 DimCalendar[Dates] 1 ┄┄* FactSales[Payment Date]   (inactive → USERELATIONSHIP)
 Indicator (disconnected — drives the dynamic measure slicer)
 _Measures (empty table holding all measures)
```

Steps in Power BI Desktop:
1. **Get data → Blank query → Advanced editor**, paste each query from `power_query.m`
   (create the `DataRoot` text parameter first, pointing to your `Data Sources\` folder). *Close & Apply.*
2. **Model view:** create the four relationships above (drag Payment Date onto Dates, then
   *Properties → Make this relationship active* = off).
3. **DimCalendar:** *Mark as date table*; sort `Month Name` by `Month Num` and `Month Yr` by `MonthYearNum`.
4. **DimGeo[Flag]:** *Column tools → Data category → Image URL* (flags show in tables).
5. **Measures:** *Enter data* → empty table `_Measures`; add every measure from `measures.dax`.
6. **Validate** against the web version: Total Sales = 1,027,561,123; 2016 = 522,117,146;
   2017 = 505,443,977; Sales by Payment Date 2018 = 6,228,157; ASP = 2,309; Discount % = 13.9%.

## 3. Report design (4 pages, 1280 × 720)

*View → Themes → Browse for themes →* `case2_theme.json`. Build page 2 first, then *Duplicate page* so
every page shares the same header, slicer bar and grid.

**Common frame on every page**
- Top-left title text box (24pt semibold) + one-line subtitle stating the page's conclusion.
- One slicer row under the header: Year, Continent, Product Category (Dropdown).
  *View → Sync slicers* so they apply to all pages.
- Right corner: a **Back/Home** button (*Insert → Buttons → Back* or *Navigator*).

**Page 1 — Home (navigation)**
- Title, 3–4 sentence summary (the "What the data says" headline).
- Buttons → *Page navigator* (Insert → Buttons → Navigator → Page navigator), or icon images with
  *Action → Page navigation* (the course icons in `Custom Visual and Icons/`).

**Page 2 — Sales overview** (the main dashboard)
- KPI cards: Total Sales, Total Units, ASP, Discount % — each with `Sales LFL YoY %` underneath
  (new Card visual → *Reference labels*).
- Line chart: `Total Sales` by `Month Name`, legend = `Year` (2017 blue, 2016 grey).
  Title: *"2017 sales track 2016 — Nov/Dec drop is missing data"*.
- Bar chart: `Total Sales` by `City`, data labels on. Title: *"Three cities make 71% of sales"*.
- **Bookmark toggle** in the bottom-right slot: two visuals in the same place —
  (a) `Total Sales` by `Product Name`, (b) `Sales LFL YoY %` by `City` (colour via *fx →
  Field value* = `[YoY Colour]`). *View → Bookmarks + Selection*: hide one, *Add bookmark*; swap; add
  bookmark. Two buttons with *Action → Bookmark*.
- **Report-page tooltip**: new page, *Page information → Allow use as tooltip*, *Canvas → Tooltip*;
  cards for ASP, Discount %, Units. On the city bar chart: *General → Tooltips → Report page*.

**Page 3 — Pricing & discount**
- Table: Product Name, List Price, ASP, Total Sales, Total Sales ListPrice, Discount %
  (conditional formatting: *Data bars* on Discount %).
- Bar chart: `Price vs List %` by City with a **constant line at 1** (*Analytics → Constant line*).
  Title: *"Europe discounts 70–75%; Singapore sells at 3.4× list"*.
- Matrix: City × Product Category, value = Discount %, background colour scale (diverging).

**Page 4 — Time intelligence**
- Matrix: rows = `Month Yr` (sorted), values = Total Sales, Sales MTD, Sales YTD, Sales SPLY,
  Sales YTD SPLY, Sales YoY %.
- Line chart: `Sales By Order Date` vs `Sales By Payment Date` by month (shows the 12-day lag and the
  Dec→Jan shift).
- Slicer on `Indicator[IndicatorName]` + column chart of `Dynamic Measure` by month, title from
  `[Dynamic Title]` (*Title → fx → Field value*).

**Polish checklist:** align with *Format → Align*, equal 12px gaps, titles state findings (not
"Sales by City"), max 3 font sizes, no 3-D/pie charts, a footnote with data source and the
like-for-like caveat, *File → Options → Report settings → Use modern visual header*.

## 4. Story (the insights to present)

1. **2017 is not down — the data is incomplete.** Reported 2017 is 505.4M vs 522.1M (−3.2%), but
   2017 ends mid-December and SF/Vancouver stop earlier. Like-for-like (Jan–Sep): **+8.6%**; the five
   markets with a full 2016 base: +3.7%.
2. **Concentration.** Singapore 32% of sales; Singapore + San Francisco + New York = 71%.
   Vancouver (+109%) and London (+38%) grow fastest, but from partial 2016 bases. **Paris (−14%)** is
   the only established market in decline.
3. **Two pricing models.** Rome and Paris ship 65% of units but bring 20% of sales — average price
   70–75% below list. Singapore sells at 3.4× list, SF 1.8×, NY 1.5×. Confirm currency before
   comparing markets.
4. **No hero product.** Each of the 8 products is 11–14% of sales; Alcohol leads (40%) because it has
   three SKUs. Whisky (list 4,000) has the deepest average discount (42%).
5. **Order vs payment.** Median payment lag 12 days. Dec 2016 is the peak month by order date
   (58.6M; Singapore 27.5M, 2.1× its normal month), and 6.2M of 2017 orders are paid in 2018.

**Recommendation:** report growth like-for-like; protect the three core cities; investigate Paris;
standardise currency and discount rules across markets; Copenhagen, Montreal and Hanoi are set up in
master data and are the natural next launches.

## 5. Publish the link for your resume

Power BI *Publish to web* needs a work/school account, so the public link is the **GitHub Pages**
web version, which recomputes the same measures in the browser.

1. Merge this branch into `main` (open a PR on GitHub and merge it).
2. Repo **Settings → Pages → Build and deployment → Deploy from a branch → `main` / `/docs`** → Save.
   (Free accounts need the repo to be **public** for Pages.)
3. After ~1 minute: `https://jkazeyuki.github.io/DataProject/case2/`
4. Add Power BI screenshots: save PNGs of each page to `powerbi_case2/screenshots/` and link them from
   this README so reviewers see the real report too. Commit the `.pbix` as well.

To refresh the web data after changing the cleaning rules:
`python powerbi_case2/build_data.py "<path>/Modelling and DAX/Data Sources"`

**Resume bullet (example):**
> **Nordic Flip-flop Sales Dashboard** (Power BI, Power Query, DAX) — [live link]
> Combined 7 market files into a star-schema model; built time-intelligence (YTD/MTD/SPLY),
> role-playing date (order vs payment) and discount/ASP measures; found that a reported −3.2% decline
> was a data-coverage artefact (like-for-like +8.6%) and that 3 cities drive 71% of sales.
