library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
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


#df_poland <- read_rds('df_poland_final.Rds')

df_poland <- read_fst('df_poland.fst')

poly_poland <- read_rds('gadm36_POL_0_sp.rds')

source('modules.R')
