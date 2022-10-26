library(DBI)
#DBI is a generic database accessing tool

source("local_config.R")
con <- dbConnect(RPostgres::Postgres(),dbname = 'postgres',
                 host = myserve,
                 port = 5432,
                 user = myuser,
                 password = mypassword)

dbListTables(con)
dbGetQuery(con,"SELECT * FROM patients limit 10")




