# Power BI Case 3 — YourFashion Jewelry Sales Report

**Live web version:** `https://jkazeyuki.github.io/DataProject/case3/` (see [Publish](#11-publish-the-link-for-your-resume))

How to rebuild `PowerBI_Case_3_Final_solution - Sales Analysis.pbix` from the raw Excel files.
I wrote this guide by taking the solution file apart: every query, DAX formula, relationship and
visual setting below comes from the solution itself. I also flag a few places where the solution has a bug
or a shortcut you should do better.

**What you're building:** a 6-page sales report for the jewelry brand "YourFashion": cover,
overview, time intelligence, sales details, product tooltip and contact. It covers weekly sales
from 2018 to 2020 across 29 business lines in 6 countries, with every amount switchable into 7 currencies.

| File | What it is |
|---|---|
| `README.md` (this file) | 3-day plan, explanation, step-by-step build, insights, publishing |
| [`BUILD_IT_YOURSELF.md`](BUILD_IT_YOURSELF.md) | Workbook version: goals, hidden hints and checks, so you build the case on your own |
| [`DAY_BY_DAY.md`](DAY_BY_DAY.md) | Click-by-click walkthrough for each day, with checkpoints and troubleshooting |
| [`MATCH_THE_SOLUTION.md`](MATCH_THE_SOLUTION.md) | Exact positions, colours and fonts to make the report look like the solution, with reference pictures in [`design/`](design/) and an importable theme |
| [`build_data.py`](build_data.py) | Rebuilds `docs/case3/data.json` for the web version from the 5 Excel files |
| [`../docs/case3/index.html`](../docs/case3/index.html) | Interactive web dashboard (the resume link) |
| `YourFashion_Sales.pbix` | *(you create this)* the Power BI report |
| `screenshots/` | *(you create this)* one PNG per report page |

The raw Excel files are course material and are **not** committed. Keep them locally.

---

## The 3-day plan

About 4–5 focused hours per day. Each day ends with something committed to GitHub.
**Click-by-click instructions for every step: [`DAY_BY_DAY.md`](DAY_BY_DAY.md).**

### Day 1: Understand the data and build the model
| Time | Task | Section |
|---|---|---|
| 30 min | Read **"Understand the case"** below. Open each Excel file and find the columns it mentions | [Understand](#understand-the-case-in-10-minutes) |
| 15 min | Power BI Desktop: turn off Auto date/time, create the `FolderPath` parameter | §0–1 |
| 1.5 h | Power Query: load and clean all 5 files (paste the M code, then *read* every step and be able to explain it) | §2 |
| 45 min | Calculated columns and calculated tables (`DimDate`, `DimCurrency`), mark the date table | §3–4 |
| 30 min | Six relationships; compare the Model view with the diagram | §5 |
| 15 min | Save as `powerbi_case3/YourFashion_Sales.pbix`, commit | |

**Done when:** a table visual with `DimDate[Year]` and `SUM(Sales Amount DKK)` shows 2,487,740,053 / 2,482,279,917 / 2,714,641,749.

### Day 2: Measures and report pages
| Time | Task | Section |
|---|---|---|
| 1 h | All DAX measures. Build `TotalSales` first, test it on a card with the Year and Currency slicers | §6 |
| 30 min | Theme, sidebar, slicers, *Sync slicers* | §7.1–7.2 |
| 1 h | OVERVIEW page | §7.4 |
| 1 h | TIME INTEL page with the country bookmarks | §7.5 |
| 1 h | SALES DETAILS page, product tooltip page, cover, contact | §7.3, 7.6–7.8 |

**Done when:** every number in [§8 Check your numbers](#8-check-your-numbers) matches.

### Day 3: Insights, polish and publish
| Time | Task | Section |
|---|---|---|
| 1 h | Read **What the data says**. Find each finding in your own report, and add an insights text box to OVERVIEW | §10 |
| 1 h | Polish: findings as titles, alignment, consistent fonts, hide helper pages | §7 |
| 30 min | Screenshots of each page into `powerbi_case3/screenshots/`, plus a 30-second GIF of the currency slicer | §11 |
| 30 min | Merge to `main`, turn on GitHub Pages, check the live link on your phone | §11 |
| 30 min | Add the resume bullet and practise the 2-minute walkthrough out loud | §11–12 |

---

## Understand the case in 10 minutes

**The business.** YourFashion sells jewelry (charms, bracelets, dangles, necklaces) through
**business lines**: shops or sales channels, 29 of them in 6 countries. Head office is in
Denmark, so every sale is recorded in **Danish kroner (DKK)**. Management in each country wants
to see the numbers in **their own currency**, and wants to know how sales are developing over time.

**The data, one sentence per file:**
- **`SalesOverview.xlsx`**: one row per *week × business line × product* with units and DKK amount.
  This is the **fact table**: things that happened, which you add up.
- **`Product.xlsx`**: what each product number is (subcategory, launch date, list price).
  This is a **dimension**: descriptions you filter and group by.
- **`BusinessLine.xlsx`**: which country each business line is in. Also a dimension.
- **`Calendar.xlsx`**: which month each ISO week belongs to. Sales only have a week number
  (`13.2020`), and this file turns it into a month so you can build monthly charts.
- **`ExchangeRate.xlsx`**: how many DKK 100 units of each currency cost, per year.

**The three ideas the case tests:**
1. **Star schema.** One fact table in the middle, dimensions around it, each linked by a key
   (product number, business line number, week). Filters flow from dimensions to the fact:
   pick "China" in `DimBusinessLine` and only China's sales rows are added up.
2. **Currency conversion in DAX.** No currency column exists in the sales data. The `TotalSales`
   measure computes it on the fly: *find the selected currency, find the year, look up that year's
   rate, divide*. 100 EUR = 745 DKK, so 1,000 DKK = 1,000 ÷ 7.45 = 134 EUR. The same sales show
   different growth in different currencies (+9.4% in DKK, +8.4% in SEK, +11.6% in USD), because the
   exchange rates changed between years.
3. **Time intelligence.** "Same period last year", "year to date" and "growth %" are measures that
   shift the date filter (`DATEADD`, `DATESYTD`). They only work with a proper date table
   (`DimDate`) that is **marked as a date table**.

**Words you'll be asked about:**

| Term | Meaning here |
|---|---|
| ASP | Average selling price = sales ÷ units |
| YoY % / MoM % | Growth vs same month last year / vs previous month |
| YTD | Year to date: total from 1 January up to the current month |
| ISO week | Weeks run Monday–Sunday. Week 1 is the week with the year's first Thursday, so some years have **53** weeks (2020 does) |
| 4-4-5 calendar | Each quarter = a 4-week, 4-week and 5-week "month". That's how `Calendar.xlsx` maps weeks to months |

---

## 0. Before you start

**Tools:** Power BI Desktop (Windows). The web version can't do Power Query on local Excel files
or calculated tables well, so on a Mac use a Windows VM.

**Source files** (from the case materials, all in one folder):

| File | Sheet | Becomes |
|---|---|---|
| `SalesOverview.xlsx` | Sheet1 | `FactSalesOverview`: weekly qty and sales (DKK) per business line × product. ~540k rows |
| `Product.xlsx` | Sheet1 | `DimProduct`: 287 products, category / subcategory / launch date / list price |
| `BusinessLine.xlsx` | Sheet1 | `DimBusinessLine`: 29 business lines → country |
| `Calendar.xlsx` | Calendar | `DimCalendar_x`: maps ISO week → month |
| `ExchangeRate.xlsx` | Exchange Rate | `FactExchangeRates`: yearly DKK rate per currency |

**First setting.** Go to *File → Options and settings → Options → Current file → Data load* and **untick
"Auto date/time"**. The solution left it on, which is why it contains hidden `LocalDateTable_…`
tables. You'll build a proper date table instead.

---

## 1. Folder parameter (5 min)

Making the folder path a parameter means the report works on any computer: you change one value
instead of editing five queries.

1. *Home → Transform data* to open Power Query.
2. *Manage Parameters → New Parameter*: Name `FolderPath`, Type **Text**, Current Value = the folder
   containing the 5 Excel files, e.g. `C:\Users\you\Documents\Case3` (no trailing `\`).

---

## 2. Power Query: load and clean (45 min)

For each file: *New Source → Excel workbook → pick the file → tick the sheet → Transform Data*.
Then open *Advanced Editor* and replace the hard-coded path with `FolderPath & "\File.xlsx"`.
The finished M code for each query is below, so you can paste it into the Advanced Editor.

### 2.1 `DimBusinessLine`
```m
let
    Source = Excel.Workbook(File.Contents(FolderPath & "\BusinessLine.xlsx"), null, true),
    Sheet1_Sheet = Source{[Item="Sheet1",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Sheet1_Sheet, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Country", type text}, {"Business Line No", Int64.Type}, {"Business Line Name", type text}})
in
    #"Changed Type"
```

### 2.2 `DimProduct`
```m
let
    Source = Excel.Workbook(File.Contents(FolderPath & "\Product.xlsx"), null, true),
    Sheet1_Sheet = Source{[Item="Sheet1",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Sheet1_Sheet, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Product No", Int64.Type}, {"Product Name", type text}, {"Category", type text}, {"SubCategory", type text}}),
    #"Parsed Launch Date" = Table.TransformColumns(#"Changed Type", {{"Launch Date", each Date.FromText(_, [Format="dd.MM.yyyy"]), type date}}),
    #"Replaced Hash" = Table.ReplaceValue(#"Parsed Launch Date", "#", 0, Replacer.ReplaceValue, {"List Price DKK"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Replaced Hash",{{"List Price DKK", type number}})
in
    #"Changed Type1"
```
> ⚠️ **Two locale traps** (the solution's author works on a Danish PC):
> - **Launch Date** is text like `01.06.2020`, meaning 1 June. A plain *type date* on an English PC reads it
>   as **6 January** or fails. `Date.FromText` with an explicit `dd.MM.yyyy` format reads it correctly everywhere.
> - **List Price DKK** holds numbers plus 10 cells containing `#`. The solution converts the column to text
>   and swaps `.` for `,`, which only works on a Danish PC; on yours it turns 67.5 into 675.
>   Replacing the `#` *value* with 0 and then setting *type number* never goes through text.

### 2.3 `DimCalendar_x`
```m
let
    Source = Excel.Workbook(File.Contents(FolderPath & "\Calendar.xlsx"), null, true),
    Calendar_Sheet = Source{[Item="Calendar",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Calendar_Sheet, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"calendar_year", type text}, {"iso_week", type text}, {"iso_month", type text}})
in
    #"Changed Type"
```
Keep year / week / month as **text**, because you'll glue them together into keys in step 3.

### 2.4 `FactExchangeRates`
```m
let
    Source = Excel.Workbook(File.Contents(FolderPath & "\ExchangeRate.xlsx"), null, true),
    #"Exchange Rate_Sheet" = Source{[Item="Exchange Rate",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(#"Exchange Rate_Sheet", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Currency Name", type text}, {"Currency", type text}, {"Year", type text}, {"Exchange Rate", type number}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type", each [Currency] <> "FJD")
in
    #"Filtered Rows"
```
**How to read the rates:** a rate is **DKK per 100 units** of the foreign currency, e.g. EUR 2020 = 745.42.
So 1 EUR = 7.4542 DKK, and that's why the measures later divide the rate by 100. FJD is
dropped because it isn't used. GBP is spelled `BGP` in the source. You can fix it with *Replace values*
if you like; nothing depends on the code.

### 2.5 `FactSalesOverview`
```m
let
    Source = Excel.Workbook(File.Contents(FolderPath & "\SalesOverview.xlsx"), null, true),
    Sheet1_Sheet = Source{[Item="Sheet1",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Sheet1_Sheet, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Year Week Number", type text}, {"Business Line no.", type text}, {"Product No", type text}, {"Sales Qty", type number}, {"Sales Amount DKK", type number}}),
    #"Removed Bad Keys" = Table.SelectRows(#"Changed Type", each
        [Product No] <> null and [Product No] <> "#N/A" and [Product No] <> "'"
        and [#"Business Line no."] <> "#"),
    #"Removed Empty Rows" = Table.SelectRows(#"Removed Bad Keys", each [Sales Qty] <> 0 or [Sales Amount DKK] <> 0),
    #"Key Types" = Table.TransformColumnTypes(#"Removed Empty Rows",{{"Product No", Int64.Type}, {"Business Line no.", Int64.Type}})
in
    #"Key Types"
```
> ⚠️ **Dirty keys.** The data has about 5,500 rows whose key is junk: `Product No` = `'` (254 rows) and
> `Business Line no.` = `#` (5,226 rows). The solution tried to remove them but filtered `"''"`
> (two apostrophes), which matches nothing, so the junk rows stayed in. They only hold about 234k DKK
> out of 7.7bn, but in an interview "I found and removed 5.5k rows with invalid keys" is a good line.
> Converting the keys to **whole numbers** gives them the same type as the dimension keys, which
> relationships need.
>
> **Units are decimals.** `Sales Qty` contains values like 6.14, probably because the course data was
> anonymised by scaling. Power BI auto-detects the column as *Whole number* and silently rounds every row.
> Set it to **Decimal number** (`type number`).
>
> **Empty rows.** 229,537 rows (42%) have 0 units *and* 0 sales: every product is listed for every week,
> sold or not. Removing them makes the model smaller and changes no total.
>
> `Year Week Number` looks like `13.2020` (zero-padded week + `.` + year). Keep it as **text**.

*Close & Apply.*

---

## 3. Calculated columns (15 min)

Use *Table view → select the table → New column*.

**`DimCalendar_x`**
```dax
Year Week = RIGHT("0" & DimCalendar_x[iso_week], 2) & "." & DimCalendar_x[calendar_year]
```
This produces `09.2020` and so on, matching the fact table's `Year Week Number` exactly. The leading zero matters.
```dax
Dates = DATE(VALUE(DimCalendar_x[calendar_year]), VALUE(DimCalendar_x[iso_month]), 1)
```
This gives the first day of the week's ISO month. The solution builds it as text and lets Power BI cast it.
`DATE()` gives you a real date directly. Set the column's data type to **Date**.

**`FactSalesOverview`** (create these *after* the relationships in step 5)
```dax
CalendarDates = RELATED(DimCalendar_x[Dates])
List Price   = RELATED(DimProduct[List Price DKK])
```
The sales data is weekly. `CalendarDates` gives every row a real date (the 1st of its month), so it can
link to the date table. As a result, the report's finest time grain is **month**.

**`FactExchangeRates`**
```dax
CalendarDate = DATE(VALUE(FactExchangeRates[Year]), 1, 1)
```

**`DimProduct`**
```dax
Launch Year = FORMAT(DimProduct[Launch Date], "YYYY")
```
The solution uses `LEFT(DimProduct[Launch Date].[Year],4)`, which only works while Auto date/time is on.

---

## 4. Calculated tables (10 min)

*Modeling → New table.*

**`DimDate`**, the main date table:
```dax
DimDate =
VAR _fromYear = 2015
VAR _toYear = 2020
VAR _startOfFiscalYear = 7
VAR _today = TODAY()
RETURN
ADDCOLUMNS (
    CALENDAR ( DATE ( _fromYear, 1, 1 ), DATE ( _toYear, 12, 31 ) ),
    "Year", FORMAT ( [Date], "YYYY" ),
    "Start of Year", DATE ( YEAR ( [Date] ), 1, 1 ),
    "End of Year", DATE ( YEAR ( [Date] ), 12, 31 ),
    "Month", MONTH ( [Date] ),
    "Start of Month", DATE ( YEAR ( [Date] ), MONTH ( [Date] ), 1 ),
    "End of Month", EOMONTH ( [Date], 0 ),
    "Days in Month", DATEDIFF ( DATE ( YEAR ( [Date] ), MONTH ( [Date] ), 1 ), EOMONTH ( [Date], 0 ), DAY ) + 1,
    "Year Month Number", INT ( FORMAT ( [Date], "YYYYMM" ) ),
    "Year Month Name", FORMAT ( [Date], "YYYY-MMM" ),
    "Day", DAY ( [Date] ),
    "Day Name", FORMAT ( [Date], "DDDD" ),
    "Day Name Short", FORMAT ( [Date], "DDD" ),
    "Day of Week", WEEKDAY ( [Date] ),
    "Day of Year", DATEDIFF ( DATE ( YEAR ( [Date] ), 1, 1 ), [Date], DAY ) + 1,
    "Month Name", FORMAT ( [Date], "MMMM" ),
    "Month Name Short", FORMAT ( [Date], "MMM" ),
    "Quarter", QUARTER ( [Date] ),
    "Quarter Name", "Q" & FORMAT ( [Date], "Q" ),
    "Year Quarter Number", INT ( FORMAT ( [Date], "YYYYQ" ) ),
    "Year Quarter Name", FORMAT ( [Date], "YYYY" ) & " Q" & FORMAT ( [Date], "Q" ),
    "Start of Quarter", DATE ( YEAR ( [Date] ), ( QUARTER ( [Date] ) * 3 ) - 2, 1 ),
    "End of Quarter", EOMONTH ( DATE ( YEAR ( [Date] ), QUARTER ( [Date] ) * 3, 1 ), 0 ),
    "Fiscal Year", IF ( _startOfFiscalYear = 1, YEAR ( [Date] ), YEAR ( [Date] ) + QUOTIENT ( MONTH ( [Date] ) + ( 13 - _startOfFiscalYear ), 13 ) ),
    "Fiscal Quarter", QUARTER ( DATE ( YEAR ( [Date] ), MOD ( MONTH ( [Date] ) + ( 13 - _startOfFiscalYear ) - 1, 12 ) + 1, 1 ) ),
    "Fiscal Month", MOD ( MONTH ( [Date] ) + ( 13 - _startOfFiscalYear ) - 1, 12 ) + 1,
    "Day Offset", DATEDIFF ( _today, [Date], DAY ),
    "Month Offset", DATEDIFF ( _today, [Date], MONTH ),
    "Quarter Offset", DATEDIFF ( _today, [Date], QUARTER ),
    "Year Offset", DATEDIFF ( _today, [Date], YEAR )
)
```
`Year` is **text** on purpose, because `FactExchangeRates[Year]` is text and the currency measure compares the two.

Then:
1. *Table tools → **Mark as date table*** → `Date`. Time intelligence (YTD / LY / LM) depends on this.
2. Select `Year Month Name` → *Column tools → Sort by column* → `Year Month Number`.
   Without this, the months sort alphabetically (2018-Apr, 2018-Aug…).

**`DimCurrency`**, the list behind the currency slicer:
```dax
DimCurrency = DISTINCT ( FactExchangeRates[Currency] )
```

---

## 5. Relationships (10 min)

In *Model view*, drag each key onto its match, or use *Manage relationships → New*.
All of them are **many-to-one (*:1), single direction, active**.

| From (many side) | To (one side) |
|---|---|
| `FactSalesOverview[Business Line no.]` | `DimBusinessLine[Business Line No]` |
| `FactSalesOverview[Product No]` | `DimProduct[Product No]` |
| `FactSalesOverview[Year Week Number]` | `DimCalendar_x[Year Week]` |
| `FactSalesOverview[CalendarDates]` | `DimDate[Date]` *(create `CalendarDates` first, see step 3)* |
| `FactExchangeRates[CalendarDate]` | `DimDate[Date]` |
| `FactExchangeRates[Currency]` | `DimCurrency[Currency]` |

```
DimBusinessLine   DimProduct   DimCalendar_x
        \             |             /
         \            |            /
          FactSalesOverview  ── CalendarDates ──►  DimDate  ◄── CalendarDate ── FactExchangeRates ──► DimCurrency
```
Product number 99 appears in sales but not in `DimProduct`, so it shows as **(Blank)** in product
visuals. That's a data issue you can mention, not something you did wrong.

---

## 6. Measures (30 min)

Create an empty table to hold them: *Home → Enter data → name it `_Measures` → Load*. Add each
measure with *New measure* and set the format shown.

### 6.1 Base measures
```dax
TotalSales DKK = SUM ( FactSalesOverview[Sales Amount DKK] )            -- format: #,0
TotalSales Qty = SUM ( FactSalesOverview[Sales Qty] )                   -- format: #,0
```

### 6.2 Currency conversion (the core idea of this case)
```dax
TotalSales =
VAR SelectedYear     = SELECTEDVALUE ( DimDate[Year] )
VAR SelectedCurrency = SELECTEDVALUE ( DimCurrency[Currency] )
VAR Rate =
    DIVIDE (
        LOOKUPVALUE (
            FactExchangeRates[Exchange Rate],
            FactExchangeRates[Currency], SelectedCurrency,
            FactExchangeRates[Year], SelectedYear
        ),
        100
    )
RETURN
    DIVIDE ( [TotalSales DKK], Rate )                                   -- format: #,0
```
The measure takes the selected currency, looks up that year's rate (DKK per 1 unit), and
divides the DKK amount by it.

> ⚠️ **Limitation in the solution's version.** `SELECTEDVALUE` returns blank when more than one year is
> in context, for example a card with no year selected or a by-country chart across all years. The
> whole measure then goes blank. The solution works around this by always forcing one year with the
> Year slicer. A sturdier version converts year by year and adds the results up:
> ```dax
> TotalSales =
> VAR SelectedCurrency = SELECTEDVALUE ( DimCurrency[Currency], "DKK" )
> RETURN
>     SUMX (
>         VALUES ( DimDate[Year] ),
>         VAR Rate =
>             DIVIDE (
>                 LOOKUPVALUE (
>                     FactExchangeRates[Exchange Rate],
>                     FactExchangeRates[Currency], SelectedCurrency,
>                     FactExchangeRates[Year], DimDate[Year]
>                 ),
>                 100
>             )
>         RETURN DIVIDE ( [TotalSales DKK], Rate )
>     )
> ```
> It also defaults to DKK when no currency is picked, which is what the report's note
> *"the selected currency by default is DKK"* promises. Build the original first, then
> swap this version in and explain the improvement. It makes a good interview story.

Fixed-currency variant used on the check page:
```dax
Total Sales EUR =
VAR SelectedYear = SELECTEDVALUE ( DimDate[Year] )
VAR Rate =
    DIVIDE (
        LOOKUPVALUE (
            FactExchangeRates[Exchange Rate],
            FactExchangeRates[Currency], "EUR",
            FactExchangeRates[Year], SelectedYear
        ),
        100
    )
RETURN
    DIVIDE ( [TotalSales DKK], Rate )                                   -- format: #,0
```

### 6.3 KPI and time intelligence
```dax
ASP = DIVIDE ( [TotalSales], [TotalSales Qty] )                         -- Average Selling Price

TotalSales YTD = CALCULATE ( [TotalSales], DATESYTD ( DimDate[Date] ) )
TotalSales LY  = CALCULATE ( [TotalSales], DATEADD ( DimDate[Date], -1, YEAR ) )
TotalSales LM  = CALCULATE ( [TotalSales], DATEADD ( DimDate[Date], -1, MONTH ) )

Sales YoY% =
IF ( ISBLANK ( [TotalSales LY] ), BLANK (), DIVIDE ( [TotalSales], [TotalSales LY] ) - 1 )   -- format: 0.00%

Sales MoM% =
IF ( ISBLANK ( [TotalSales LM] ), BLANK (), DIVIDE ( [TotalSales], [TotalSales LM] ) - 1 )   -- format: 0.00%
```
Why LY works even though the Year slicer is set to 2020: `DATEADD` shifts the dates to 2019, and
because `DimDate` is *marked as a date table* the slicer's Year filter is replaced. Inside the
shifted context, `SELECTEDVALUE(DimDate[Year])` becomes "2019", so last year is converted at
**last year's** exchange rate.

### 6.4 Product mix (optional; the solution defines these but no visual uses them)
```dax
Sales Allproduct = CALCULATE ( [TotalSales], ALL ( DimProduct[Product Name] ) )

Market Share% = DIVIDE ( [TotalSales], [Sales Allproduct] )             -- format: 0.00%

Expected Sales by List Price =
SUMX ( FactSalesOverview, FactSalesOverview[Sales Qty] * FactSalesOverview[List Price] )
```
> ⚠️ The solution's `Market Share%` divides **`[TotalSales DKK]`** by a converted total, which mixes
> currencies, so it is only right when DKK is selected. The version above uses `[TotalSales]` on both sides.
> The solution's `Expected Sales by List Price` wraps a measure in `ADDCOLUMNS` over the whole fact table.
> That gives the same result but is much slower than the plain `SUMX` above.

---

## 7. Report pages (2–3 h)

### 7.1 Theme and page setup
- *View → Themes → Browse for themes*. The solution uses a custom "nordic-flipflop" theme; any
  clean theme works. Page size: 16:9, **1280 × 720**.
- Pages 2–4 share a **left sidebar**: a rectangle 175 px wide and full height, holding the page title
  and the slicers. Build it once on OVERVIEW, then copy and paste it onto the other pages.

### 7.2 Slicers (on OVERVIEW, TIME INTEL and SALES DETAILS)
| Slicer | Field | Style | Default selection |
|---|---|---|---|
| Year | `DimDate[Year]` | Dropdown, **single select** | 2020 |
| Currency | `DimCurrency[Currency]` | Dropdown, **single select** | DKK (the saved solution has SEK) |
| Launch Year | `DimProduct[Launch Year]` | Dropdown | none |

Add a text box: *"Please note the selected currency by default is DKK"*.
*View → **Sync slicers***: tick all three pages for each slicer, so a choice made on one page carries to the others.
*Format → Selection → Single select = On* for Year and Currency. The currency measure needs exactly one of each.

### 7.3 Page 1: COVER
- Large text box "YourFashion SALES REPORT", plus a background image (any product photo).
- A "GO" text and arrow shape. *Format → Action → Type: Page navigation → Destination: OVERVIEW*.
  In Desktop you **Ctrl+click** to follow it.

### 7.4 Page 2: OVERVIEW
| Position | Visual | Fields | Settings |
|---|---|---|---|
| Top | **Page navigator** (*Insert → Buttons → Navigator → Page navigator*) | — | Hide COVER, CONTACT, ProductTooltip and Page 1 in its *Pages* settings |
| Row 1 | 4 × **Card** | `ASP`, `TotalSales Qty`, `TotalSales`, `Sales YoY%` | Rename each card's title to a business name |
| Mid-left | **Clustered column** | X: `DimBusinessLine[Country]`, Y: `TotalSales` | Sort by TotalSales, descending |
| Mid-right | **Pie** | Legend: `DimProduct[SubCategory]`, Values: `TotalSales` | Title "Total Sales by SubCategory" |
| Bottom-left | **Line and clustered column** | X: `DimDate[Year Month Name]`, column Y: `TotalSales` | Title "Total Sales by Time"; optionally add `TotalSales LY` as the line |
| Bottom-right | **Clustered bar** | Y: `DimBusinessLine[Business Line Name]`, X: `TotalSales Qty` | *Filters pane → Business Line Name → Filter type **Top N** → Top 5 by `TotalSales Qty`*. Title "Best Selling Business Line by Sales Qty" |

### 7.5 Page 3: TIME INTEL
| Visual | Fields | Settings |
|---|---|---|
| **Stacked area** (large, top) | X: `DimDate[Year Month Name]`, Y: `TotalSales YTD`, Legend: `DimProduct[SubCategory]` | YTD resets every January, which gives the saw-tooth shape |
| **Line** (bottom-left) | X: `Year Month Name`, Y: `Sales YoY%` | Title "YoY Growth Rate" |
| **Line** (bottom-right) | X: `Year Month Name`, Y: `Sales MoM%` | Title "MoM Growth Rate" |
| **Bookmark navigator** (left of the area chart) | — | See below |

**Country bookmarks:** for each of Germany, Italy and Spain:
1. In the area chart's *Filters on this visual*, set `DimBusinessLine[Country]` to only that country.
2. Select only the area chart, then *View → Bookmarks → Add* and rename the bookmark to the country name.
   In the bookmark's ⋯ menu, keep **Data** ticked and choose **Selected visuals**. The bookmark then
   stores only the area chart's filter and doesn't overwrite your slicers.
3. *Insert → Buttons → Navigator → **Bookmark navigator***, which creates one button per bookmark.

For the area chart to show all years, set the Year slicer to a single year anyway; YTD/LY handle
the rest. If you switched to the improved `TotalSales` in 6.2, you can instead turn on
*Edit interactions* and set the Year slicer to **None** on this chart.

### 7.6 Page 4: SALES DETAILS
| Visual | Fields | Settings |
|---|---|---|
| **Scatter** (top-left) | Values: `DimProduct[Product Name]`, X: `ASP`, Y: `TotalSales Qty` | Each dot is one product. Shows price vs volume. *Format → Tooltips → Type: Report page → Page: ProductTooltip* |
| **Map** (top-right) | Location: `DimBusinessLine[Country]`, Legend: `DimProduct[SubCategory]`, Bubble size: `TotalSales` | Title "Total Sales by Region". If maps are disabled: *File → Options → Security → Use Map and Filled Map visuals* |
| **Clustered bar** (bottom-left) | Y: `Product Name`, X: `TotalSales` | Visual filter: Product Name **Top N = Top 3** by `TotalSales` |
| **Clustered bar** (bottom-right) | same | **Top N → Bottom 3** by `TotalSales`. Many products have 0 sales, so ties make this show more than 3. Add a visual filter `TotalSales` *is greater than 0* to make it meaningful |

### 7.7 Page 5: ProductTooltip (a report-page tooltip)
1. New page → *Format page → Page information → **Allow use as tooltip** = On*; *Canvas settings → Type: **Tooltip*** (320 × 240).
2. Four cards: `TotalSales`, `TotalSales Qty`, `ASP`, and `DimProduct[SubCategory]` (set to **First**).
3. Drag `DimProduct[Product Name]` into the page's **Tooltip** well.
4. Right-click the page tab → **Hide page**.
   Hovering a dot on the scatter now shows this mini-card for that product.

### 7.8 Page 6: CONTACT
Text boxes with name, email and copyright, plus a logo image. Hidden from the page navigator.

### 7.9 "Page 1": a check page
The solution has a scratch page with a table showing `TotalSales` and `Total Sales EUR` plus the
Year and Currency slicers, used to check the conversion. Build it, set currency = EUR, and both columns
must match. Then **hide** the page.

---

## 8. Check your numbers

Computed from the raw Excel files with the cleaning in §2. The solution `.pbix` shows slightly
different figures (2020 = 2,714,722,926 DKK, 15,978,069 units) because it kept the junk-key rows and
rounded the units.

| Year | TotalSales DKK | TotalSales SEK | TotalSales Qty | ASP (DKK) |
|---|---|---|---|---|
| 2018 | 2,487,740,053 | 3,422,099,960 | 14,160,780 | 175.68 |
| 2019 | 2,482,279,917 | 3,519,910,944 | 15,407,050 | 161.11 |
| 2020 | 2,714,641,749 | 3,817,003,937 | 15,971,868 | 169.96 |

- **Sales YoY% 2020:** +9.36% in DKK, but **+8.44% in SEK** and +11.6% in USD, because last year is
  converted at last year's rate. Seeing YoY change with the currency is how you know the measure works.
- **2020 by SubCategory (DKK):** Charms 1.82bn › Bracelet 559M › Dangle 221M › Necklace 118M.
- **2020 by Country (DKK):** Australia 846M › China 835M › Spain 437M › USA 338M › Germany 130M › Italy 128M.
- **Top 3 products 2020:** P 84 (207M DKK), P 186 (127M), P 94 (113M).
- **Top business line by qty 2020:** BL 1 (China), 4.25M units, nearly 3× the next (BL 25, 1.46M).

The [web version](../docs/case3/index.html) shows all of these, so you can compare any filter combination.

---

## 9. Data audit (what to say you found)

| Issue | Impact | Fix |
|---|---|---|
| 5,480 sales rows with junk keys (`#` business line, `'` product) | Rows can't join to dimensions; the solution's filter had a typo and kept them | Filter them out in Power Query |
| `Sales Qty` has decimals (6.14 units) | Auto-detected *Whole number* rounds every row | Set the type to Decimal |
| 229,537 rows (42%) are 0 units and 0 sales | Bigger model, no information | Remove |
| Launch dates are `dd.mm.yyyy` text; list prices contain `#` | Wrong dates / wrong prices on non-Danish PCs | `Date.FromText` with a format; replace `#` with 0 |
| Product 99 sells (198K DKK) but isn't in `Product.xlsx` | Shows as (Blank) | Report it to the data owner |
| A few products launched in 2021 already have 2020 sales (6.9M DKK) | Pre-launch sales or wrong launch dates | Flag it |
| 2020 has 53 ISO weeks, and the 4-4-5 calendar moves week 48 into November | YoY and monthly comparisons are distorted | Compare 52 weeks and Nov+Dec together |
| `ExchangeRate.xlsx` has a second sheet ("Info") with mismatched codes, and GBP is spelled `BGP` | Easy to load the wrong sheet | Load only the "Exchange Rate" sheet |

---

## 10. What the data says (the story)

1. **2020 grew +9.4%, but a third of that is an extra week.** 2020 has 53 ISO weeks and week 53 alone is
   71M DKK. On 52 comparable weeks growth is **+6.5%**. Units grew only +1.1% on 52 weeks, so growth
   came from a **higher average price** (161 → 170 DKK), not from selling more pieces.
2. **The peak moved earlier.** Q4 (weeks 40+) is 48% of the year. In 2020 weeks 44–48 (up to Black Friday
   week) were **+25%** vs 2019 and weeks 49–52 **−19%**. A monthly chart shows "Nov +85%, Dec −25%",
   which is mostly the calendar moving week 48 into November.
3. **Charms are the business, but growth came from elsewhere.** Charms are 67% of sales and were flat
   (−0.3%). Bracelets (+41%) and Dangles (+47%) drove growth. Dangles and Necklaces are new lines (almost no 2018 sales).
4. **Fast product turnover.** 62% of 2020 sales come from products launched in 2020 and 33% from 2019
   launches. 31 of 272 selling products make 80% of sales.
5. **Concentration.** Australia and China are 31% each. BL 1 in China sells 27% of all units. The USA (+16%)
   and Spain (+12%) grew fastest; Australia slowest (+7%).

**Recommendation:** report growth on comparable weeks and a fixed currency, plan stock and marketing for a
Black-Friday-led peak, keep the launch pipeline strong, and reduce dependence on BL 1 by growing the USA and Spain.

---

## 11. Publish the link for your resume

Power BI *Publish to web* needs a work or school account, so the public link is the **GitHub Pages**
web version in `docs/case3/`. It recomputes the same measures in the browser, as Case 2 does.

1. Merge this branch into `main` (open a PR on GitHub and merge it).
2. Repo **Settings → Pages → Build and deployment → Deploy from a branch → `main` / `/docs`** → Save.
   On a free account the repo must be **public**.
3. After about a minute: `https://jkazeyuki.github.io/DataProject/case3/`
4. Put the Power BI screenshots in `powerbi_case3/screenshots/` and link them at the top of this README,
   so reviewers see the real report too. Commit the `.pbix` as well.

To rebuild the web data: `python powerbi_case3/build_data.py "<folder with the 5 Excel files>"`

**Resume bullet:**
> **Multi-currency Sales Report, YourFashion** (Power BI, Power Query, DAX) [live link]
> Cleaned 540k weekly sales rows (invalid keys, rounding, locale-dependent dates) into a star-schema
> model; built DAX currency conversion across 7 currencies and YTD/YoY/MoM time intelligence; showed
> that a third of 2020's +9.4% growth came from a 53rd ISO week (like-for-like +6.5%).

---

## 12. Your 2-minute interview walkthrough

1. **Problem** (15 s): "A Danish jewelry brand sells in 6 countries. Managers want sales in their own
   currency and want to know how sales are developing."
2. **Data and cleaning** (30 s): "Five Excel files. I found junk keys, units being rounded, dates that only
   parse on a Danish PC, and 42% empty rows, and fixed them in Power Query."
3. **Model and DAX** (30 s): "Star schema. Sales are stored in DKK; one measure looks up the selected
   currency's rate for each year and converts. Time intelligence runs on a marked date table."
4. **Insight** (30 s): "Reported growth was 9.4%, but 2020 had 53 weeks. Like-for-like it's 6.5%, and it
   came from price and mix, not volume."
5. **Result** (15 s): "Interactive report plus a public web version." Then open the link.
