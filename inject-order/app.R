suppressPackageStartupMessages({library(shiny)})
suppressPackageStartupMessages({library(tidyverse)})
suppressPackageStartupMessages({library(bslib)})

source("./default.R")

readRenviron("/var/.env")

ui <- page_sidebar(
    title = "Order builder",
    sidebar = sidebar(width = 500,
                      helpText = "Randomization strategies",
                      fileInput(
                          inputId = "file", label = NULL,
                          accept = c("text/csv",
                                     "text/comma-separated-values",
                                     ".csv"
                                     )
                      ),
                      actionButton("clear_all", "Clear all"),
                      numericInput(
                          inputId = "Seed",
                          label = "seed",
                          value = 1
                      ),
                      checkboxGroupInput(
                          inputId = "select",
                          label = "Algorithm",
                          choices = list(
                              "Fixed order",
                              "Simple randomization",
                              "Permuted-Subblock Randomization (PSR)",
                              "Latin Square",
                              "Fixed Grouping",
                              "Random Grouping - factor",
                              "Random Grouping - item",
                              "Random Grouping - both",
                              "Fixed Cycling",
                              "Random Cycling - factor",
                              "Random Cycling - item",
                              "Random Cycling - both"
                          ),
                          selected = "Fixed order"),
                      conditionalPanel(
                          condition = "input.select.includes('Fixed order')",
                          numericInput(
                              inputId = "n_subj_fx",
                              label = "N_subj for Fixed order",
                              value = 3)),
                      conditionalPanel(
                          condition = "input.select.includes('Simple randomization')",
                          numericInput(
                              inputId = "n_subj_rd",
                              label = "N_subj for Simple randomization",
                              value = 3)),
                      conditionalPanel(
                          condition = "input.select.includes('Permuted-Subblock Randomization (PSR)')",
                          numericInput(
                              inputId = "n_subj_psr",
                              label = "N_subj for PSR",
                              value = 3)),
                      conditionalPanel(
                          condition = "input.select.includes('Latin Square')",
                          numericInput(
                              inputId = "n_subj_ls",
                              label = "N_subj for (each row of) Latin Square",
                              value = 3)),
                      conditionalPanel(
                          condition = "input.select.includes('Fixed Grouping')",
                          numericInput(
                              inputId = "n_subj_gff",
                              label = "N_subj for Fixed Grouping",
                              value = 3)),
                      conditionalPanel(
                          condition = "input.select.includes('Random Grouping - factor')",
                          numericInput(
                              inputId = "n_subj_grf",
                              label = "N_subj for Random Grouping - factor",
                              value = 3)),
                      conditionalPanel(
                          condition = "input.select.includes('Random Grouping - item')",
                          numericInput(
                              inputId = "n_subj_gfr",
                              label = "N_subj for Random Grouping - item",
                              value = 3)),
                      conditionalPanel(
                          condition = "input.select.includes('Random Grouping - both')",
                          numericInput(
                              inputId = "n_subj_grr",
                              label = "N_subj for Random Grouping - both",
                              value = 3)),
                      conditionalPanel(
                          condition = "input.select.includes('Fixed Cycling')",
                          numericInput(
                              inputId = "n_subj_cff",
                              label = "N_subj for Fixed Cycling",
                              value = 3)),
                      conditionalPanel(
                          condition = "input.select.includes('Random Cycling - factor')",
                          numericInput(
                              inputId = "n_subj_crf",
                              label = "N_subj for Random Cycling - factor",
                              value = 3)),
                      conditionalPanel(
                          condition = "input.select.includes('Random Cycling - item')",
                          numericInput(
                              inputId = "n_subj_cfr",
                              label = "N_subj for Random Cycling - item",
                              value = 3)),
                      conditionalPanel(
                          condition = "input.select.includes('Random Cycling - both')",
                          numericInput(
                              inputId = "n_subj_crr",
                              label = "N_subj for Random Cycling - both",
                              value = 3))
                      ),

    tags$head(tags$style(HTML("
        #select { width: 100%; max-width: none; }
        #select .checkbox label { white-space: nowrap; }
        #order_plan table { width: auto !important; }
        #order_plan th, #order_plan td {
            padding: 4px 12px !important;
            white-space: nowrap;
        }
    "))),

    ## downloadButton(
    ##     outputId = "download",
    ##     label = "Download order datasets"
    ## ),
    div(
        style = "display: flex; align-items: center; gap: 0.75rem; flex-wrap: wrap;",
        downloadButton(
            outputId = "download",
            label = "Download orders"
        ),
        actionButton(
            inputId = "stop_app",
            label = "Finish and exit",
            class = "btn-outline-danger"
        )
    ),

    navset_card_underline(
        title = "orders",
        ## panel 1 shows raw data
        nav_panel(title = "raw data",
                  tableOutput(outputId = "order_frame")),
        ## panel 2 enables multiple randomization strategies
        nav_panel(title = "builder",
                  textOutput(outputId = "strategy"),
                  tableOutput(outputId = "plan")),
        ## Show the condition label at each generated item position
        nav_panel(title = "condition distribution",
                  textOutput(outputId = "condition_strategy"),
                  tableOutput(outputId = "condition_distribution")),
        ## panel 3 shows assignment plan
        nav_panel(title = "plan",
                  tableOutput(outputId = "order_plan")),
        ## panel 4 shows usage for each strategy
        nav_panel(title = "help page",
                  fluidRow(
                      includeMarkdown("./description.md")
                  ))
    )
)

server <- function(input, output, session){

    observeEvent(input$clear_all, {
        updateCheckboxGroupInput(session, "select", selected = character(0))
        for (suffix in c("fx", "rd", "psr", "ls", "gff", "grf", "gfr",
                         "grr", "cff", "crf", "cfr", "crr")) {
            updateNumericInput(session, paste0("n_subj_", suffix), value = 0)
        }
    })

    observeEvent(input$stop_app, {
        shiny::stopApp()
    })
    
    get_data <- reactive({
        req(input$file)
        data <- suppressMessages(
            readr::read_csv(input$file$datapath))
    })

    get_n <- reactive({
        subj_ls <- c(fx = input$n_subj_fx,
                     rd = input$n_subj_rd,
                     psr = input$n_subj_psr,
                     ls = input$n_subj_ls,
                     gff = input$n_subj_gff,
                     grf = input$n_subj_grf,
                     gfr = input$n_subj_gfr,
                     grr = input$n_subj_grr,
                     cff = input$n_subj_cff,
                     crf = input$n_subj_crf,
                     cfr = input$n_subj_cfr,
                     crr = input$n_subj_crr)
    })

    get_order <- reactive({
        req(input$file, input$select)
        algorithms <- c(
            "Fixed order", "Simple randomization",
            "Permuted-Subblock Randomization (PSR)", "Latin Square",
            "Fixed Grouping", "Random Grouping - factor",
            "Random Grouping - item", "Random Grouping - both",
            "Fixed Cycling", "Random Cycling - factor",
            "Random Cycling - item", "Random Cycling - both"
        )
        selected_n <- get_n()[match(input$select, algorithms)]
        validate(need(
            length(selected_n) == length(input$select) &&
                all(is.finite(selected_n) & selected_n > 0 &
                    selected_n == floor(selected_n)),
            "Enter a positive whole-number sample size for each selected algorithm."
        ))
        generate_plan(data = tidy_scale(get_data()),
                      plan_ls = input$select,
                      subj_ls = get_n(),
                      seed = input$Seed)
    })

    get_condition_distribution <- reactive({
        req(input$file, input$select)
        orders <- get_order()
        items <- tidy_scale(get_data())
        position_cols <- grep("^p[0-9]+$", names(orders), value = TRUE)

        # Reuse the generated orders; do not randomize a second time.
        orders[position_cols] <- lapply(orders[position_cols], function(ids) {
            as.character(items$label[match(ids, items$q_num)])
        })
        orders
    })

    get_plan <- reactive({
        plan_subj(plan = get_order(),
                  subj_ls = get_n())
    })
    
    ## dynamic output for panel "data"
    output$order_frame <- renderTable({
        if(length(input$file) == 0) {
            paste('Select a file from "scalepool" directory to start.')
        } else {
            get_data()
        }
    })
    
    ## Both panels describe the same selected strategies.
    strategy_text <- reactive({
        if (length(input$select) == 0) return("")
        paste0("Current plans: ", paste(input$select, collapse = ", "), ".")
    })

    output$strategy <- renderText({ strategy_text() })
    output$condition_strategy <- renderText({ strategy_text() })

    ## Missing input is guidance, not an application error.
    output$plan <- renderTable({
        validate(
            need(!is.null(input$file), "Select a questionnaire CSV to start."),
            need(length(input$select) > 0, "No strategy has been selected yet.")
        )
        get_order()
    })

    output$condition_distribution <- renderTable({
        validate(
            need(!is.null(input$file), "Select a questionnaire CSV to start."),
            need(length(input$select) > 0, "No strategy has been selected yet.")
        )
        get_condition_distribution()
    })

    ## dynamic output for panel "plan"
    output$order_plan <- renderTable({
        validate(
            need(!is.null(input$file), "Select a questionnaire CSV to start."),
            need(length(input$select) > 0, "No strategy has been selected yet.")
        )
        get_plan()
    }, spacing = "xs", width = "auto")

    ## refer to ui for output on panel 'description'.
    output$download <- downloadHandler(
        filename = function(){"df-order.zip"},
        content = function(file) {
            tmpdir <- tempdir()
            setwd(tempdir())
            fnames <- c("df-order.csv", "df-plan.csv")
            write.csv(get_order(), file = fnames[1])
            write.csv(get_plan(), file = fnames[2])

            zip::zip(zipfile = file, files = fnames)
        },
        contentType = "application/zip"
    )

    ## output$download <- downloadHandler(
    ##     filename = function(){"df-plan.csv"},
    ##     content = function(file) {
    ##         write.csv(get_plan(), file)
    ##     }
    ##     )
}

app_port <- as.numeric(Sys.getenv("SHINY_PORT"))

suppressWarnings({
    shinyApp(ui = ui, server = server,
             options = list(
                 port = app_port,
                 host = "0.0.0.0"))
})

