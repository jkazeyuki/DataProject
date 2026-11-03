# Case 3 — Day-by-Day Walkthrough

Click-by-click instructions for the [3-day plan](README.md#the-3-day-plan). Follow the steps in order.
Each day ends with a **checkpoint**. If your numbers match it, move on. If they don't, use the
"If something goes wrong" table for that day before continuing.

`README.md` is the reference: it explains *why* each step exists and has the findings. This file is
the *how*.

**Conventions**
- `Home → Transform data` means: click the **Home** ribbon tab, then the **Transform data** button.
- 🔎 **Check:** what you should see on screen before moving on.
- ⏱ Times are estimates for a first attempt.

---

## Before Day 1 (15 min, do it the evening before)

1. **Windows + Power BI Desktop.** On your Mac, start the Windows VM. Open the Microsoft Store, search
   **Power BI Desktop**, and click *Get*. You don't need to sign in to build the report: close the sign-in
   box whenever it appears.
2. **Data folder.** Inside Windows, create `C:\Case3\` and copy the 5 Excel files into it:
   `SalesOverview.xlsx`, `Product.xlsx`, `BusinessLine.xlsx`, `Calendar.xlsx`, `ExchangeRate.xlsx`.
   Use exactly these names; the queries refer to them.
3. **Look at the files for 2 minutes each in Excel.** Find these columns and say out loud what one row
   means:
   - `SalesOverview` → `Year Week Number`, `Business Line no.`, `Product No`, `Sales Qty`, `Sales Amount DKK`
     ("in week 1 of 2018, business line 2085 sold 6.14 units of product 2 for 245 DKK")
   - `Product` → `Launch Date` (written `01.06.2020`), `List Price DKK` (some cells are `#`)
   - `ExchangeRate` → only the **Exchange Rate** sheet matters; ignore "Info"
4. Open the [live web version](https://jkazeyuki.github.io/DataProject/case3/) once (or `docs/case3/index.html`
   on GitHub) so you know what the end result looks like.

---

# Day 1: Understand the data and build the model (~4 h)

**Goal:** all 5 files loaded and cleaned, two calculated tables, six relationships, and a table
visual that shows the correct yearly totals.

### Step 1.1: Read the explanation (30 min)
Read [Understand the case in 10 minutes](README.md#understand-the-case-in-10-minutes). Then close it and
write, in your own words, 3 sentences on paper:
1. What one row of `SalesOverview` is.
2. Why the report needs `ExchangeRate.xlsx`.
3. What a "fact table" vs a "dimension table" is.

If you can't, re-read. Interviewers will ask you exactly this.

### Step 1.2: New file and settings (10 min)
1. Open Power BI Desktop → **Blank report**.
2. `File → Save as` → `C:\Case3\YourFashion_Sales.pbix`. Press **Ctrl+S** often from now on.
3. `File → Options and settings → Options`.
   - Left list, under **CURRENT FILE** → **Data Load** → untick **Auto date/time** → OK.
   - (Optional, recommended) under **GLOBAL** → **Data Load** → untick **Auto date/time for new files**.

   *Why:* otherwise Power BI creates a hidden date table for every date column, which clutters the
   model and conflicts with the real date table you'll build.
4. Still in Options: **GLOBAL → Security** → tick **Use Map and Filled Map visuals** (needed on Day 2) → OK.

### Step 1.3: The folder parameter (5 min)
1. `Home → Transform data` (the top half of the button). The **Power Query Editor** window opens.
2. `Home → Manage Parameters → New Parameter`.
3. Fill in: **Name** `FolderPath` · **Type** Text · **Suggested Values** Any value ·
   **Current Value** `C:\Case3` (no `\` at the end) → **OK**.

🔎 **Check:** the left *Queries* pane shows `FolderPath` with the value `C:\Case3`.

### Step 1.4: Load each file with pasted M code (60 min)
Power Query records every cleaning action as a line of **M code**. Instead of clicking each step,
you'll create an empty query and paste the finished code. Then you'll read the steps so you can explain them.

Do the following **five times**, once per table below:

1. `Home → New Source → Blank Query`. A query called `Query1` appears.
2. Right-click `Query1` in the Queries pane → **Rename** → type the table name (e.g. `DimBusinessLine`).
3. `Home → Advanced Editor`. **Delete everything** in the box and paste the code from the README
   section listed below → **Done**.
4. 🔎 **Check:** the preview grid shows data, with no yellow "Expression.Error" bar. Look at the
   **Applied Steps** list on the right and click each step one at a time to see what it changes.

| Order | Query name | Code to paste | Rows (Table view shows the count at the bottom after Step 1.5) |
|---|---|---|---|
| 1 | `DimBusinessLine` | README §2.1 | 29 |
| 2 | `DimProduct` | README §2.2 | 287 |
| 3 | `DimCalendar_x` | README §2.3 | 2,662 |
| 4 | `FactExchangeRates` | README §2.4 | 21 |
| 5 | `FactSalesOverview` | README §2.5 | **307,588** |

**For `DimProduct`, check:**
- Product **P 1** has Launch Date **01/06/2020 = 1 June 2020**, *not* 6 January. Hover the cell; the
  tooltip shows the full date.
- `List Price DKK` shows `67.5`, `217.5`… (not `675`), and the 10 `#` cells became `0`.

**For `FactSalesOverview`** (it takes 30–60 s to load, which is normal for a 17 MB file), check:
- `Sales Qty` has the **1.2** (decimal) icon in its header, not **123** (whole number).
- Click the filter arrow on `Business Line no.`: there's no `#` in the list.

*What each fact-table step does* (say this in interviews):
1. `Changed Type`: keys as text, so the junk values `#` and `'` don't cause errors yet. Units and amounts as decimals.
2. `Removed Bad Keys`: drops the 5,480 rows with `#` / `'` keys.
3. `Removed Empty Rows`: drops 229,537 rows where nothing was sold.
4. `Key Types`: converts the keys to whole numbers so they match the dimension keys.

### Step 1.5: Close & Apply (5 min)
`Home → Close & Apply`. A loading box counts rows. When it finishes, the **Data** pane on the right
lists your 5 tables. (`FolderPath` is a parameter, not a table, so it isn't listed.)

### Step 1.6: Calculated columns, part 1 (15 min)
Switch to **Table view** (the grid icon on the far left). Select a table in the Data pane on the right.

**On `DimCalendar_x`:** `Table tools → New column`, paste, press Enter:
```dax
Year Week = RIGHT("0" & DimCalendar_x[iso_week], 2) & "." & DimCalendar_x[calendar_year]
```
Then `Table tools → New column` again:
```dax
Dates = DATE(VALUE(DimCalendar_x[calendar_year]), VALUE(DimCalendar_x[iso_month]), 1)
```
With the `Dates` column selected: `Column tools → Data type → Date`, and `Format → *14/03/2001`
(any date format).

🔎 **Check:** scroll to a 2020 row; `Year Week` looks like `09.2020`, matching the fact table's format.

**On `FactExchangeRates`:**
```dax
CalendarDate = DATE(VALUE(FactExchangeRates[Year]), 1, 1)
```
**On `DimProduct`:**
```dax
Launch Year = FORMAT(DimProduct[Launch Date], "YYYY")
```

### Step 1.7: Calculated tables (15 min)
1. `Table tools → New table` (or `Modeling → New table`). Paste the whole **DimDate** formula from
   README §4 → Enter. 🔎 **Check:** 2,192 rows, 2015-01-01 to 2020-12-31.
2. With `DimDate` selected: `Table tools → Mark as date table` → pick **Date** → OK.
   🔎 **Check:** the status line under the ribbon or the table's properties says it's marked.
   *This step is what makes "last year" and "YTD" work on Day 2.*
3. Click the `Year Month Name` column → `Column tools → Sort by column → Year Month Number`.
   *Without it, months sort alphabetically: 2018-Apr, 2018-Aug, 2018-Dec…*
4. `Table tools → New table`:
   ```dax
   DimCurrency = DISTINCT ( FactExchangeRates[Currency] )
   ```
   🔎 **Check:** 7 rows (AUD, BGP, CNY, DKK, EUR, SEK, USD). `BGP` is the source's typo for GBP; leave it.

### Step 1.8: Relationships (30 min)
1. Switch to **Model view** (the third icon on the left). Drag the tables so the fact tables are in
   the middle and the dimensions around them.
2. `Home → Manage relationships`. If Power BI auto-created any relationships, **delete them all**
   (select → *Delete*); you'll create them deliberately.
3. Click **New relationship** for each row below. Pick the first table and column on top, the second
   below, and check that the dialog says **Many to one (\*:1)**, **Cross filter: Single**, and
   *Make this relationship active* ticked → OK.

| # | Top (many side) | Bottom (one side) |
|---|---|---|
| 1 | `FactSalesOverview` · `Business Line no.` | `DimBusinessLine` · `Business Line No` |
| 2 | `FactSalesOverview` · `Product No` | `DimProduct` · `Product No` |
| 3 | `FactSalesOverview` · `Year Week Number` | `DimCalendar_x` · `Year Week` |

4. Go back to **Table view** → `FactSalesOverview` → `Table tools → New column`, twice:
   ```dax
   CalendarDates = RELATED(DimCalendar_x[Dates])
   ```
   ```dax
   List Price = RELATED(DimProduct[List Price DKK])
   ```
   `RELATED` only works once relationships 1–3 exist, which is why these come now.
   🔎 **Check:** `CalendarDates` is filled on every row (no blanks), and its type is Date.
5. Back in **Model view → Manage relationships → New**:

| # | Top (many side) | Bottom (one side) |
|---|---|---|
| 4 | `FactSalesOverview` · `CalendarDates` | `DimDate` · `Date` |
| 5 | `FactExchangeRates` · `CalendarDate` | `DimDate` · `Date` |
| 6 | `FactExchangeRates` · `Currency` | `DimCurrency` · `Currency` |

🔎 **Check:** compare your Model view with the diagram in README §5. Every line has a **1** at the
dimension end and a **\*** at the fact end, and the arrows point towards the fact tables.

### Step 1.9: Checkpoint (10 min)
1. Switch to **Report view** (top icon). From the Visualizations pane, click **Table**.
2. Drag `DimDate` → `Year` into it, then `FactSalesOverview` → `Sales Amount DKK` (it sums automatically).
3. Add `FactSalesOverview` → `Sales Qty`.

✅ **Day 1 checkpoint:**

| Year | Sales Amount DKK | Sales Qty |
|---|---|---|
| 2018 | 2,487,740,053 | 14,160,780 |
| 2019 | 2,482,279,917 | 15,407,050 |
| 2020 | 2,714,641,749 | 15,971,868 |

If it matches: delete the test table, **Ctrl+S**, and you're done for the day.

**Commit:** on GitHub, open your repo → switch to the branch → `powerbi_case3` folder →
**Add file → Upload files** → drop `YourFashion_Sales.pbix` → commit message `Case 3 Day 1: data model`.

### If something goes wrong on Day 1

| Symptom | Cause | Fix |
|---|---|---|
| `DataSource.NotFound` / "Could not find file" | Path or file name differs | `Home → Manage Parameters`: check `FolderPath`; check the file names exactly |
| `Expression.Error: The column 'X' of the table wasn't found` | Header in your Excel differs (extra space, renamed) | Open the file and compare the header with the code |
| Launch dates are in January | You kept the auto-generated steps | Advanced Editor: make sure *only* the README code is there |
| Totals in the checkpoint are a bit higher (2,714,722,926 for 2020) | Junk rows still in | Check the `Removed Bad Keys` step is present and spelled exactly |
| Units total off by ~6K for 2020 | `Sales Qty` is a whole number | Power Query → set the type to *Decimal number* |
| Year column shows only "(Blank)" | Relationship 4 is missing or `CalendarDates` is empty | Recreate it; check relationships 1–3 exist before creating `CalendarDates` |
| "You can't create a relationship between these two columns because one of the columns must have unique values" | You picked the columns in the wrong order or the wrong column | The dimension (one side) must be the bottom table |
| Relationship dialog warns about different data types | A key is text on one side, number on the other | Power Query: set both keys to whole number (`Key Types` step) |

---

# Day 2: Measures and report pages (~4.5 h)

**Goal:** every measure works, and the OVERVIEW, TIME INTEL and SALES DETAILS pages are built.

### Step 2.1: A home for measures (5 min)
`Home → Enter data` → name it `_Measures` → **Load**. Keeping all measures in one table makes them
easy to find. (Once you've added your first measure, you can delete the dummy `Column1`.)

### Step 2.2: Base measures and the currency measure (40 min)
For each measure: select `_Measures` in the Data pane → `Home → New measure` → paste → Enter → then set
the format in `Measure tools → Format`.

1. `TotalSales DKK` and `TotalSales Qty`: README §6.1. Format: whole number with thousands separator.
2. `TotalSales`: README §6.2, **the original version first**. Format: whole number.
3. **Test it before building anything else:**
   - Add two **Slicer** visuals: one with `DimDate[Year]`, one with `DimCurrency[Currency]`.
   - Add a **Card** with `TotalSales`.
   - Select 2020 + DKK → **2,714,641,749**. Select SEK → **3,817,003,937**. Select nothing → the
     card shows **(Blank)**. That's the limitation explained in README §6.2.
4. Now replace `TotalSales` with the **improved version** from the same section (click the measure,
   select all the formula text in the bar, paste over it). 🔎 **Check:** with nothing selected the card now
   shows all-years DKK, 7,684,661,719.
5. `Total Sales EUR`: README §6.2.

*Understand it:* say out loud what each line of `TotalSales` does: "get the currency, get the rate for
that year, divide by 100 because rates are per 100 units, divide the DKK amount by it".

### Step 2.3: KPI and time-intelligence measures (20 min)
Add everything in README §6.3: `ASP`, `TotalSales YTD`, `TotalSales LY`, `TotalSales LM`,
`Sales YoY%`, `Sales MoM%`. Set `Sales YoY%` and `Sales MoM%` to **Percentage** with 2 decimals.

🔎 **Test with cards (Year 2020, DKK):** `Sales YoY%` = **9.36%**. Switch currency to SEK → **8.44%**.
`ASP` (DKK) = **169.96**.

Then optionally add README §6.4 (`Sales Allproduct`, `Market Share%`, `Expected Sales by List Price`).

### Step 2.4: Theme and page frame (30 min)

> **Want it to look exactly like the solution?** Follow [MATCH_THE_SOLUTION.md](MATCH_THE_SOLUTION.md)
> instead of Steps 2.4–2.8. It has every position, colour and font, plus reference pictures.
1. `View → Themes` → pick a clean built-in theme (e.g. *Classic* or *Innovate*). Keep it simple.
2. Rename the page: double-click the **Page 1** tab at the bottom → `OVERVIEW`.
3. `Format page` (paintbrush with no visual selected) → **Canvas settings** → Type *16:9* (1280 × 720).
4. **Sidebar:** `Insert → Shapes → Rectangle`. Set its size and position in `Format → General →
   Properties`: X 0, Y 0, width 175, height 720. Give it a dark fill.
5. **Title:** `Insert → Text box` → "OVERVIEW", white, bold, on top of the sidebar.
6. **Slicers** (place them in the sidebar, one under another):
   - **Year:** Slicer with `DimDate[Year]` → `Format visual → Visual → Slicer settings → Options → Style:
     Dropdown`; `Selection → Single select: On`. Pick **2020**.
   - **Currency:** Slicer with `DimCurrency[Currency]`, Dropdown, Single select. Pick **DKK**.
   - **Launch Year:** Slicer with `DimProduct[Launch Year]`, Dropdown, multi-select allowed.
7. Text box near the top: *"Please note the selected currency by default is DKK"*.

### Step 2.5: OVERVIEW visuals (60 min)
For each visual: click an empty part of the canvas, click the visual type in **Visualizations**, then
drag fields from **Data** into the wells. Rename visual titles in `Format visual → General → Title`.

1. **Page navigator** (top strip): `Insert → Buttons → Navigator → Page navigator`. Leave it for now; you'll
   hide helper pages from it at the end of Day 2.
2. **4 cards** in a row: `ASP`, `TotalSales Qty`, `TotalSales`, `Sales YoY%`. Rename the titles: "Avg selling
   price", "Units sold", "Total sales", "Growth vs last year".
3. **Clustered column chart:** X-axis `DimBusinessLine[Country]`, Y-axis `TotalSales`. Click `⋯` on the visual →
   *Sort axis → TotalSales* and *Sort descending*.
4. **Pie chart:** Legend `DimProduct[SubCategory]`, Values `TotalSales`. Title "Total Sales by SubCategory".
5. **Line and clustered column chart:** X-axis `DimDate[Year Month Name]`, Column y-axis `TotalSales`,
   Line y-axis `TotalSales LY`. Title "Total Sales by Time".
   🔎 **Check:** months are in date order. If they're alphabetical, redo Step 1.7.3.
6. **Clustered bar chart:** Y-axis `DimBusinessLine[Business Line Name]`, X-axis `TotalSales Qty`.
   Then in the **Filters** pane → *Filters on this visual* → expand `Business Line Name` → Filter type
   **Top N** → Show items *Top* **5** → drag `TotalSales Qty` into *By value* → **Apply filter**.
   Title "Best Selling Business Line by Sales Qty". 🔎 **Check:** BL 1 is on top with about 4.25M units.

### Step 2.6: TIME INTEL page (45 min)
1. Right-click the OVERVIEW tab → **Duplicate page** → rename it `TIME INTEL`. Delete everything except the
   sidebar, title, slicers and navigator. Change the title text to "TIME INTEL".
2. **Stacked area chart** (top, wide): X-axis `Year Month Name`, Y-axis `TotalSales YTD`, Legend
   `DimProduct[SubCategory]`. The saw-tooth shape is YTD resetting every January.
3. **Line chart** (bottom-left): X `Year Month Name`, Y `Sales YoY%`. Title "YoY Growth Rate".
4. **Line chart** (bottom-right): X `Year Month Name`, Y `Sales MoM%`. Title "MoM Growth Rate".
5. **Country bookmarks**, done 3 times, for Germany, Italy and Spain:
   1. `View → Bookmarks` and `View → Selection` to open both panes.
   2. Click the area chart. In the **Filters** pane → *Filters on this visual* → drag `DimBusinessLine[Country]`
      in → tick only **Germany**.
   3. With the area chart still selected: Bookmarks pane → **Add** → double-click the new bookmark → rename it
      `Germany`. Click its `⋯` → keep **Data** ticked → choose **Selected visuals**.
   4. Repeat for Italy and Spain. At the end, clear the country filter.
   5. `Insert → Buttons → Navigator → Bookmark navigator`. Place it left of the area chart.
   🔎 **Check:** **Ctrl+click** each bookmark button. The area chart switches country and the slicers don't change.
6. **Sync slicers:** `View → Sync slicers`. Click the Year slicer; in the pane, tick both the *sync* and
   *visible* columns for OVERVIEW and TIME INTEL (and SALES DETAILS once it exists). Repeat for Currency
   and Launch Year. Now one choice applies on every page.

### Step 2.7: SALES DETAILS page (45 min)
1. Duplicate TIME INTEL → rename it `SALES DETAILS`, delete its charts and the bookmark navigator, and change the title.
2. **Scatter chart** (top-left): Values `DimProduct[Product Name]`, X-axis `ASP`, Y-axis `TotalSales Qty`.
   Title "ASP and TotalSales Qty". Each dot is one product.
3. **Map** (top-right): Location `DimBusinessLine[Country]`, Legend `DimProduct[SubCategory]`, Bubble size
   `TotalSales`. Title "Total Sales by Region". (If it's blank, redo Step 1.2.4 and restart Power BI.)
4. **Clustered bar** (bottom-left): Y `Product Name`, X `TotalSales`. Filters → `Product Name` →
   **Top N**, Top **3**, by `TotalSales`. Title "Top 3 Products by Total Sales".
   🔎 **Check (2020, DKK):** P 84, P 186, P 94.
5. **Clustered bar** (bottom-right): the same, but **Bottom 3**. Also drag `TotalSales` into *Filters on this
   visual* → *is greater than* **0** → Apply. Otherwise you get products with no sales.

### Step 2.8: Tooltip page, cover, contact, check page (40 min)
1. **ProductTooltip:** new page (`+` at the bottom) → rename `ProductTooltip` → `Format page → Page information →
   Allow use as tooltip: On`; `Canvas settings → Type: Tooltip`. Add 4 cards: `TotalSales`,
   `TotalSales Qty`, `ASP`, and `DimProduct[SubCategory]` (click the field's dropdown in the well → **First**).
   Drag `DimProduct[Product Name]` into the page's **Tooltip** well (Visualizations pane, with no visual
   selected). Right-click the tab → **Hide page**.
   Then on SALES DETAILS: select the scatter → `Format visual → General → Tooltips → Type: Report page,
   Page: ProductTooltip`. 🔎 **Check:** hovering a dot shows the mini card.
2. **COVER:** new page, move it first (drag the tab). Big text box "YourFashion SALES REPORT", an image
   (`Insert → Image`), and a "GO →" button: `Insert → Buttons → Blank` → `Format → Action: On, Type: Page
   navigation, Destination: OVERVIEW`.
3. **CONTACT:** new page with your name, email and LinkedIn in a text box. Put your real details here.
4. **Check page:** new page with a table showing `TotalSales` and `Total Sales EUR`, plus the Year and
   Currency slicers. Set the currency to EUR: both columns must be equal. Then hide the page.
5. Select the page navigator on each page → `Format → Pages` → turn off ProductTooltip and the check page.

✅ **Day 2 checkpoint:** go through [README §8 Check your numbers](README.md#8-check-your-numbers) and
tick every line. **Ctrl+S**, then upload the `.pbix` again (`Case 3 Day 2: measures and pages`).

### If something goes wrong on Day 2

| Symptom | Cause | Fix |
|---|---|---|
| Every `TotalSales` visual is blank | Original measure with no single year or currency selected | Select one year and one currency, or use the improved measure |
| `TotalSales LY` / YoY% blank everywhere | `DimDate` not marked as a date table | Step 1.7.2 |
| YoY% is the same in DKK and SEK | `TotalSales LY` uses `[TotalSales DKK]` | It must use `[TotalSales]` |
| "A circular dependency was detected" | A calculated column refers to a measure | Measures go in `_Measures`, not as columns |
| Top N shows more than 3 bars | Ties (several products at 0) | Add the "TotalSales > 0" filter |
| Bookmark changes the slicers too | Bookmark saved with *All visuals* | `⋯` → *Selected visuals*, then right-click → *Update* |
| Map is blank or grey | Map visuals disabled, or no internet in the VM | Step 1.2.4; check the VM has network |

---

# Day 3: Insights, polish and publish (~4 h)

**Goal:** the report tells a story, looks professional, the public link works, and you can present it in 2 minutes.

### Step 3.1: Find the insights yourself (60 min)
Read [README §10 What the data says](README.md#10-what-the-data-says-the-story). For each finding,
reproduce the number **in your own report** or on the web version:

| Finding | Where to see it |
|---|---|
| 1. +9.4% includes a 53rd week | Web version: Weeks → *Comparable 52 weeks* (YoY drops to +6.5%). In Power BI: table with `DimCalendar_x[Year Week]` + `TotalSales DKK`, filtered to 2020 → week `53.2020` = 71.2M |
| 2. Peak moved earlier | "Total Sales by Time" chart: Nov 2020 high, Dec 2020 low. Web: weekly chart weeks 44–52 |
| 3. Charms flat, Bracelets/Dangles grew | Pie chart + a table of SubCategory × `TotalSales`, `Sales YoY%` |
| 4. Fast product turnover | Bar chart of `DimProduct[Launch Year]` × `TotalSales` for 2020 |
| 5. Concentration | Country column chart; Top 5 business line bar |

Then add a **text box** on OVERVIEW titled "Key insights" with 3 short bullets in your own words, e.g.
*"Charms are 67% of sales but flat; growth came from Bracelets (+41%)."*

### Step 3.2: Polish (60 min)
Go through this checklist on every page:
- [ ] **Titles state a finding**, not a label: "Australia and China make 62% of sales", not "Sales by Country".
- [ ] Same font everywhere; at most 3 sizes (title, visual title, labels).
- [ ] Visuals aligned: select several → `Format → Align → Align top` / `Distribute horizontally`.
- [ ] Equal gaps between visuals (about 12 px).
- [ ] One accent colour. Grey for context (e.g. last year's line).
- [ ] Data labels on the bar charts (`Format visual → Data labels: On`), no decimals on large numbers.
- [ ] No hidden broken visuals: `View → Selection` lists everything on the page; delete leftovers.
- [ ] A small footnote: "Data: YourFashion training dataset, amounts recorded in DKK, converted at yearly average rates."
- [ ] Open the COVER page, Ctrl+click GO, click through every page as if you're the manager.

### Step 3.3: Screenshots and GIF (30 min)
1. For each page: `View → Full screen` (or hide the panes), then **Win+Shift+S** → *Window* snip → save as
   `01_cover.png`, `02_overview.png`, `03_time_intel.png`, `04_sales_details.png`.
2. **GIF** (optional but impressive): use **ScreenToGif** (free, Microsoft Store) or on your Mac **Kap**.
   Record about 30 s: change the currency DKK → SEK → USD, click the country bookmarks, hover the scatter.
3. Upload them to GitHub: `powerbi_case3` → **Add file → Create new file** → type `screenshots/README.md`
   (this creates the folder) → commit; then open `screenshots/` → **Add file → Upload files** → drop the PNGs/GIF.
4. Final `.pbix` upload: `Case 3: final report`.

### Step 3.4: Publish the website (30 min)
1. On GitHub: **Pull requests → New pull request** → *base:* `main` ← *compare:*
   `claude/data-job-project-selection-q0yb37` → **Create pull request** → **Merge pull request** → **Confirm**.
2. **Settings** (repo top bar) → **Pages** (left menu) → *Source: Deploy from a branch* → Branch `main`,
   folder `/docs` → **Save**. On a free account the repo must be **public**:
   *Settings → General → Danger Zone → Change visibility*. Remove anything private first, e.g. meeting notes in `week1/`.
3. Wait 1–2 minutes, then open `https://jkazeyuki.github.io/DataProject/case3/`.
   🔎 **Check on your phone too:** filters work, charts show, there's no "Could not load data.json" message.
4. Edit `powerbi_case3/README.md` on GitHub (pencil icon) and add your screenshots at the top:
   `![Overview](screenshots/02_overview.png)`.

### Step 3.5: Resume and LinkedIn (30 min)
1. Copy the resume bullet from [README §11](README.md#11-publish-the-link-for-your-resume) into your resume under
   **Projects**. Make the title a hyperlink to the live page.
2. Skills line: *Power BI (Power Query, DAX, data modelling), Excel, SQL, Python*.
3. Optional LinkedIn post: one screenshot plus 3 sentences: problem → what you built → the 53-week insight → link.

### Step 3.6: Practise the walkthrough (30 min)
1. Read the [2-minute script](README.md#12-your-2-minute-interview-walkthrough) out loud twice.
2. Record yourself (phone or Zoom) presenting with the live link open. Watch it back. Cut anything over 2 minutes.
3. Prepare answers to these likely questions:
   - *"Why a star schema?"* Filters flow one way from small dimension tables to one big fact table. It's
     simpler, faster and makes DAX predictable.
   - *"Why is the currency a measure and not a column?"* The rate depends on what the user selects (currency
     and year). A column is computed once at load time; a measure is computed for every filter combination.
   - *"What does CALCULATE do?"* It evaluates an expression under a changed filter, e.g.
     `DATEADD(...,-1,YEAR)` shifts the dates back a year.
   - *"What data issues did you find?"* Pick 3 from [README §9](README.md#9-data-audit-what-to-say-you-found).
   - *"What would you do next?"* Ask for daily data and real dates instead of ISO weeks, a currency table
     with monthly rates, and margin/cost data to analyse profitability, not just sales.

✅ **Day 3 checkpoint:** the live link opens on your phone, the screenshots are in the repo, the resume
has the link, and you can present the report in under 2 minutes without notes.
