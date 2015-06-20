---
title       : Investment - Delta Hedge Fund vs Savings Account
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

## Definitions from Finance
* **Stock** An asset representing partial ownership of a publicly traded firm.
* **American Option** Right to buy (long) or sell (short) an asset at strike price $S_k$ at any time until maturity for a premium.
* **European Option** Right to buy (long) or sell (short) an asset at strike price $S_k$ at maturity for a premium.
* **Call Option** Option to buy an asset at strike price $S_k$ at maturity for a premium.
* **Put Option** Option to sell an asset at strike price $S_k$ at maturity for a premium.

## Savings Account: Limit of continuous compounding
* $r =$ risk free interest rate; $PV =$ Present Value of Money; $FV =$ Future Value of Money
* With annual compounding, $FV_1 = PV (1 + r) \Longrightarrow FV_t = PV(1+\frac{r}{n})^{nt}$
* In limit of decreasing time intervals, $FV_t = \lim_{n\to\infty} PV(1+\frac{r}{n})^{\frac{n}{r} rt} = PV e^{rt}$

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

* Numerical simulation and actual stock price of Google (Dates:  1/2/2015 - 6/12/2015).  Plot also shows savings account (best interest $r=1.25\%$) & a $\Delta$ Hedge with Google stock (market rate $\mu= 6.28 \%$ &
$ \sigma = $ \$41.)

<video   controls loop><source src="assets/fig/stockPricing-.webm" />video of chunk stockPricing</video>
* Animation demonstrates stochastic nature of stock pricing.  Each simulation presents a valid solution.
