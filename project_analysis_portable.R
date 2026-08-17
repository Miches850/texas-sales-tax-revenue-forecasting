# Texas Sales Tax Revenue Forecasting - portable GitHub version
# ECMT 674, Group 17: Carson Fenwick, Mia Clay, Xuesong Dai, Michael Shannon
#
# This file converts the submitted code appendix into repository-relative paths.
# It does not invent the missing TXNA/CPI source workbooks. The univariate
# section runs from the included Texas Tax Revenue workbook. The VAR section
# runs only if those two external source files are later restored under data/external/.

required <- c("readxl", "tidyverse", "forecast", "ggfortify", "ggplot2", "urca", "vars")
missing <- required[!vapply(required, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
if (length(missing) > 0) {
  stop("Install required packages before running: ", paste(missing, collapse = ", "))
}

library(readxl)
library(tidyverse)
library(forecast)
library(ggfortify)
library(ggplot2)

# -----------------------------------------------------------------------------
# 1. Load and adjust Texas sales-tax receipts
# Instructor-provided adjustment logic is also preserved separately in
# code/instructor_supplied/Sales_Tax_Adjust.R.
# -----------------------------------------------------------------------------
sales_data <- readxl::read_excel("data/Texas_Tax_Revenue.xlsx", sheet = "Sales Tax")
sales <- ts(sales_data[["Sales Tax"]], frequency = 12, start = c(2003, 9))

xdat <- ts(matrix(0, nrow = 258, ncol = 7), frequency = 12, start = c(2003, 9))
xdat[181,1] <- 1; xdat[192,2] <- 1; xdat[204,3] <- 1; xdat[216,4] <- 1
xdat[226,5] <- 1; xdat[237,6] <- 1; xdat[249,7] <- 1
tr_fit <- tslm(sales ~ trend + xdat, lambda = 0)
holiday <- xdat[,1]*tr_fit$coefficients[3] + xdat[,2]*tr_fit$coefficients[4] +
  xdat[,3]*tr_fit$coefficients[5] + xdat[,4]*tr_fit$coefficients[6] +
  xdat[,5]*tr_fit$coefficients[7] + xdat[,6]*tr_fit$coefficients[8] +
  xdat[,7]*tr_fit$coefficients[9]
sales_adj <- exp(log(sales) - holiday)

# -----------------------------------------------------------------------------
# 2. Six-month holdout: ETS vs ARIMA
# -----------------------------------------------------------------------------
train_data <- window(sales_adj, end = c(2024, 8))
test_data <- window(sales_adj, start = c(2024, 9))
ets_model <- ets(train_data)
arima_model <- auto.arima(train_data)
ets_forecast <- forecast(ets_model, h = 6)
arima_forecast <- forecast(arima_model, h = 6)

print(data.frame(Model="ETS", Forecast=as.numeric(ets_forecast$mean), Actual=as.numeric(test_data)))
print(data.frame(Model="ARIMA", Forecast=as.numeric(arima_forecast$mean), Actual=as.numeric(test_data)))
print(accuracy(ets_forecast, test_data))
print(accuracy(arima_forecast, test_data))

# Preferred model in submitted report: ETS(M,A,A)
final_ets_model <- ets(sales_adj)
ets_forecast_30 <- forecast(final_ets_model, h = 30)
print(ets_forecast_30$mean)

# -----------------------------------------------------------------------------
# 3. VAR(5) extension - optional until original external workbooks are restored
# -----------------------------------------------------------------------------
employment_path <- "data/external/TXNA.xlsx"
cpi_path <- "data/external/CPIAUCSL.xlsx"

if (file.exists(employment_path) && file.exists(cpi_path)) {
  library(urca)
  library(vars)
  employment_data <- readxl::read_excel(employment_path, sheet = "Monthly")
  cpi_data <- readxl::read_excel(cpi_path, sheet = "Monthly")
  employment_ts <- ts(employment_data$TXNA, start = c(1990,1), frequency = 12)
  cpi_ts <- ts(cpi_data$CPIAUCSL, start = c(1947,1), frequency = 12)

  sales_tax <- window(sales_adj, start = c(2010,1), end = c(2025,2))
  employment <- window(employment_ts, start = c(2010,1), end = c(2025,2))
  cpi <- window(cpi_ts, start = c(2010,1), end = c(2025,2))

  log_sales_tax <- log(sales_tax); log_employment <- log(employment); log_cpi <- log(cpi)
  diff_sales_tax <- diff(log_sales_tax); diff_employment <- diff(log_employment); diff_cpi <- diff(log_cpi)
  var_data <- cbind(diff_sales_tax, diff_employment, diff_cpi)
  colnames(var_data) <- c("SalesTax", "Employment", "CPI")
  print(VARselect(var_data, lag.max = 12, type = "const")$selection)
  var_model <- VAR(var_data, p = 5, type = "const")
  print(serial.test(var_model, lags.pt = 12, type = "PT.asymptotic"))
  var_pred <- predict(var_model, n.ahead = 30, ci = 0.95)
  f_sales <- var_pred$fcst$SalesTax
  f_sales_lev <- ts(0, frequency=12, start=c(2025,3), end=c(2027,8))
  f_sales_lower <- f_sales_upper <- f_sales_lev
  lag_sales <- log_sales_tax[length(log_sales_tax)]
  for (j in 1:30) {
    f_sales_lev[j] <- exp(f_sales[j,1] + lag_sales)
    f_sales_lower[j] <- exp(f_sales[j,2] + lag_sales)
    f_sales_upper[j] <- exp(f_sales[j,3] + lag_sales)
    lag_sales <- log(f_sales_lev[j])
  }
  print(data.frame(
    Month=seq(as.Date("2025-03-01"), by="month", length.out=30),
    Forecast=round(as.numeric(f_sales_lev),2),
    Lower_95=round(as.numeric(f_sales_lower),2),
    Upper_95=round(as.numeric(f_sales_upper),2)
  ))
} else {
  message("VAR section skipped: restore data/external/TXNA.xlsx and CPIAUCSL.xlsx to rerun it.")
}
