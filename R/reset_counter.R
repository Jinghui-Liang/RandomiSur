qname <- commandArgs(TRUE)

readRenviron(".env")

con <- DBI::dbConnect(
              RMariaDB::MariaDB(),
              host = '127.0.0.1',
              port = Sys.getenv('SQL_PORT'),
              user = 'root',
              password = Sys.getenv('DB_PASS'),
              dbname = qname
            )

query <- "update frequency_counter set n = 0"

rs <- DBI::dbSendStatement(con, query)
DBI::dbClearResult(rs)
DBI::dbDisconnect(con)
