# Methodology

## Sales-tax adjustment
The class supplied R code constructs seven event indicators for large annual sales-tax drops and estimates a trend regression on the log scale. The estimated event effects are removed to create `sales_adj`.

## Holdout design
Training sample ends August 2024. The final six observations, September 2024-February 2025, are used as the test set.

## Univariate models
The submitted report identifies the preferred models as ETS(M,A,A) and ARIMA(1,1,3)(0,0,2)[12] with drift. Residual diagnostics and out-of-sample accuracy are compared, including RMSE, MAE, MAPE, ACF1, and Theil's U.

## Long-horizon forecast
The preferred ETS model is refit to the full adjusted series and used to generate monthly forecasts from March 2025 through August 2027.

## VAR extension
The submitted code uses Texas employment (`TXNA`) and CPI (`CPIAUCSL`). Log levels are tested with ADF tests, then first differences are used. `VARselect()` is used for lag guidance; the final report states that VAR(5) was selected because residual diagnostics improved relative to the BIC-favored lag of 2.
