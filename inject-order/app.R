library(shiny)
library(bslib)
library(tidyverse)

source("./default.R")

readRenviron("/var/.env")

ui <- page_sidebar(
    title = "Order builder",
    sidebar = sidebar(helpText = "Randomization strategies",
                      fileInput(
                          inputId = "file", label = NULL,
                          accept = c("text/csv",
                                     "text/comma-separated-values",
                                     ".csv"
                                     )
                      ),
                      numericInput(
                          inputId = "Seed",
                          label = "seed",
                          value = 1
                      ),
                      checkboxGroupInput(
                          inputId = "select",
                          label = "Select Option",
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

server <- function(input, output){

    observeEvent(input$stop_app, {
        shiny::stopApp()
    })
    
    get_data <- reactive({
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
        generate_plan(data = tidy_scale(get_data()),
                      plan_ls = input$select,
                      subj_ls = get_n(),
                      seed = input$Seed)
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
    
    ## dynamic output for panel "builder"
    output$strategy <- renderText({
        if(is.null(input$file)){
            stop('Select a file from "scalepool" directory to start.')
        } else {text <- paste("Current plans:", paste(input$select, collapse = ", "), ".")}
    })

    output$plan <- renderTable({
        if(is.null(input$select)){
            paste("No strategy has been selected yet.")
        } else {   
            ## ------ here is how you generate your data ------
            ## plan_df <- generate_plan(data = tidy_scale(get_data()),
            ##                          plan_ls = input$select,
            ##                          subj_ls = get_n())
            ## ------
            plan_df <- get_order()
        }})

    ## dynamic output for panel "plan"
    output$order_plan <- renderTable({
        if(is.null(input$select)){
            paste("No strategy has been selected yet.")
        } else {
            f.order <- get_plan()
            ## plan_subj(plan = output$plan,
            ##                  subj_ls = get_n())
        }
    })
    
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

app_port <- as.integer(Sys.getenv("SHINY_PORT"))

shinyApp(ui = ui, server = server,
         options = list(
             port = app_port,
             host = "0.0.0.0"))
