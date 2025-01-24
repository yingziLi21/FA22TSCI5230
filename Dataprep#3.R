#'---
#' title: "TSCI 5230: Introduction to Data Science"
#' author: ''
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

library(ggplot2); # visualisation
library(GGally);
#library(rio);# simple command for importing and exporting
library(pander); # format tables
library(printr); # set limit on number of lines printed
library(broom); # allows to give clean dataset
library(dplyr); #add dplyr library
library(tidyr);
library(purrr);
library(table1);




options(max.print=42);
panderOptions('table.split.table',Inf); panderOptions('table.split.cells',Inf);

# load data ----

if(!file.exists("data.R.rdata")){
  system("R -f Data.R")
}

load("data.R.rdata")

##plotting using ggplot
ggplot(data = patients, aes(x = anchor_age, fill = gender))+
  geom_histogram() +
  geom_vline(xintercept = 65)

table(patients$gender)
#check for duplicates in the subject_id

#aggregating data: data structures

Demographics <- group_by(admissions, subject_id)%>%
  mutate(los = difftime(dischtime, admittime))%>%
  summarise(admits = n(),
            ethnic = length(unique(ethnicity)),
            ethnicity_combo = paste(sort(unique(ethnicity)), collapse = ":"),
            # language0 <- length(unique(language)),
            # language_combo <- paste(sort(unique(language)), collapse = ":")
            language = tail(language, 1),
            dod = max(deathtime, na.rm = TRUE),
            los = median(los),
            numED = length(na.omit(edregtime)))


#subset(ethnic > 1)

table(admissions$ethnicity)

ggplot(data = Demographics, aes(x = admits)) +
  geom_histogram()

#join admission and patients df
intersect(names(Demographics), names(patients))
Demographics$subject_id
patients$subject_id
setdiff(Demographics$subject_id, patients$subject_id)
setdiff(patients$subject_id,Demographics$subject_id)
setdiff(Demographics$dod, patients$dod)

Demographics1<- left_join(Demographics, select(patients, -dod), by=c("subject_id"))

# Mapping the variables.

# build list of keywords
kw_abx <- c("vanco", "zosyn", "piperacillin", "tazobactam", "cefepime", "meropenam", "ertapenem", "carbapenem", "levofloxacin")
kw_lab <- c("creatinine")
kw_aki <- c("acute renal failure", "acute kidney injury", "acute kidney failure", "acute kidney", "acute renal insufficiency")
kw_aki_pp <- c("postpartum", "labor and delivery")

# search for those keywords in the tables to find the full label names
# remove post partum from aki in last line here
# may need to remove some of the lab labels as well (pending)
label_abx <- grep(paste0(kw_abx, collapse = '|'), d_items$label, ignore.case = T, value = T, invert = F)
label_lab <- grep(paste0(kw_lab, collapse = '|'), d_labitems$label, ignore.case = T, value = T, invert = F)
label_aki <- grep(paste0(kw_aki, collapse = '|'), d_icd_diagnoses$long_title, ignore.case = T, value = T, invert = F)
label_aki <- grep(paste0(kw_aki_pp, collapse = '|'), label_aki, ignore.case = T, value = T, invert = T)

# use dplyr filter to make tables with the item_id for the keywords above
item_ids_abx <- d_items %>% filter(label %in% label_abx)
item_ids_lab <- d_labitems %>% filter(label %in% label_lab)
item_ids_aki <- d_icd_diagnoses %>% filter(long_title %in% label_aki)
Akidiagnoses_icd<- subset(diagnoses_icd,grepl("^548|N17",icd_code))
Antibiotics <- subset (item_ids_abx, category=="Antibiotics") %>% left_join(inputevents,by="itemid")

Cr_labevents<- subset(item_ids_lab, fluid=='Blood') %>%
  left_join(labevents, by='itemid') #Filter only blood Cr and match to lab events

grepl(paste(kw_abx,collapse = '|' ),emar$medication)
subset(emar, grepl(paste(kw_abx, collapse = '|'), medication, ignore.case = T)) $event_txt%>%
  table()%>%sort() #Filter emar by antibiotic administration with individual event txt

Antibiotics_Groupings<-group_by(Antibiotics, hadm_id) %>%
  summarise(Antibiotics,Vanc='Vancomycin' %in% label,
            Zosyn=any(grepl('Piperacillin',label)),
            Other=length(grep('Piperacillin|Vancomycin',label,value = T,invert=T))>0,
            N=n(),
Exposure1=case_when(!Vanc~'Other',
                    Vanc&Zosyn~'Vanc&Zosyn',
                    Other~'Vanc&Other',
                    !Other~'Vanc',
                    TRUE~'UNDEFINED'))

