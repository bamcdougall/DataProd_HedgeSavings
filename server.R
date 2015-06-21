################################################################################
##
##  Author:  Brendan McDougall
##  Proj Purpose: Project 1 of Developing Data Products / Johns Hopkins Univ
##  File Purpose: R-script for client server of Shiny Application
##                  Compare return of Hedge Fund with arbritrary return and std
##                  deviation to Google Stock and Savings Account
##  MOOC:  Coursera
##  Course ID:  devdataprod-015
##  Date:  6/17/15
##
################################################################################
##
##  System Info:  Windows 7, 64 bit, i7 processor, RStudio Version 0.98.1102
##                  R x64 3.1.2, git scm 1.9.5
##
################################################################################
##
## Revision History
##
##      6/17/15: assembling elements of R-script
##      6/20/15: application running on local computer, but failing to upload
##                  no product documentation provided by RStudio regarding
##                  error msgs reported by deployApp() nor on msg boards.
##                  Other demo end-users are reporting same fault, but no
##                  solution available.
##      
################################################################################
##
##  Methdology:
##  (1) Load sufficient libraries for app deployment;
##  (2) Prepare user interface;
##  (3) Execute client / server interations for user
##      
##
################################################################################
##
## Part (1):  Load sufficient R libraries
##
library(shiny)
library(dplyr); library(ggplot2); library(lubridate); library(DT)
##
################################################################################
##
## Part (2a):  Read data from file; build stochastic stock pricing model;
##              Generate exploratory plot;
##
aprAnn = 0.0125 #https://www.mysavingsdirect.com/MySavingsDirectWeb/en/common/information/LearnMore.jsp
aprDay = aprAnn / yday(mdy("12/31/2015"))
aprMnth = aprAnn / 12
aprQtr = aprAnn / 4
mu <- (547.47 - 532.60) / 532.60 # ~0.15 annualized rate of return from
# https://www.stock-analysis-on.net/NASDAQ/Company/Google-Inc/Valuation/Ratios
mu_daily <- mu / 112

