header <- dashboardHeader(title = 'Biodiversity dashboard assignment', titleWidth = '100%', disable = F)

sidebar <- dashboardSidebar(
    disable = TRUE,
    sidebarMenu(
        sidebarMenuOutput("menu")
    )
)

body <- dashboardBody(
    includeCSS("www/dashshiny.css"),
    shinyjs::useShinyjs(),
    shinyWidgets::prettySwitch(
        inputId = "switch",
        label = NULL, 
        status = "success",
        fill = TRUE, 
        value = TRUE
    ),
    tabItems(
    tabItem(
        tabName = "species",
        fluidRow(
            column(width = 6,
                   panel(
                       selectizeGroupUI(
                           id = "type_choices",
                           inline = TRUE,
                           params = list(
                               vernacularName = list(inputId = "vernacularName", title = "Vernacular Name:"),
                               scientificName = list(inputId = "scientificName", title = "Scientific Name:")
                               )
                           ),
                       status = "success"
                        )
                    ),
            column(width = 6,
                   uiOutput(outputId = 'get_only_image_id')
                   ),
            tabBox(
                id = "results", 
                width = 12, 
                title = tagList(shiny::icon("far fa-chart-bar"), "Results"),
                tabPanel(title = tagList(shiny::icon("map"), "Map"),
                         h4("Location of the selected species."),
                         leafletOutput(outputId = 'map', height = 850)
                         ),
                tabPanel(title = tagList(shiny::icon("table"), "Table"),
                         h4("Table of the species that were observed."),
                         viz_timeline_table_ui(id = "table_timeline")
                         ),
                tabPanel(title = tagList(shiny::icon("chart-line"), "Chart Line"),
                         viz_timeline_chart_ui(id = "chart_timeline")
                         ),
                tabPanel(title = tagList(shiny::icon("chart-pie"), "More charts"),
                         fluidRow(
                         column(width = 6, viz_bar_chart_ui(id = "chart_bar_taxonRank")),
                         column(width = 6, viz_bar_chart_ui(id = "chart_bar_kingdom")),
                         column(width = 6, viz_bar_chart_ui(id = "chart_bar_lifeStage")),
                         column(width = 6, viz_bar_chart_ui(id = "chart_bar_sex"))
                         )
                )
                )
            )
        )
    )
)

dashboardPage(skin = "green", header, sidebar, body)


