if(!interactive()) {
    prompt_position <- "Are you running local test or uploading your platform to a server? (local/server)"
    cat(prompt_position)
    position <- readLines("stdin", n = 1)
    cat(position)
    ## ------ under development ------
    prompt_questionnaire <- "Which database you would like to down data from?"
    db_name <- readLines("stdin", n = 1)
    cat(db_name)
    ## ------
    prompt_verbose <- "Do you want to download (f)ull data or just (r)esposne data? (f/r)"
    cat(prompt_verbose)
    verbose <- readLines("stdin", n = 1)
    readRenviron("./.env")
} else {
    db_name <- "fullscale"
    readRenviron("../.env")
}

localdb <- "fullscale"

if (position == "local") {
    env_server <- '127.0.0.1'
} else if (position == "server") {
    env_server <- Sys.getenv('SERVER_NAME')
} else {
    stop ('arguments must be either "local" or "server"')
}

tryCatch({
    con_t <- DBI::dbConnect(
                      RMariaDB::MariaDB(),
                      host = env_server,
                      port = Sys.getenv('SQL_PORT'),
                      user = Sys.getenv('USR_NAME'),
                      password = Sys.getenv('DB_PASS'),
                      dbname = db_name)
},
error = stop(".env file not correctly configured.")
)


response <- dplyr::tbl(con_t, "response") |> dplyr::collect()
demo <- dplyr::tbl(con_t, "demo") |> dplyr::collect() |> 
    dplyr::mutate(property = substr(property, 2, nchar(property) - 1)) |> 
    tidyr::pivot_wider(names_from = property,
                       values_from = value)
frequency <- dplyr::tbl(con_t, "frequency_counter") |> dplyr::collect()
order <- dplyr::tbl(con_t, "order_list") |> dplyr::collect()
match <- dplyr::tbl(con_t, "order_match") |> dplyr::collect()

if(!interactive()) {
    dir_name <- paste0("./raw_data/results-", Sys.Date(), "-", format(Sys.time(), "%X"))
} else {
    dir_name <- paste0("../raw_data/results-", Sys.Date(), "-", format(Sys.time(), "%X"))
}

dir.create(dir_name)

if(verbose == "f") {
    write.csv(demo, file = paste0(dir_name, "/demo.csv"))
    write.csv(order, file = paste0(dir_name, "/order-list.csv"))
    write.csv(match, file = paste0(dir_name, "/order-pid.csv"))
    write.csv(frequency, file = paste0(dir_name, "/frequency-counter.csv"))
} else if(verbose != "r") {
    stop("target data number not properly specified.")
}

write.csv(response, file = paste0(dir_name, "/response.csv"))

DBI::dbDisconnect(con_t)
