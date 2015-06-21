## ----libraryLoad, echo=FALSE, warning=FALSE, results='hide', message=FALSE----
# require(stringr)
# require(DiagrammeR)
require(slidify)
require(knitr)
require(ggplot2)
# require(grid)
# require(gridExtra)
# require(gtable)
require(lubridate)
library(dplyr)
# library(Cairo)
library(animation)
library(htmlwidgets)
ani.options(interval=.6)

## ----fvMoney, echo=FALSE, cache=FALSE, warning=FALSE, message=FALSE, fig.height=5, fig.width=12, fig.cap="Time Value of Money"----
aprAnn = 0.0125 #https://www.mysavingsdirect.com/MySavingsDirectWeb/en/common/information/LearnMore.jsp
aprDay = aprAnn / yday(mdy("12/31/2015"))
aprMnth = aprAnn / 12
aprQtr = aprAnn / 4

finGrowthTblMnth <- tbl_df(as.data.frame( ymd_hms("2015-01-01 16:00:00", tz = "America/New_York") + months(1:120) - days(1) ))
names(finGrowthTblMnth) <- "dateClose"
finGrowthTblMnth <- finGrowthTblMnth%>%
    dplyr::mutate(
        ydayNum = yday(dateClose),
        month = month(dateClose),
        years = as.period( (dateClose - ymd_hms("2015-01-02 16:00:00", tz = "America/New_York") ) ) %/% months(12),
        quarters = as.period( (dateClose - ymd_hms("2015-01-02 16:00:00", tz = "America/New_York") ) ) %/% months(3),
        months = as.period( (dateClose - ymd_hms("2015-01-02 16:00:00", tz = "America/New_York") ) ) %/% months(1),
        days = as.period( (dateClose - ymd_hms("2015-01-02 16:00:00", tz = "America/New_York") ) ) %/% days(1),
        Savings = (532.60 * (1 + aprDay)**(days)),
        Contin = (532.60 * exp( aprDay * days) ),
        Mnthly = (532.60 * (1 + aprMnth)**(months)),
        Qtrly = (532.60 * (1 + aprQtr)**(quarters)),
        Annul = (532.60 * (1 + aprAnn)**(years))
        )

# mnyPlt2 <- ggplot() + scale_colour_hue("Compound_Rate")
# mnyPlt2 <- mnyPlt2 + geom_line(data=finGrowthTblMnth, aes(x = dateClose, y = Contin, color = "1_Contin"))
# mnyPlt2 <- mnyPlt2 + geom_line(data=finGrowthTblMnth, aes(x = dateClose, y = Savings, color = "2_Daily"))
# mnyPlt2 <- mnyPlt2 + geom_line(data=finGrowthTblMnth, aes(x = dateClose, y = Mnthly, color = "3_Mnthly"))
# mnyPlt2 <- mnyPlt2 + geom_line(data=finGrowthTblMnth, aes(x = dateClose, y = Qtrly, color = "4_Qtrly"))
# mnyPlt2 <- mnyPlt2 + geom_line(data=finGrowthTblMnth, aes(x = dateClose, y = Annul, color = "5_Annul"))
# mnyPlt2 <- mnyPlt2 + labs(x = "Date", y = "Amount [$]", title = "Money:  Time Value", legend = "Compounding")
# mnyPlt2

## ----stockPricingPrep, echo=FALSE, message=FALSE, warning=FALSE, cache=FALSE----
################################################################################
##
## This section is for comparing Google Stock Price with Wiener Pricing of Stock
##  For comparison, bank savings is shown.  Import Google price history. 
##
mu <- (547.47 - 532.60) / 532.60 # ~0.15 annualized rate of return from
# https://www.stock-analysis-on.net/NASDAQ/Company/Google-Inc/Valuation/Ratios
mu_daily <- mu / 112