grepl('Zosyn', Antibiotics$label)
group_by(Antibiotics_Groupings,Vanc,Zosyn,Other)%>%
  summarise(N=n())

#Vanc&Zosyn&!Other~'Vanc' exposure2 variablead

#9.28#
# create Antibiotics_dates: each row represents a day  with antibiotics injection
admissions_scaffold<- admissions %>% select(hadm_id, admittime, dischtime) %>%
transmute(hadm_id= hadm_id,
          ip_date= map2(as.Date(admittime), as.Date(dischtime),seq,by="1 day"))%>%
    unnest(ip_date)

# split Antibiotics_dates by antibiotics type
Antibiotics_dates<- Antibiotics %>%
  transmute(hadm_id = hadm_id,
            group=case_when( "Vancomycin" == label ~ "Vanc",
            grepl("Piperacillin", label) ~ "Zosyn",
            TRUE ~ "Other"),
            starttime= starttime,
            endtime= endtime) %>% unique() %>%

 subset(!is.na(starttime) & !is.na(endtime)) %>%
  transmute (hadm_id = hadm_id,
            ip_date = map2(as.Date(starttime), as.Date(endtime), seq, by="1 day"),
            group=group) %>%
unnest(ip_date)

Antibiotics_dates<- split(Antibiotics_dates, Antibiotics_dates$group)

## combine multiple variables

Antibiotics_dates <- sapply(names(Antibiotics_dates), function(xx)
{
  names(Antibiotics_dates[[xx]])[3] <- xx
  Antibiotics_dates[[xx]]},
simplify = FALSE) %>%
  Reduce(left_join, ., admissions_scaffold)

mutate(Antibiotics_dates,
       across(all_of(c("Other", "Vanc", "Zosyn")), ~ coalesce(.x, "")),
       exposure = paste(Vanc, Zosyn, Other)) %>%
  select(hadm_id, exposure) %>%
  unique() %>%
  pull(exposure) %>% table()

group_by(Antibiotics_Groupings, Vanc, Zosyn, Other) %>%
  summarise(N=n())
grepl("Zosyn", Antibiotics$label)

#10/05
class(Antibiotics_dates)
Cr_labevents2<- Antibiotics_dates %>%
  group_by(hadm_id) %>%
  #mutate(date_Vanc_Zosyn = min(ip_date[!is.na(Vanc) & !is.na(Zosyn)]))%>%
  summarise(date_Vanc_Zosyn = min(ip_date[!is.na(Vanc) & !is.na(Zosyn)])) %>%
  subset(!is.infinite(date_Vanc_Zosyn)) %>%
  left_join(Cr_labevents, .) %>%
  subset(!is.na(hadm_id)) %>%
  arrange(hadm_id, charttime)%>%
  group_by(hadm_id)%>%
  #mutate(after_Vanc_Zosyn = coalesce (charttime >= date_Vanc_Zosyn, FALSE),
         #centered = charttime - coalesce(date_Vanc_Zosyn, median(charttime)),
        #no_Vanc_Zosyn = all(is.na(date_Vanc_Zosyn)))
  mutate(Vanc_Zosyn = !all(is.na(date_Vanc_Zosyn)))

ggplot(Cr_labevents,aes(x=centered, y=valuenum, group=hadm_id))+
   geom_line(aes(col=no_Vanc_Zosyn))+
   geom_point(aes(col=after_Vanc_Zosyn))+
   facet_wrap("no_Vanc_Zosyn")

Cr_labevents$charttime - Cr_labevents$date_Vanc_Zosyn %>% na.omit() %>% head()

#combine demographics and creation table
  Analysis_Date <- left_join(Cr_labevents2, Demographics1)

  ggplot(Analysis_Date, aes(x= date_Vanc_Zosyn, y=valuenum))+
  geom_violin()

paireed_analysis <- c('valuenum', 'admits', 'flag' ,'Vanc_Zosyn')
Analysis_Date[,paireed_analysis]%>%
  ggpairs(aes(col=Vanc_Zosyn))

table1(~valuenum+admits+flag+anchor_age+gender|Vanc_Zosyn,data = Analysis_Date)
xx<- stats.default(Analysis_Date$anchor_age)
with(xx, MAX - MIN)
sprintf("The decimal is %0.2f or %0.1f. The integer is %d. The percentage is %s, 4.222, 5.2222)

my.render.cont<-function(x) {
  with(x<- stats.default(Analysis_Date$anchor_age),
       sprintf("%0.2f (%0.1)", MEAN,SD))}

# with(a,b): temporarily calculation b on object a
