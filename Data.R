#'---
#' title: "Data Extraction
#' author: 'Yingzi'
#' abstract: |
#'  | Provide a summary of objectives, study design, setting, participants,
#'  | sample size, predictors, outcome, statistical analysis, results,
#'  | and conclusions.
#' documentclass: article
#' description: 'Manuscript'
#' clean: false
#' self_contained: true
#' number_sections: false
#' keep_md: true
#' fig_caption: true
#' output:
#'  html_document:
#'    toc: true
#'    toc_float: true
#'    code_folding: show
#' ---
#'
#+ init, echo=FALSE, message=FALSE, warning=FALSE
# init ----
# This part does not show up in your rendered report, only in the script,
# because we are using regular comments instead of #' comments
debug <- 0;
knitr::opts_chunk$set(echo=debug>-1, warning=debug>0, message=debug>0);



library(rio);# simple command for importing and exporting
library(pander); # format tables
library(printr); # set limit on number of lines printed
library(broom); # allows to give clean dataset
library(dplyr); #add dplyr library
library(fs)

options(max.print=42);
panderOptions('table.split.table',Inf); panderOptions('table.split.cells',Inf);
whatisthis <- function(xx){
  list(class=class(xx),info=c(mode=mode(xx),storage.mode=storage.mode(xx)
                              ,typeof=typeof(xx)))};

#' # Import the data
InputData <- 'https://physionet.org/static/published-projects/mimic-iv-demo/mimic-iv-clinical-database-demo-1.0.zip'
dir.create("data", showWarnings = FALSE)
ZippedData <- file.path("data", "temptdata.zip")
download.file(InputData,destfile = ZippedData)

# UnzippedDate the data
UnzippedData <- unzip(ZippedData,exdir= "data" ) %>%
grep ("gz",., value = TRUE)

TableNames <- unzip(ZippedData, exdir = "data")%>%
  grep('gz', ., value = TRUE)%>%
  basename()%>%
  fs::path_ext_remove()%>%
  fs::path_ext_remove()
# for (ii in seq_along(TableNames)){
#   assign(TableNames[ii], import(UnzippedData[ii]), format ='CSV'));

Junk <- mapply(function(xx,yy)
  assign(xx,import(yy,format = 'CSV'),inherits = TRUE),TableNames,UnzippedData)

save(list = TableNames,file='data.R.rdata')


#if(!file.exists(ZippedData)) {download.file(InputData, destfile = ZippedData)}

# %>%

# grep("gz", UnzippedData) # poositions in the vector where the pottern "gz" has been fpund
# grep("gz", UnizippedData, value = TURE) #return the actual strings