finGrowthTbl <- tbl_df(
    read.csv2(".//www//googl.csv", sep = ",", stringsAsFactors = FALSE, na.strings = "NA",
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
##  and 2015-06-12, which is 112 trading days and estimate Stock price using
##  Wiener process
##
sd_googl <- sd(finGrowthTbl$Close) # for 112 trading days
sd_googlDly <-  sd_googl / 112
##
goog_W <- vector("numeric", length = 112)
goog_W[1] <- 532.60
##
for(i in 2:112) {
    #     set.seed(314159)
    goog_W[i] <- goog_W[i-1] * (1 + mu_daily * (1/365) + sd_googlDly * rnorm(1) * sqrt(1/365)) 
}
finGrowthTbl$goog_W <- goog_W

mnyPlt <- ggplot() + scale_colour_hue("Instrument") # + scale_y_continuous(limits = c(450, 650))
mnyPlt <- mnyPlt + labs(x = "Date", y = "Amount [$]", title = "Money:  Time Value")
mnyPlt <- mnyPlt + geom_line(data=finGrowthTbl, aes(x = dateClose, y = Close, color="GOOGL"))
mnyPlt <- mnyPlt + geom_line(data=finGrowthTbl, aes(x = dateClose, y = goog_H, color = "goog_H"))
mnyPlt <- mnyPlt + geom_line(data=finGrowthTbl, aes(x = dateClose, y = Savings, color = "Savings"))
mnyPlt <- mnyPlt + geom_line(data=finGrowthTbl, aes(x = dateClose, y = goog_W, color="goog_W"))
##
################################################################################
##
## Part (2b):  Generate predictions for client;
##
##
# hedgeReturn <- function(Annual_Stock_Performance, Annual_Stock_Volatility){Annual_Stock_Performance + Annual_Stock_Volatility}
##
hedgeReturn <- function(Annual_Stock_Performance){
    round( (532.60 * exp( Annual_Stock_Performance/100 * 160/365) ), 2)    
}

urStkRtrn <- function(Annual_Stock_Performance, Annual_Stock_Volatility){
    mu_daily <- Annual_Stock_Performance / 252
    sd_urStkDly <- Annual_Stock_Volatility / 252
    urStk_W <- vector("numeric", length = 112)
    urStk_W[1] <- 532.60
    for(j in 2:112) {
        #     set.seed(314159)
        urStk_W[j] <- urStk_W[j-1] * (1 + mu_daily * (1/365) + sd_urStkDly * rnorm(1) * sqrt(1/365)) 
    }
    urStk_W[112]
}
##
################################################################################
##
## Part (3):  Serve client;
##
shinyServer(
    function(input, output) {
        
        output$inputValue1 <- renderPrint({round(input$Annual_Stock_Performance,2)})
        output$inputValue2 <- renderPrint({input$Annual_Stock_Volatility})
        
        output$predictStock <- renderPrint({urStkRtrn(input$Annual_Stock_Performance, input$Annual_Stock_Volatility)})
        output$predictHedge <- renderPrint({hedgeReturn(input$Annual_Stock_Performance)})
        ########################################################################        
        output$plot <- renderPlot({
            
            print(mnyPlt)       
        }, height=700)
        ########################################################################        
        summaryVals <- reactive({
            
            # Compose data frame
            datatable(data.frame(
                Fund = c("Savings Account", "Google Stock", "Delta Hedge: Google", "YOUR Stock", "Delta Hedge: YOU"),
                Ann_Return = c(aprAnn, 252*mu_daily, 252*mu_daily, 
                               input$Annual_Stock_Performance/100, input$Annual_Stock_Performance/100),
                Ann_Volatility = c(round(0,2), round(252*sd_googlDly,2), round(0,2), input$Annual_Stock_Volatility, round(0,2)),
                Start = c(round(finGrowthTbl$Savings[1],2), round(finGrowthTbl$Open[1],2), 
                          round(finGrowthTbl$goog_H[1],2), round(finGrowthTbl$Open[1],2), round(finGrowthTbl$Open[1],2)),
                Finish = c(round(finGrowthTbl$Savings[112],2), round(finGrowthTbl$Open[112],2), 
                           round(finGrowthTbl$goog_H[112],2),
                           round(urStkRtrn(input$Annual_Stock_Performance, input$Annual_Stock_Volatility),2),
                           round(hedgeReturn(input$Annual_Stock_Performance),2)),
                Gain = c(round(finGrowthTbl$Savings[112]-finGrowthTbl$Savings[1],2), 
                         round(finGrowthTbl$Open[112]-finGrowthTbl$Open[1],2), 
                         round(finGrowthTbl$goog_H[112]-finGrowthTbl$goog_H[1],2), 
                         round(urStkRtrn(input$Annual_Stock_Performance, input$Annual_Stock_Volatility)-finGrowthTbl$Open[1],2), 
                         round(hedgeReturn(input$Annual_Stock_Performance)-finGrowthTbl$Open[1],2)),
                stringsAsFactors=FALSE)) %>% formatCurrency(c('Start', 'Finish', 'Gain')) %>% formatPercentage('Ann_Return', 2)
            
        })
        #         summaryVals <- datatable(summaryVals)
        # Show the values using an HTML table
        output$accountVals <- DT::renderDataTable({
            summaryVals()
        })
        ########################################################################        
        summaryVals2 <- reactive({
            
            # Compose data frame
            data.frame(
                Fund = c("Savings Account", "Google Stock", "Delta Hedge: Google", "YOUR Stock", "Delta Hedge: YOU"),
                Ann_Return = c(aprAnn, 252*mu_daily, 252*mu_daily, 
                               input$Annual_Stock_Performance/100, input$Annual_Stock_Performance/100),
                Ann_Volatility = c(round(0,2), round(252*sd_googlDly,2), round(0,2), input$Annual_Stock_Volatility, round(0,2)),
                Start = c(round(finGrowthTbl$Savings[1],2), round(finGrowthTbl$Open[1],2), 
                          round(finGrowthTbl$goog_H[1],2), round(finGrowthTbl$Open[1],2), round(finGrowthTbl$Open[1],2)),
                Finish = c(round(finGrowthTbl$Savings[112],2), round(finGrowthTbl$Open[112],2), 
                           round(finGrowthTbl$goog_H[112],2),
                           round(urStkRtrn(input$Annual_Stock_Performance, input$Annual_Stock_Volatility),2),
                           round(hedgeReturn(input$Annual_Stock_Performance),2)),
                Gain = c(round(finGrowthTbl$Savings[112]-finGrowthTbl$Savings[1],2), 
                         round(finGrowthTbl$Open[112]-finGrowthTbl$Open[1],2), 
                         round(finGrowthTbl$goog_H[112]-finGrowthTbl$goog_H[1],2), 
                         round(urStkRtrn(input$Annual_Stock_Performance, input$Annual_Stock_Volatility)-finGrowthTbl$Open[1],2), 
                         round(hedgeReturn(input$Annual_Stock_Performance)-finGrowthTbl$Open[1],2)),
                stringsAsFactors=FALSE)
            
        })
        #         summaryVals <- datatable(summaryVals)
        # Show the values using an HTML table
        output$accountVals2 <- renderTable({
            summaryVals2()
        })
    }
)