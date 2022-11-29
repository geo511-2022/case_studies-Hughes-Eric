---
title: "Case Study Number 08"
author: Eric Hughes
date: October 28, 2022
output: 
  html_document: default
  github_document: default
  powerpoint_presentation: default
  word_document: default
knit: {rmarkdown::render("case_study_08.Rmd", output_format = "all")}
knit: (function(inputFile, encoding){
  rmarkdown::render(inputFile, encoding = encoding,
  output_dir = "my-output-path", output_format = "all") })
---

```{r}
library(tidyverse)
data = read_table(file = ('ftp://aftp.cmdl.noaa.gov/products/trends/co2/co2_annmean_mlo.txt'), skip = 57, col_names = c("year", "mean", "unc"), comment = "#")
```
```{r}
library(ggplot2)
ggplot(data, aes(x=year, y=mean)) +
  geom_line(aes(color = "red")) +
  labs(title = "Mean CO2 Concentrations Through Time",
       y = "Mean CO2",
       x = "Years",
       caption = "From Mauna Loa CO2 annual mean data")
```
```{r}
knitr::kable(head(arrange(co2_data[,1:3], desc(year))), format = "simple", col.names = c("Year", "Mean", "UNC"), caption = "Mauna Loa CO2 Annual Mean")
```
  
