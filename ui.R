################################################################################
##
##  Author:  Brendan McDougall
##  Proj Purpose: Project 1 of Developing Data Products / Johns Hopkins Univ
##  File Purpose: R-script for client user interface of Shiny Application
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
## library(shiny)
##
################################################################################
##
## Build UI Page 

shinyUI(
    fluidPage(withMathJax(),
              
              headerPanel("Investment:  \\(\\Delta\\) Hedge Fund vs Savings Account"),
              titlePanel("Market vs Best Available Bank Rate"),
              
              sidebarLayout(
                  sidebarPanel(
                      # Decimal interval with step value
                      sliderInput("Annual_Stock_Performance", "Target Annual Growth Rate:", 
                                  min = 0, max = 20, value = 9.0, step= 0.01, post='%'),            
                      # Decimal interval with step value
                      sliderInput("Annual_Stock_Volatility", "Target Annual Volatility [standard deviation]:", 
                                  min = 0, max = 80, value = 41.3, step= 0.01, pre='$')#, 
                  ),
                  
                  mainPanel(
                      tabsetPanel(type = "tabs", 
                                  tabPanel("Main",
                                           h1('Executive Summary'),
                                           p('In principle, a hedge fund enables stock market return, but with risk 
                                                well-managed.  This', a(href="http://shiny.rstudio.com/", "Shiny"),
                                             'application compares investment performance between a
                                                Delta (\\(\\Delta\\)) Hedge, its underlying stock, and a savings account.'),
                                           h2('Investment Period: 2 Jan 2015 - 12 June 2015', align = "center"),
                                           p('There are 112 trading days in this period.  There are about 252 trading days
                                             in a year.'),
                                           h2('Investment Summary'),
                                           p('The starting balance for each investment strategy is $532.60.  The amount
                                                selected is the opening price of Google stock on 2 Jan 2015.  The Table tabs summarize the performance of the following
                                             financial instruments during the investment period.  The return rate shown in the table is the annualized rate for the return during the investment period.'),
                                           p('The funds are:'),
                                           tags$ol(
                                               tags$li("Savings account.  Interest rate is best available
                                                       on 12 June 2015 with daily compounding."), 
                                               tags$li("Goggle Stock."), 
                                               tags$li(" \\(\\Delta\\) Hedge fund with Goggle stock against its own European option."), 
                                               tags$li('YOUR Stock.  The target return and volatility are entered by you.  The default values approximate
                                                       performance by Google stock during this investment period'), 
                                               tags$li(" \\(\\Delta\\) Hedge fund with YOUR stock against its own European option.")
                                           ),
                                           h2('Brief comments'),
                                           tags$ol(
                                               tags$li("The financial models are simple and only meant to be illustrative."), 
                                               tags$li("The model utilized for stock pricing is stochastic and uses a standard normal distribution.  The physical
                                  meaning of this can be seen in the table.  Nearly all the time, the valuation of YOUR stock and this pricing
                                  history of Google stock will differ with matching parameters.  This is an intrinsic property of 
                                  stochastic processes and also illustrated in the", strong('Plot'), "tab!"), 
                                               tags$li('For additional information, see the', strong('Help'), "tab!")
                                           )
                                  ),
                                  tabPanel("Data Table",
                                           p('The numerical expression for stock price used for these calculations is:'),
                                           div(withMathJax(
                                               p("$$S_{i + 1} = S_i + \\mu S_i \\Delta t + \\sigma S_i \\epsilon \\sqrt{\\Delta t}$$",
                                                 style = "color:blue; font-size = 32pt")
                                           ), style="font-size: 200%;"),
                                           p('where'),
                                           div(withMathJax(
                                               p('$$ S = stock Price;\\mu = stock Return Rate; \\Delta t = time; \\epsilon$$',
                                                 style = "color:blue; font-size = 32pt")
                                           ), style="font-size: 200%;"),
                                           p('is a sample drawn from a standard normal distribution.'),
                                           DT::dataTableOutput("accountVals")
                                  ),
#                                   tabPanel("Table",
#                                            p('The numerical expression for stock price used for these calculations is:'),
#                                            div(withMathJax(
#                                                p("$$S_{i + 1} = S_i + \\mu S_i \\Delta t + \\sigma S_i \\epsilon \\sqrt{\\Delta t}$$",
#                                                  style = "color:blue; font-size = 32pt")
#                                                ), style="font-size: 200%;"),
#                                                p('where'),
#                                            div(withMathJax(
#                                                p('$$ S = stock Price;\\mu = stock Return Rate; \\Delta t = time; \\epsilon$$',
#                                                  style = "color:blue; font-size = 32pt")
#                                            ), style="font-size: 200%;"),
#                                            p('is a sample drawn from a standard normal distribution.'),
#                                            tableOutput("accountVals2")
#                                   ),
                                  tabPanel("Plot",
                                           h1('Time Evolution of Financial Assets'),
                                           h2('Investment Period: 2 Jan 2015 - 12 June 2015', align = "center"),
                                           p(''),
                                           h2('Discussion'),
                                           p('The figure shows a plot of actual Google stock price (GOOGL) vs time.
                                             The plot also includes a simulation of Google stock price (goog_W).  In the
                                             simulation, the
                                             return rate and the volatility are matched to the actual performance of Google
                                             stock as shown in the GOOGL cruve.  The simulation
                                             incorporates the stochastic Wiener process.  Note the simulation
                                             captures the volatility demonstrated by GOOGL.  Sinc e the model incorporates
                                             randomness, one should not expect simulation and real price history to match
                                             exactly.
                                             The following link illustrates the Wiener process more vividly by 
                                             animating this plot:',
                                             a(href="http://bamcdougall.github.io/DataProd_HedgeSavings/index.html#5", 'Animation of Stock Pricing.')),
                                           p('The numerical expression for stock price used for these calculations is:'),
                                           div(withMathJax(
                                               p("$$S_{i + 1} = S_i + \\mu S_i \\Delta t + \\sigma S_i \\epsilon \\sqrt{\\Delta t}$$",
                                                 style = "color:blue; font-size = 32pt")
                                           ), style="font-size: 200%;"),
                                           p('where'),
                                           div(withMathJax(
                                               p('$$ S = stock Price;\\mu = stock Return Rate; \\Delta t = time; \\epsilon$$',
                                                 style = "color:blue; font-size = 32pt")
                                           ), style="font-size: 200%;"),
                                           p('is a sample drawn from a standard normal distribution.'),
                                           p('NOTE:  the plot may take a few moments or minutes to load depending on server responsiveness and on
                                             your network speed.  Otherwise, click the animation link above, which loads more quickly.'),
                                           plotOutput('plot')
                                  ),
                                  tabPanel("Help",
                                           h1('Instructions'),
                                           h2('Using this application'),
                                           p('Two values are needed to price your target stock'),
                                           tags$ol(
                                               tags$li(strong('Target Annual Growth Rate'), 'Target Annual Growth Rate of your stock expressed as a percentage.
                                       The default value represents the return on Google stock during the selected investment period.
                                       Just drag the slider to the left or to the right to the desired return of your stock.'), 
                                               tags$li(strong('Target Annual Volatility'), 'Target Annual Volatility of your stock expressed as a standard deviation
                                        in units of currency [$].
                                       The default value represents the annual volatility of Google stock during the selected investment period.
                                       Just drag the slider to the left or to the right to the desired return of your stock.')
                                           ),
                                           p('When the application starts, default values are used to generate data shown in the Table of the', strong('Data Table'),
                                             'tab and generate the figure on the', strong('Plot'),' tab.  Each time you update the Slider Input, the values for your stock are updated
                                             in the Table of the', strong('Main'), 'tab.  The plot is not updated.'),
                                           
                                           h1('Brief Description of Concepts.'),
                                           p('A \\(\\Delta\\) Hedge fund is a portfolio with \\(\\Delta\\) shares of a stock for every one of
                                             its own options in the portfolio.  In 1979, Cox, Ross, Rubinstein published a paper validating
                                             that a \\(\\Delta\\) Hedge fund can be made riskless using a two-state outcome:  stock either
                                             increases or decreases.'),
                                           p('Even in this simple model, complexity is evident in the figure shown on the', strong('Plot'),' tab!  The 
                                             time step for the figure is 1 trading day.  In reality, trades are executed in time steps of 1 micro-second.
                                             Conceptually, this means that for a single stock that there are 3.6 billion possible trades per hour.'),
                                           p('For technical information, see this ', a(href="http://bamcdougall.github.io/DataProd_HedgeSavings/index.html#1", 'Derivative and Stock Pricing'),
                                             a(href="http://www.http://slidify.org/", 'Slidify'), ' presentation.')
                                  )
                      ))
              )
    )
)
