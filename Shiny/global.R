library(shiny)
library(bs4Dash)
library(shinyjs)
library(shinyWidgets)
library(tidyverse)
library(DT)
library(plotly)
library(echarts4r)
library(readr)
library(fst)
library(leaflet)
library(leafpop)
library(glue)

df_poland <- read_fst('df_poland.fst') %>% arrange(eventDate)

poly_poland <- read_rds('gadm36_POL_0_sp.rds')

source('modules.R')
