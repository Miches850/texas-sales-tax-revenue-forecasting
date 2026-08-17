# Texas Sales Tax Revenue Forecasting

**ECMT 674 - Economic Forecasting | Spring 2025**  
**Group 17:** Carson Fenwick, Mia Clay, Xuesong Dai, Michael Shannon

**Tools:** R, RStudio, Excel  
**Methods:** anomaly adjustment, ETS, seasonal ARIMA, six-month holdout validation, residual diagnostics, 30-month path forecasting, fiscal-year aggregation, benchmark comparison, ADF testing, VAR lag selection, and VAR(5) forecasting.

## Project objective

Develop forecasting models for Texas state sales-tax receipts and compare model-generated fiscal-year projections with the Texas Comptroller's Biennial Revenue Estimate.

The project uses monthly Texas sales-tax receipts from September 2003 through February 2025. The submitted analysis first adjusts large annual sales-tax-holiday drops, compares ETS and ARIMA models using a six-month holdout period, selects a preferred univariate model, produces a 30-month forecast through August 2027, and extends the analysis with a VAR model using Texas employment and CPI.

## Main reported findings

The submitted report selected **ETS(M,A,A)** over **ARIMA(1,1,3)(0,0,2)[12] with drift** based on the six-month test set. The reported ETS test-set RMSE was about **157,681**, versus about **211,554** for ARIMA; reported MAPE was **3.80%** for ETS versus **4.41%** for ARIMA.

The 30-month ETS forecast was aggregated into fiscal-year totals and compared with the Comptroller benchmark. The report concluded that ETS was relatively conservative and stable, while the VAR(5) model produced higher long-run projections and greater uncertainty.

### Reported fiscal-year forecasts (thousands of dollars)

| Fiscal year | Comptroller BRE | ETS forecast | VAR(5) forecast |
|---|---:|---:|---:|
| 2025 | 43,977,083 | 46,526,027 | 47,553,688 |
| 2026 | 46,211,370 | 47,506,131 | 50,687,852 |
| 2027 | 48,026,569 | 48,798,016 | 53,891,427 |

## Selected figures

### Original Texas sales-tax receipts
![Texas sales tax receipts](figures/01_texas_sales_tax_receipts.png)

### ETS residual diagnostics
![ETS residual diagnostics](figures/04_ets_residual_diagnostics.png)

### 30-month ETS forecast
![ETS 30-month forecast](figures/09_ets_30_month_forecast.png)

### VAR(5) forecast
![VAR5 forecast](figures/11_var5_30_month_forecast.png)

## Repository structure

```text
1_texas-sales-tax-revenue-forecasting/
├── README.md
├── requirements-r.txt
├── LICENSE_NOTICE.md
├── code/
│   ├── project_analysis_transcribed_from_submission.R
│   ├── project_analysis_portable.R
│   └── instructor_supplied/
│       └── Sales_Tax_Adjust.R
├── data/
│   ├── Texas_Tax_Revenue.xlsx
│   ├── README.md
│   └── reference/
│       ├── all_funds_historical.xlsx
│       └── general_fund_historical.xlsx
├── figures/
├── outputs/
│   └── reported_results/
├── report/
│   ├── ECMT_674_Term_Project_Group_17.pdf
│   └── ECMT_674_Term_Project_Code_Appendix.pdf
└── docs/
    ├── PROJECT_SUMMARY.md
    ├── METHODOLOGY.md
    ├── DATA_SOURCES.md
    ├── REPRODUCIBILITY_NOTES.md
    ├── GITHUB_UPLOAD_GUIDE.md
    └── ECMT_674_Term_Project_Assignment.pdf
```

## Code provenance

The class assignment supplied the sales-tax holiday-adjustment code. That original file is preserved under `code/instructor_supplied/` and is explicitly separated from the Group 17 analysis.

The original Group 17 `.R` file was not available in the retained project files. `project_analysis_transcribed_from_submission.R` was reconstructed from the code appendix that was submitted with the project. `project_analysis_portable.R` changes file paths and makes the missing external VAR inputs optional; it should not be described as the original submitted script.

## Reproducibility status

The univariate ETS/ARIMA portion can be reconstructed from the included Texas tax workbook and the submitted code appendix. The VAR(5) section is **documented but not currently fully reproducible** because the original `TXNA.xlsx` and `CPIAUCSL.xlsx` workbooks were not retained.

See `docs/REPRODUCIBILITY_NOTES.md` for the final correction items.

## Data source and benchmark

The course assignment identifies the Texas Comptroller's Office as the source of the Texas revenue data and directs students to the Comptroller's revenue-watch/Biennial Revenue Estimate materials for the benchmark forecasts.

## Portfolio note

This repository documents a graduate group forecasting project. It is presented as evidence of applied forecasting, model validation, time-series analysis, and fiscal-data interpretation; it is not professional forecasting work performed for the State of Texas.