finGrowthTbl <- tbl_df(
    read.csv2("googl.csv", sep = ",", stringsAsFactors = FALSE, na.strings = "NA",
              header = TRUE, #colClasses = c("character", "numeric", "numeric", "numeric", "numeric", "numeric")
              )
    )   %>%
    select(
        Date, Open, High, Low, Close, Volume
        ) %>%
    mutate(
        dateClose = ymd_hms( paste( dmy(Date), hms(c("16:00:00") )), tz = "America/New_York"),
        Open = as.numeric(Open), High = as.numeric(High), Low = as.numeric(Low), Close = as.numeric(Close),
        Volume = as.numeric(Volume)
        ) %>%
    select(
        dateClose,
        Date, Open, High, Low, Close, Volume      
        )  %>%
    filter(
        dateClose > mdy("01/01/2015") & dateClose < mdy("06/30/2015")
        ) %>%
    mutate(
        ydayNum = yday(dateClose),
        days = as.period( (dateClose - ymd_hms("2015-01-02 16:00:00", tz = "America/New_York") ) ) %/% days(1)        
        )%>%
    arrange(ydayNum)%>%
    mutate(
        Savings = (532.60 * (1 + aprDay)**(days)),
        Contin = (532.60 * exp( aprDay * days) ),
        goog_W = 0,
        goog_H = (532.60 * exp( mu_daily * days) )
        )%>%
    select(
        dateClose, days,
        Open, High, Low, Close, goog_W, goog_H, Savings
        )
##
################################################################################
##
## This section for determining volatility in Google Stock between 2015-01-02
##  and 2015-06-12, which is 112 trading days and estimate Stock price with Wiener model
##
sd_googl <- sd(finGrowthTbl$Close) # for 112 trading days
sd_googlDly <-  sd_googl / 112

goog_W <- vector("numeric", length = 112)
goog_W[1] <- 532.60

## ----stockPricing, echo=TRUE, message=TRUE, warning=TRUE, error=TRUE, cache=FALSE----
## This code chunk demonstrates pricing Google Stock assuming a Wiener process.
for(j in 1:30) {
    for(i in 2:112) {
        #     set.seed(314159)
        goog_W[i] <- goog_W[i-1] * (1 + mu_daily * (1/365) + sd_googlDly * rnorm(1) * sqrt(1/365)) 
        }
    }
print(paste('On 12 June 2015, the simulated closing price of Google Stock is $', round(goog_W[112],2)))

## ----stockPricingAnimating, echo=FALSE, message=FALSE, warning=FALSE, cache=TRUE, fig.height=5, fig.width=12, fig.show='animate'----
################################################################################
##
## This section is for comparing Google Stock Price with Wiener Pricing of Stock
##  For comparison, bank savings is shown.  Import Google price history. 
##
for(j in 1:30) {
    for(i in 2:112) {
        #     set.seed(314159)
        goog_W[i] <- goog_W[i-1] * (1 + mu_daily * (1/365) + sd_googlDly * rnorm(1) * sqrt(1/365)) 
        }
    finGrowthTbl$goog_W <- goog_W
    
    mnyPlt <- ggplot() + scale_colour_hue("Instrument") + scale_y_continuous(limits = c(450, 650))
    mnyPlt <- mnyPlt + geom_line(data=finGrowthTbl, aes(x = dateClose, y = Close, color="GOOGL"))
    mnyPlt <- mnyPlt + geom_line(data=finGrowthTbl, aes(x = dateClose, y = goog_H, color = "goog_H"))
    mnyPlt <- mnyPlt + geom_line(data=finGrowthTbl, aes(x = dateClose, y = Savings, color = "Savings"))
    mnyPlt <- mnyPlt + labs(x = "Date", y = "Amount [$]", title = "Money:  Time Value")
    mnyPlt <- mnyPlt + geom_line(data=finGrowthTbl, aes(x = dateClose, y = goog_W, color="goog_W"))
    print(mnyPlt)
    }

