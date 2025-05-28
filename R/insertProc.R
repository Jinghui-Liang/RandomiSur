query_response <- "CREATE OR REPLACE PROCEDURE insertLikertResp(IN json VARCHAR(9999))
    INSERT INTO response (p_id, rt, response, Q_num, trial_type, trial_index, order_index, time_elapsed, internal_node_id)
    VALUES(
      JSON_EXTRACT(json, '$.p_id'),
      JSON_EXTRACT(json, '$.rt'),
      JSON_EXTRACT(json, '$.response'),
      JSON_EXTRACT(json, '$.Q_num'),
      JSON_EXTRACT(json, '$.trial_type'),
      JSON_EXTRACT(json, '$.trial_index'),
      JSON_EXTRACT(json, '$.order_index'),
      JSON_EXTRACT(json, '$.time_elapsed'),
      JSON_EXTRACT(json, '$.internal_node_id')
   )"

query_demo <- "CREATE OR REPLACE PROCEDURE insertDemo(IN json VARCHAR(9999))
    INSERT INTO demo (p_id, value, property)
    VALUES(
      JSON_EXTRACT(json, '$.p_id'),
      JSON_EXTRACT(json, '$.value'),
      JSON_EXTRACT(json, '$.property')
   )"

rs <- DBI::dbSendStatement(con_t, query_response)
DBI::dbClearResult(rs)

rs <- DBI::dbSendStatement(con_t, query_demo)
DBI::dbClearResult(rs)

DBI::dbDisconnect(con_t)
