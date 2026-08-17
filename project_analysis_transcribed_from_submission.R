# ECMT 674 Term Project - Group 17
# Code transcribed from the submitted code appendix PDF.
# Group 17: Carson Fenwick, Mia Clay, Xuesong Dai, Michael Shannon
#
# NOTE: The code appendix itself included instructor-supplied holiday-adjustment
# logic. The standalone instructor file is preserved separately under
# code/instructor_supplied/Sales_Tax_Adjust.R.

library(readxl)
library(tidyverse)
library(forecast)
library(ggfortify)
library(ggplot2)
library(tsibble)
library(lubridate)

sales_data <- readxl::read_excel(
  "C:/Users/dai/OneDrive/Desktop/Texas Tax Revenue.xlsx",
  sheet = "Sales Tax"
)
head(sales_data)
colnames(sales_data)

# 1. Sales-tax adjustment
sales <- ts(sales_data[["Sales Tax"]], frequency = 12, start = c(2003, 9))
head(sales)

xdat <- ts(matrix(0, nrow = 258, ncol = 7), frequency = 12, start = c(2003, 9))
xdat[181,1] <- 1
xdat[192,2] <- 1
xdat[204,3] <- 1
xdat[216,4] <- 1
xdat[226,5] <- 1
xdat[237,6] <- 1
xdat[249,7] <- 1

tr_fit <- tslm(sales ~ trend + xdat, lambda = 0)
summary(tr_fit)

holiday <- xdat[,1]*tr_fit$coefficients[3] +
  xdat[,2]*tr_fit$coefficients[4] +
  xdat[,3]*tr_fit$coefficients[5] +
  xdat[,4]*tr_fit$coefficients[6] +
  xdat[,5]*tr_fit$coefficients[7] +
  xdat[,6]*tr_fit$coefficients[8] +
  xdat[,7]*tr_fit$coefficients[9]

sales_adj <- exp(log(sales) - holiday)

plot(sales, main = "Original Sales Tax", col = "blue")
lines(sales_adj, col = "red")
legend("topleft", legend = c("Original", "Adjusted"), col = c("blue", "red"), lty = 1)
plot(sales_adj)

# 2. Univariate models
train_data <- window(sales_adj, end = c(2024, 8))
test_data <- window(sales_adj, start = c(2024, 9))

ets_model <- ets(train_data)
summary(ets_model)
checkresiduals(ets_model)

arima_model <- auto.arima(train_data)
summary(arima_model)
checkresiduals(arima_model)

ets_forecast <- forecast(ets_model, h = 6)
autoplot(ets_forecast) + autolayer(test_data, series = "Actual")
data.frame(Forecast = ets_forecast$mean, Actual = test_data)

arima_forecast <- forecast(arima_model, h = 6)
autoplot(arima_forecast) + autolayer(test_data, series = "Actual")
data.frame(Forecast = arima_forecast$mean, Actual = test_data)

accuracy(ets_forecast, test_data)
accuracy(arima_forecast, test_data)

final_ets_model <- ets(sales_adj)
summary(final_ets_model)
ets_forecast_30 <- forecast(final_ets_model, h = 30)
autoplot(ets_forecast_30) + autolayer(sales_adj, series = "Actual")
ets_forecast_30$mean

# 3. VAR model
employment_data <- readxl::read_excel(
  "C:/Users/dai/OneDrive/Desktop/TXNA.xlsx",
  sheet = "Monthly"
)
cpi_data <- readxl::read_excel(
  "C:/Users/dai/OneDrive/Desktop/CPIAUCSL.xlsx",
  sheet = "Monthly"
)

employment_ts <- ts(employment_data$TXNA, start = c(1990,1), frequency = 12)
cpi_ts <- ts(cpi_data$CPIAUCSL, start = c(1947,1), frequency = 12)

start_year <- 2010
start_month <- 1
end_year <- 2025
end_month <- 2

sales_tax <- window(sales_adj, start = c(start_year, start_month), end = c(end_year, end_month))
employment <- window(employment_ts, start = c(start_year, start_month), end = c(end_year, end_month))
cpi <- window(cpi_ts, start = c(start_year, start_month), end = c(end_year, end_month))

log_sales_tax <- log(sales_tax)
log_employment <- log(employment)
log_cpi <- log(cpi)

library(urca)
adf_sales_tax <- ur.df(log_sales_tax, type = "drift")
summary(adf_sales_tax)
adf_employment <- ur.df(log_employment, type = "drift")
summary(adf_employment)
adf_cpi <- ur.df(log_cpi, type = "drift")
summary(adf_cpi)

diff_sales_tax <- diff(log_sales_tax)
diff_employment <- diff(log_employment)
diff_cpi <- diff(log_cpi)
summary(ur.df(diff_sales_tax, type = "drift"))
summary(ur.df(diff_employment, type = "drift"))
summary(ur.df(diff_cpi, type = "drift"))

var_data <- cbind(diff_sales_tax, diff_employment, diff_cpi)
colnames(var_data) <- c("SalesTax", "Employment", "CPI")

library(vars)
lag_selection <- VARselect(var_data, lag.max = 12, type = "const")
lag_selection$selection

var_model <- VAR(var_data, p = 5, type = "const")
serial.test(var_model, lags.pt = 12, type = "PT.asymptotic")
var_pred <- predict(var_model, n.ahead = 30, ci = 0.95)

f_sales <- var_pred$fcst$SalesTax
f_sales_lev <- ts(0, frequency = 12, start = c(2025,3), end = c(2027,8))
f_sales_lower <- ts(0, frequency = 12, start = c(2025,3), end = c(2027,8))
f_sales_upper <- ts(0, frequency = 12, start = c(2025,3), end = c(2027,8))

lag_sales <- log_sales_tax[length(log_sales_tax)]
for (j in 1:30) {
  f_sales_lev[j] <- exp(f_sales[j,1] + lag_sales)
  f_sales_lower[j] <- exp(f_sales[j,2] + lag_sales)
  f_sales_upper[j] <- exp(f_sales[j,3] + lag_sales)
  lag_sales <- log(f_sales_lev[j])
}

autoplot(window(sales_adj, start = c(2020,1))) +
  autolayer(f_sales_lev, series = "VAR Forecast", color = "red") +
  autolayer(f_sales_lower, linetype = "dashed", series = "Lower CI") +
  autolayer(f_sales_upper, linetype = "dashed", series = "Upper CI") +
  ggtitle("Texas Sales Tax Forecast from VAR(5) Model") +
  ylab("Sales Tax")

sales_forecast_table <- data.frame(
  Month = seq(as.Date("2025-03-01"), by = "month", length.out = 30),
  Forecast = round(as.numeric(f_sales_lev), 2),
  Lower_95 = round(as.numeric(f_sales_lower), 2),
  Upper_95 = round(as.numeric(f_sales_upper), 2)
)
print(sales_forecast_table)
