# Build Case 3 Yourself: A Workbook

This is the learning version of the case. Each task gives you a **goal**, the **check** that proves
you got it right, and **hints** that stay folded until you click them. The finished code is in
`README.md`, linked under *Answer*. Open it only after you've tried, or to compare with your own.

**How to work through each task**
1. Read the goal and the check.
2. Try for **10–15 minutes** without hints. Use the Power BI menus, right-click menus and the formula bar.
3. Stuck? Open **Hint 1**. Still stuck after 5 more minutes? Open **Hint 2**.
4. Pass the **check** before moving on. The numbers must match.
5. Answer the **Explain it** question out loud. That's the interview version of the task.

Same 3-day rhythm as the [plan](README.md#the-3-day-plan). Data files go in `C:\Case3\`.
Turn off *Auto date/time* first (`File → Options → Current file → Data Load`).

---

# Day 1: Get clean data into a model

## Task 1: Explore before you build (30 min)
**Goal:** know what's in the 5 Excel files before touching Power BI.
Open each file in Excel and answer these on paper:
1. What does one row of `SalesOverview` represent?
2. Which column links `SalesOverview` to `Product`? To `BusinessLine`? To `Calendar`?
3. The sales have a week number but no date. How could you get a month?
4. What unit is `Exchange Rate` in? (Look at DKK's value.)
5. Find at least **3 things that look wrong or odd** in the data.

<details><summary>Hint: where to look for odd things</summary>

Sort or filter each key column and look at the first and last values. Look at the format of the dates
in `Product`. Look at `Sales Qty`: are they whole numbers? Count how many rows have 0 in both units and sales.
</details>

<details><summary>Check</summary>

1. Week × business line × product, with units and DKK amount.
2. `Product No`; `Business Line no.` ↔ `Business Line No`; `Year Week Number` ↔ `iso_week` + `calendar_year` (no single matching column; you'll need to build one).
3. `Calendar.xlsx` maps each ISO week to a month.
4. DKK per **100** units of the currency (DKK = 100).
5. Any of: `#` as a business line, `'` as a product number, decimal units, `dd.mm.yyyy` launch dates, `#` list prices, product 99 not in the product list, 42% of rows all zeros, GBP spelled `BGP`, a messy "Info" sheet in ExchangeRate.
</details>

**Explain it:** "What's a fact table and what's a dimension table in this case?"

---

## Task 2: Load and clean the dimensions (60 min)
**Goal:** load `BusinessLine`, `Product`, `Calendar` and `ExchangeRate` using **Power Query clicks
only** (no Advanced Editor), with correct data types.

Requirements:
- Use a text parameter `FolderPath` for the folder, so the file works on another PC.
- `Product`: launch dates must be correct dates, and `List Price DKK` must be a number (the `#` cells become 0).
- `ExchangeRate`: load only the right sheet.
- `Calendar`: keep year, week and month as **text**; you'll glue them together later.

<details><summary>Hint 1: parameter and loading</summary>

`Home → Transform data` → `Manage Parameters → New Parameter`. Load a file with `New Source → Excel
workbook`. To use the parameter afterwards, click the **Source** step's gear icon (or edit the formula
bar) and replace the hard-coded folder with `FolderPath & "\Product.xlsx"`.
</details>

<details><summary>Hint 2: the two tricky Product columns</summary>

- **Launch Date** is `01.06.2020` = 1 June. Right-click the column header → **Change Type → Using Locale…**
  → Data type *Date*, Locale **Danish (Denmark)**.
- **List Price DKK**: change the type to *Decimal Number*. The `#` cells turn into **Error**. Then right-click
  the header → **Replace Errors** → `0`.
</details>

<details><summary>Check</summary>

- Row counts: BusinessLine **29**, Product **287**, Calendar **2,662**, ExchangeRate **21**.
- Product P 1: Launch Date **1 June 2020** (not 6 January). P 2: List Price **67.5** (not 675).
- No yellow error bars in any query.
</details>

<details><summary>Answer</summary>

[README §1–2.4](README.md#1-folder-parameter-5-min). The README uses `Date.FromText` instead of *Using
Locale*; both are correct.
</details>

**Explain it:** "Why did the dates need a locale?"

---

## Task 3: Load and clean the sales table (45 min)
**Goal:** a clean `FactSalesOverview`:
- Remove rows whose product or business-line key isn't a number.
- Units must keep their decimals.
- Keys must be **whole numbers** (to match the dimension keys).
- Optional: remove rows where units **and** sales are both 0.

<details><summary>Hint 1</summary>

Look at the values in the filter dropdown of `Business Line no.` and `Product No`. Two junk values appear.
You can untick them in the filter, *or* change the type to Whole Number and then use
`Home → Remove Rows → Remove Errors`.
</details>

<details><summary>Hint 2: the optional zero rows</summary>

The column filter only looks at one column at a time. Use `Add Column → Custom Column` with
`[Sales Qty] <> 0 or [Sales Amount DKK] <> 0`, filter it to `TRUE`, then delete the helper column.
</details>

<details><summary>Check</summary>

- Rows: **313,125** after removing junk keys, or **307,588** if you also removed the zero rows.
- `Sales Qty` header shows **1.2** (decimal), not **123**.
- After *Close & Apply*, a table visual with `SUM(Sales Amount DKK)` shows **7,684,661,719** in total.
</details>

<details><summary>Answer</summary>

[README §2.5](README.md#25-factsalesoverview).
</details>

**Explain it:** "What would have happened if you'd left `Sales Qty` as a whole number?"

---

## Task 4: Build the keys and the date table (45 min)
**Goal:**
1. The sales `Year Week Number` looks like `13.2020`. Create a column in `DimCalendar_x` with **exactly**
   the same format, so the two tables can be joined.
2. Give each sales row a real **date** (the 1st of its month), so it can join a date table.
3. Create a date table `DimDate` for 2015–2020 with at least: `Date`, `Year` (as **text**),
   `Year Month Name` (e.g. 2020-Jan) and `Year Month Number` (e.g. 202001). **Mark it as a date table.**
   Make months sort in date order.
4. Create a one-column table `DimCurrency` with each currency once.
5. Give `FactExchangeRates` a date column (1 January of its year).

<details><summary>Hint 1: functions you'll need</summary>

Columns: `RIGHT`, `&`, `DATE`, `VALUE`, `RELATED`. Tables: `CALENDAR`, `ADDCOLUMNS`, `FORMAT`, `DISTINCT`.
Look them up on dax.guide if needed.
</details>

<details><summary>Hint 2</summary>

- The week has to be 2 digits: put `"0"` in front and keep the right 2 characters.
- The date per sales row must come from the calendar table, so the relationship on the week key has to exist first.
- `Year` must be text because `FactExchangeRates[Year]` is text; you'll compare them in a measure.
- Month sorting: `Column tools → Sort by column`.
</details>

<details><summary>Check</summary>

- `DimCalendar_x` contains the key `09.2020` (with the leading zero).
- `DimDate`: **2,192** rows; marked as a date table.
- `DimCurrency`: **7** rows.
</details>

<details><summary>Answer</summary>

[README §3–4](README.md#3-calculated-columns-15-min).
</details>

**Explain it:** "Why is a separate date table better than using the date column in the sales table?"

---

## Task 5: Relationships (30 min)
**Goal:** connect the tables so that a filter on country, product, month or currency reaches the right rows.
Work out yourself which 6 relationships you need, and in what order you can create them.

<details><summary>Hint</summary>

Draw it on paper first: the sales table in the middle, its 3 dimension tables and the date table around it.
Then the exchange-rate table, which needs to know the year and the currency. Every relationship is
many-to-one, single direction, from the fact table to the dimension.
</details>

<details><summary>Check</summary>

A table visual with `DimDate[Year]` + `SUM(Sales Amount DKK)` + `SUM(Sales Qty)`:

| Year | Sales DKK | Units |
|---|---|---|
| 2018 | 2,487,740,053 | 14,160,780 |
| 2019 | 2,482,279,917 | 15,407,050 |
| 2020 | 2,714,641,749 | 15,971,868 |

No "(Blank)" row.
</details>

<details><summary>Answer</summary>

[README §5](README.md#5-relationships-10-min).
</details>

**Explain it:** draw your model from memory in 1 minute.

✅ **End of Day 1:** save as `YourFashion_Sales.pbix` and upload it to GitHub.

---

# Day 2: Measures and pages

## Task 6: The currency measure (60 min, the core of the case)
**Goal:** a measure `TotalSales` that shows sales in the currency chosen in a `DimCurrency` slicer,
converted at the **selected year's** rate. Test it with a Year slicer, a Currency slicer and a card.

Write your own `TotalSales DKK` and `TotalSales Qty` sum measures first, in a `_Measures` table (`Home → Enter data`).

<details><summary>Hint 1: think it through</summary>

In words: *which currency is selected? which year? what's the rate for that pair? DKK ÷ (rate ÷ 100)*.
Functions: `SELECTEDVALUE`, `LOOKUPVALUE`, `DIVIDE`, `VAR … RETURN`.
</details>

<details><summary>Hint 2: level up</summary>

Your first version probably goes blank when no single year is selected. Fix it by converting **each
year separately and adding them up**: `SUMX(VALUES(DimDate[Year]), …)`. Default to DKK with the second
argument of `SELECTEDVALUE`.
</details>

<details><summary>Check</summary>

| Selection | Expected |
|---|---|
| 2020 + DKK | 2,714,641,749 |
| 2020 + SEK | 3,817,003,937 |
| 2020 + EUR | 364,174,865 |
| Nothing selected (improved version) | 7,684,661,719 |
</details>

<details><summary>Answer</summary>

[README §6.2](README.md#62-currency-conversion-the-core-idea-of-this-case).
</details>

**Explain it:** "Why is currency conversion a measure and not a calculated column?"

---

## Task 7: KPI and time-intelligence measures (45 min)
**Goal:** `ASP`, `TotalSales YTD`, `TotalSales LY`, `TotalSales LM`, `Sales YoY%`, `Sales MoM%`.
All of them must build on `[TotalSales]`, so they follow the currency slicer. YoY% and MoM% should
show blank (not −100% or an error) when there's nothing to compare with.

<details><summary>Hint</summary>

`CALCULATE([TotalSales], <shifted dates>)` with `DATESYTD` or `DATEADD(DimDate[Date], -1, YEAR)`.
For the % measures: `DIVIDE(now, before) - 1`, wrapped in `IF(ISBLANK(before), BLANK(), …)`.
</details>

<details><summary>Check (Year 2020)</summary>

- DKK: `Sales YoY%` **9.36%**, `ASP` **169.96**.
- SEK: `Sales YoY%` **8.44%**. If it's still 9.36%, your LY measure isn't using `[TotalSales]`.
- `TotalSales YTD` for 2020-Dec equals the 2020 total.
</details>

<details><summary>Answer</summary>

[README §6.3](README.md#63-kpi-and-time-intelligence).
</details>

**Explain it:** "Why does YoY growth differ between DKK and SEK?"

---

## Task 8: Design and build the pages (2–3 h)
**Goal:** a report that answers *"How are sales developing, where, and for which products?"* in any currency.
It must have:
- A **cover** page with a button that leads into the report.
- An **overview** page: 4 KPI cards, sales by country, sales by subcategory, sales over time, top 5 business lines by units.
- A **time** page: YTD by subcategory, YoY % and MoM % trends, and **bookmarks** that switch a chart between Germany, Italy and Spain.
- A **details** page: price vs volume per product (scatter), a map, top 3 and bottom 3 products.
- A **tooltip page** that appears when hovering a product on the scatter.
- Year, currency and launch-year slicers that apply to **all** report pages.
- **Page navigation** buttons on every report page.

**Sketch your layout on paper first** (1280 × 720), then build. Choose your own colours and fonts.

<details><summary>Hint 1: features to look for</summary>

`Insert → Buttons → Navigator` (page and bookmark navigators); `View → Sync slicers`; `View → Bookmarks`
(save them with *Selected visuals* only); `Format page → Page information → Allow use as tooltip`;
Filters pane → *Top N*; `Insert → Shapes` for a sidebar.
</details>

<details><summary>Hint 2: when something doesn't work</summary>

See the "If something goes wrong on Day 2" table in [DAY_BY_DAY.md](DAY_BY_DAY.md#if-something-goes-wrong-on-day-2).
</details>

<details><summary>Check</summary>

- Changing the currency on one page changes it on every page.
- Bookmark buttons switch only the chart, not the slicers.
- Bottom 3 shows products that actually sold (not zeros).
- Top 3 products (2020): P 84, P 186, P 94. Top business line by units: BL 1 (China).
</details>

<details><summary>Answer: two versions</summary>

- Step by step: [DAY_BY_DAY.md Steps 2.4–2.8](DAY_BY_DAY.md#step-24-theme-and-page-frame-30-min)
- Pixel-exact copy of the solution's design: [MATCH_THE_SOLUTION.md](MATCH_THE_SOLUTION.md)
</details>

**Explain it:** "Walk me through your report in 60 seconds."

✅ **End of Day 2:** upload the `.pbix` again.

---

# Day 3: Find the story and publish

## Task 9: Find the insights yourself (60–90 min)
Answer each question **using only your report**. Write down the number and the visual you used.

1. 2020 sales grew vs 2019. Is all of that growth real? *(Look at how many weeks each year has.)*
2. Did growth come from selling **more pieces** or from **higher prices**?
3. Which subcategory is the biggest? Is it growing? Which ones drove growth?
4. How old are the products that sell? *(Use `DimProduct[Launch Year]`.)*
5. Which countries and which business line dominate? Which country grew fastest?
6. The monthly chart shows November 2020 way up and December 2020 way down. Why might that be partly a calendar effect? *(Compare which weeks belong to November in 2019 vs 2020 in `DimCalendar_x`.)*

<details><summary>Hint for question 1</summary>

Make a table of `DimCalendar_x[Year Week]` and `TotalSales DKK`. Filter to week numbers above 50. Which year has a week 53?
</details>

<details><summary>Check your answers</summary>

[README §10 What the data says](README.md#10-what-the-data-says-the-story) and the
[web version](https://jkazeyuki.github.io/DataProject/case3/) (use the *Comparable 52 weeks* switch).
</details>

Then write a **"Key insights"** text box on your overview page with your 3 best findings, in your own words.

## Task 10: Polish, publish, present (2–3 h)
Follow [DAY_BY_DAY.md Day 3, Steps 3.2–3.6](DAY_BY_DAY.md#step-32-polish-60-min): polish checklist,
screenshots, GitHub Pages link, resume bullet, 2-minute walkthrough.

---

## Self-assessment: are you interview-ready?
Tick only what you can do **without notes**:
- [ ] Draw the data model and name every relationship.
- [ ] Explain each Power Query cleaning step and why it was needed.
- [ ] Write `TotalSales` from memory.
- [ ] Explain the difference between a calculated column and a measure, using this case.
- [ ] Explain what marking a date table does and why `DATEADD` needs it.
- [ ] Present 3 insights with numbers, including the 53-week effect.
- [ ] Say what you'd do next with more data (daily dates, monthly FX rates, cost and margin data).
