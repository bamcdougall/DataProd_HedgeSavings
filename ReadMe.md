---
title       : Comparative Investing - Delta Hedge Fund vs Savings Account
subtitle    : Market vs Best Available Bank Rate
author      : B.A. McDougall
job         : NSCI Consulting
date        : Wednesday, 17 June 2015
output      : html_document
---

## Abstract

This GitHub Repository contains **7** primary files:

- **ReadMe.md** This file
- **index.Rmd** index.Rmd is the file that generates the content of the Slidify presentation using the command slidify('index.Rmd')
- **index.r** index.r contains all the raw R code and is obtained from index.Rmd using purl("index.Rmd",output = "index.R")
- **CodeBook.Rmd** CodeBook.Rmd contains definitions for the critical variables in index.r
- **googl.csv** googl.csv is the file containing Google stock prices from 16-Jun-14 through 12-Jun-15
- **server.R** server.R is the server file used by shinyapps.io to serve the client.  The source code for calculataions is from index.Rmd
- **ui.R** ui.R is the user-interface file used by shinyapps.io to serve the client.



Use of **index.html** is intended from the gh-pages branch.  The file provides a brief model of a two-step binomial pricing model for a call option linked to its underlying stock.
