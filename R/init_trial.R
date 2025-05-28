source("R/generate_order.R")
 
# DBI::dbWriteTable(con_t, "order_list", o.record, overwrite = TRUE)
# DBI::dbWriteTable(con_t, "frequency_counter", f.record, overwrite = TRUE)
# DBI::dbWriteTable(con_t, "order_match", match.record, overwrite = TRUE)

DBI::dbWriteTable(con_t, "order_list", order_plan, overwrite = TRUE)
DBI::dbWriteTable(con_t, "frequency_counter", order_counter, overwrite = TRUE)
DBI::dbWriteTable(con_t, "order_match", matcher, overwrite = TRUE)

query <- "ALTER TABLE order_match MODIFY order_label VARCHAR(999)"

rs <- DBI::dbSendStatement(con_t, query)
DBI::dbClearResult(rs)

query <- "ALTER TABLE order_match MODIFY p_id VARCHAR(999)"

rs <- DBI::dbSendStatement(con_t, query)
DBI::dbClearResult(rs)

query <- "CREATE OR REPLACE TABLE demo (
                                        p_id VARCHAR(999),
                                        value VARCHAR(999),
                                        property VARCHAR (999)
                                       );"

rs <- DBI::dbSendStatement (con_t, query)
DBI::dbClearResult(rs)
