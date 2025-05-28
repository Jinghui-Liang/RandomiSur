con <- DBI::dbConnect(
	      RMariaDB::MariaDB(),
	      host = env_server,
	      port = env_port,
	      user = env_usr,
	      password = env_password)

stmt_db <- paste ('CREATE DATABASE IF NOT EXISTS', sql_dbname)

rs <- DBI::dbSendStatement(con, stmt_db)
DBI::dbClearResult(rs)
DBI::dbDisconnect(con)

cat ("database generated successfully \n")
