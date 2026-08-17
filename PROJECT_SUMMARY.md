# Project Summary

## Question
How accurately can Texas sales-tax receipts be forecast using univariate time-series models, and how do those forecasts compare with both a macroeconomic VAR model and the Texas Comptroller's fiscal-year projections?

## Workflow
1. Inspect trend, seasonality, cycles, and sales-tax-holiday anomalies.
2. Apply the class-provided holiday-adjustment procedure.
3. Hold out September 2024 through February 2025.
4. Fit and diagnose ETS and ARIMA models.
5. Compare six-month forecast accuracy.
6. Select ETS(M,A,A) as the preferred univariate model.
7. Refit to the full adjusted series and forecast 30 months through August 2027.
8. Aggregate the path forecast to fiscal-year totals and compare with the Biennial Revenue Estimate.
9. Extend the analysis with Texas employment and CPI in a VAR(5) model after stationarity testing and lag selection.
