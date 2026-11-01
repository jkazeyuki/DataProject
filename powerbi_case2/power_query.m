// ============================================================
// Power Query (M) for Case 2 — paste into Home → Transform data →
// New Source → Blank Query → Advanced Editor.
// Change DataRoot to the folder that holds "Data Sources" on your PC.
// ============================================================

// ---------- Query: DataRoot (parameter-style text query) ----------
// "C:\Users\<you>\Documents\Modelling and DAX\Data Sources\" meta [IsParameterQuery = true, Type = "Text", IsParameterQueryRequired = true]


// ---------- Query: FactSales ----------
let
    Source = Folder.Files(DataRoot & "Facts"),
    // Only the market files in Facts\ (Other\ holds a duplicate of Sing_Sales.xlsx)
    Excel = Table.SelectRows(Source, each [Extension] = ".xlsx" and not Text.StartsWith([Name], "~$")),
    // City key = file-name prefix: "NY_Results.xlsx" -> "NY"
    WithCity = Table.AddColumn(Excel, "IDCity", each Text.BeforeDelimiter([Name], "_"), type text),
    WithData = Table.AddColumn(WithCity, "Data",
        each Table.PromoteHeaders(Excel.Workbook([Content], null, true){[Item = "Data", Kind = "Sheet"]}[Data], [PromoteAllScalars = true])),
    Keep = Table.SelectColumns(WithData, {"IDCity", "Data"}),
    Expanded = Table.ExpandTableColumn(Keep, "Data",
        {"Product ID", "Order Date", "Payment Date", "Quantity", "Sales Amount"}),
    // London has 366 completely blank rows
    NoBlanks = Table.SelectRows(Expanded, each [Product ID] <> null and [Product ID] <> ""),
    Typed = Table.TransformColumnTypes(NoBlanks, {
        {"Product ID", type text}, {"Order Date", type date}, {"Payment Date", type date},
        {"Quantity", Int64.Type}, {"Sales Amount", Currency.Type}})
in
    Typed


// ---------- Query: DimProducts ----------
let
    Source = Excel.Workbook(File.Contents(DataRoot & "Dim\Dim.xlsx"), null, true),
    Sheet = Source{[Item = "Products", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Sheet, [PromoteAllScalars = true]),
    Typed = Table.TransformColumnTypes(Headers, {
        {"Code", type text}, {"Product Name", type text}, {"Product Category", type text}, {"List Price", Currency.Type}})
in
    Typed


// ---------- Query: DimGeo ----------
let
    Source = Excel.Workbook(File.Contents(DataRoot & "Dim\Dim.xlsx"), null, true),
    Sheet = Source{[Item = "Geo", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Sheet, [PromoteAllScalars = true]),
    Typed = Table.TransformColumnTypes(Headers, {
        {"IDCity", type text}, {"City", type text}, {"Country", type text},
        {"Sub Continent", type text}, {"Continent", type text}, {"Flag", type text}})
    // In Data view: select Flag → Column tools → Data category = Image URL
in
    Typed


// ---------- Query: DimCalendar ----------
// The Excel calendar covers 2016-01-01 → 2017-12-31, but 143 orders are paid
// in Jan–Feb 2018. Append the missing dates so Sales by Payment Date is complete.
let
    Source = Excel.Workbook(File.Contents(DataRoot & "Dim\Dim.xlsx"), null, true),
    Sheet = Source{[Item = "Calendar", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Sheet, [PromoteAllScalars = true]),
    Typed = Table.TransformColumnTypes(Headers, {{"Dates", type date}}),
    Extra = Table.FromList(List.Dates(#date(2018, 1, 1), 59, #duration(1, 0, 0, 0)), Splitter.SplitByNothing(), {"Dates"}),
    ExtraCols = Table.AddColumn(
        Table.AddColumn(
            Table.AddColumn(
                Table.AddColumn(
                    Table.AddColumn(
                        Table.AddColumn(Table.TransformColumnTypes(Extra, {{"Dates", type date}}),
                            "Year", each Date.Year([Dates])),
                        "Month Num", each Date.Month([Dates])),
                    "Month Name", each Date.MonthName([Dates], "en-US")),
                "Month Yr", each Date.MonthName([Dates], "en-US") & " " & Text.From(Date.Year([Dates]))),
            "Quarter", each Date.QuarterOfYear([Dates])),
        "MonthYearNum", each Date.Year([Dates]) * 100 + Date.Month([Dates])),
    Combined = Table.Combine({Typed, ExtraCols}),
    Final = Table.TransformColumnTypes(Combined, {
        {"Year", Int64.Type}, {"Month Num", Int64.Type}, {"Month Name", type text},
        {"Month Yr", type text}, {"Quarter", Int64.Type}, {"MonthYearNum", Int64.Type}})
in
    Final


// ---------- Query: Indicator ----------
let
    Source = Excel.Workbook(File.Contents(DataRoot & "Dim\Dim.xlsx"), null, true),
    Sheet = Source{[Item = "Indicator", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Sheet, [PromoteAllScalars = true]),
    Typed = Table.TransformColumnTypes(Headers, {{"ID", Int64.Type}, {"IndicatorName", type text}})
in
    Typed
