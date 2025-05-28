if(file.exists("/.dockerenv")) {
  questPath <- paste0("/var/scalepool/", quest_name)
  outputDir <- "/var/www/html/"
} else {
  if(interactive()) {
      questPath <- "../scalepool/fullscale.csv"
      # questPath <- "../inject-order/fullscale.csv"
  } else {
    questPath <- paste0("./scalepool/", quest_name)
  }
  outputDir <- "./server/www/"
}

cat(questPath)

dat <- readr::read_csv(questPath) |>
    dplyr::mutate(choices = ifelse(choices == "NA", NA_real, choices),
                  required = ifelse(required == "NA", NA_real, required))

## split out questionnaire part
## quest <- dat[, c("question", "q_choices", "q_required")] |> 
##   dplyr::filter(!is.na(question)) |> tibble::as_tibble()
colnames(dat)[colnames(dat) == "question"] <- "prompt"

## convert demo items to JSON
demo <- dat |> dplyr::filter(demographic == "y")

demo_js <- demo |>
    dplyr::mutate(choices = ifelse(test = is.na(choices),
                                   yes = list(NA),
                                   no = sapply(choices,
                                               \(.x) strsplit(.x, split = "/"),
                                               USE.NAMES = FALSE)
                                   ))

# demo_js <- dplyr::bind_rows(demo_strvar, demo_catvar)
demoJSON <- jsonlite::toJSON(demo_js, pretty = TRUE)

## convert scale to JSON
quest <- dplyr::anti_join(dat, demo, by = "prompt") |>
    dplyr::select(-demographic) |>    
    dplyr::mutate(choices = ifelse(is.na(choices),
                                   choices[which.max(!is.na(choices))],
                                   choices
                                   ),
                  required = ifelse(is.na(required), "y", "n")
                  )

if (any(!quest$required %in% c("n", "y"))) {
  print (quest$q_required)
  stop ('Column "required" not properly defined.')
}

quest_js <- quest |>
    dplyr::mutate (choices = sapply(quest$choices,
                                    \(.x) strsplit(.x, split = "/"),
                                    USE.NAMES = FALSE)) |> 
  dplyr::select(-label)

scaleJSON <- jsonlite::toJSON(quest_js, pretty = TRUE)

write(scaleJSON, paste0(outputDir, "scale.json"))
write(demoJSON, paste0(outputDir, "demo.json"))
