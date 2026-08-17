library(tidyverse)
library(tseries)
library(forecast)

# You will need to set the working directory for your system
setwd("~/cts1/TEACH/MA_Forecasting/S25/Term Project")

tax.dat <- readxl::read_excel("Texas Tax Revenue.xlsx", sheet = "Sales Tax")
sales <- ts(tax.dat[, "Sales Tax"], frequency=12, start=c(2003, 9))

xdat <- ts(matrix(0, nrow=258, ncol=7), frequency = 12, start=c(2003,9))
xdat[181,1] <- 1
xdat[192,2] <- 1
xdat[204,3] <- 1
xdat[216,4] <- 1
xdat[226,5] <- 1
xdat[237,6] <- 1
xdat[249,7] <- 1

(tr_fit <- tslm(sales ~ trend + xdat, lambda=0))
holiday <- xdat[,1]*tr_fit$coefficients[3] +
  xdat[,2]*tr_fit$coefficients[4] +
  xdat[,3]*tr_fit$coefficients[5] +
  xdat[,4]*tr_fit$coefficients[6] +
  xdat[,5]*tr_fit$coefficients[7] +
  xdat[,6]*tr_fit$coefficients[8] +
  xdat[,7]*tr_fit$coefficients[9] 
sales_adj <- exp(log(sales) - holiday)

