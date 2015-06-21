---
title       : Comparative Investing - Delta Hedge Fund vs Savings Account
subtitle    : Market vs Best Available Bank Rate
author      : B.A. McDougall
job         : NSCI Consulting
framework   : io2012     # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : [mathjax, bootstrap]            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
---

## Portfolio Management

### Generate Risk Neutral Valued (RNV) Portfolio using [Binary Tree Model](https://en.wikipedia.org/wiki/Binomial_options_pricing_model)
* Purchasing $\Delta$ shares of stock at price $S_o$, and short a call option on same stock with value $f$
* Value of RNV portfolio is same whether stock price goes up or down; therefore, $(\Delta S_o) u - f_u = (\Delta S_o) d - f_d$.  $u$ is multiplier for increase; $d$ is multiplier for decrease.

### $\Delta$ Hedge for RNV Portfolio
* From equality, $\Delta$ required for creating a RNV Portfolio is $\Delta = \frac{f_u - f_d}{S_o (u-d)}$
* PV of RNV is discounted FV $\Longrightarrow (\Delta S_o)  - f = e^{-r t} \left[ (\Delta S_o) u - f_u \right]$
* Solving for f estimates PV of call option $\Longrightarrow f = e^{-r t} \left[ p f_u + (1 - p) f_d \right]$
where
<div class="centered">
\begin{equation}
p = \frac{e^{r t} - d}{u - d}
\end{equation}
</div>

* **NOTE**:  f is discounted expectation value of option's FV against a binomial density (*coin flip*)

---
## Portfolio Management (continued)
* For stochastic processes, variance is proportional to $\Delta t$, so
<div class="centered">
\begin{equation}
\sigma^2 \Delta t = \langle S(t)^2 \rangle - \langle S(t) \rangle ^2
\end{equation}
</div>
<div class="centered">
\begin{equation}
\sigma^2 \Delta t = \left[ p u^2 + (1-p) d^2 \right] - \left[ \left( p u + (1-p) d \right)^2 \right]
\end{equation}
</div>
<div class="centered">
\begin{equation}
\sigma^2 \Delta t = (u + d) e^{\mu t} - du - e^{2 \mu t}
\end{equation}
</div>

* Using a Taylor Expansion, one validates a solution for u & d is $u = e^{\sigma \sqrt{\Delta t}}$ & $d = e^{- \sigma \sqrt{\Delta t}}$
* Summarizing:  (1) FV of RNV Portfolio is $\left[(\Delta S_o)  - f\right]e^{\mu t}$ which is of same form as FV of Savings account; (2) The relationship between $f$ and $S_o$ is fully determined.

## Pricing a Stock
* Two assumptions: (1) during a small time interval, a random contribution to the differential of stock price is $\epsilon \sqrt(\Delta t)$ where $\epsilon$ is a standard normal distribution; (2) Values of $\epsilon \sqrt(\Delta t)$ from any two time intervals $\Delta t$ are mutually independent.

---
## Time Dependence of $S$

* The differential of stock price is $d S = \mu S d t + \sigma S \epsilon \sqrt{dt}$. Neglecting volatility, $S(t) = S_o e^{\mu t}$.

* Solving numerically, $\Delta S = \mu S \Delta t + \sigma S \epsilon \sqrt{\Delta t}$, so $S_{i + 1} = S_i + \mu S_i \Delta t + \sigma S_i \epsilon \sqrt{\Delta t}$








```r
## This code chunk demonstrates pricing Google Stock assuming a Wiener process.
for(j in 1:30) {
    for(i in 2:112) {
        #     set.seed(314159)
        goog_W[i] <- goog_W[i-1] * (1 + mu_daily * (1/365) + sd_googlDly * rnorm(1) * sqrt(1/365)) 
        }
    }
print(paste('On 12 June 2015, the simulated closing price of Google Stock is $', round(goog_W[112],2)))
```

```
## [1] "On 12 June 2015, the simulated closing price of Google Stock is $ 519.9"
```
* Code chunk numerically integrates the opening Google stock price on 2 Jan 2015 of $532.60 through 112 trading days until 12 June 2015

---
## Animation of Pricing a Stock Using a Wiener Process
* Numerical simulation and actual stock price of Google (Dates:  1/2/2015 - 6/12/2015).
* Plot also shows savings account (best interest $r=1.25\%$) & a $\Delta$ Hedge with Google stock (market rate $\mu= 6.28 \%$ &
$ \sigma = $ \$41.)

<video   controls loop><source src="assets/fig/stockPricingAnimating-.webm" />video of chunk stockPricingAnimating</video>
* Animation demonstrates stochastic nature of stock pricing
