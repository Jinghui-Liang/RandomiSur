if(file.exists("/.dockerenv")) {
  arcPath <- "/var/scalepool/"
  # outputDir <- "/var/scalepool"
} else {
  if(interactive()){
    arcPath <- "../scalepool/"
  }
  else {
    stop("no plan archive is detected.")
  }
}

if(file.exists(paste0(arcPath, "df-order.zip"))){
    unzip(paste0(arcPath, "df-order.zip"), exdir = arcPath)
}

## data recording every orders (o.record)
order_plan <- readr::read_csv(paste0(arcPath, "df-order.csv")) |>
    dplyr::select(-`...1`)

## plan for PHP
order_counter <- readr::read_csv(paste0(arcPath, "df-plan.csv")) |>
    dplyr::select(-`...1`) |>
    dplyr::mutate(counter = 0)

## match which participant got which order(match.order)
matcher <- as.data.frame(matrix(nrow = 0, ncol = 2))
colnames(matcher) <- c("p_id", "order_label")
