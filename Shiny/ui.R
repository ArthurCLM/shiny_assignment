header <- bs4Dash::dashboardHeader(
    title = bs4DashBrand('Biodiversity dashboard assignment', color = 'olive',
                         href = 'https://www.gbif.org/occurrence/search?dataset_key=8a863029-f435-446a-821e-275f4f641165',
                         image = NULL, opacity = 0), border = TRUE, status = 'olive')

sidebar <- dashboardSidebar(disable = TRUE)

body <- dashboardBody(
    includeCSS("www/dashshiny.css"),
    shinyjs::useShinyjs(),
    fluidRow(
        column(
            width = 3,
            bs4Card(
                title = "Filtering Data",
                width = 12,
                status = "olive",
                closable = FALSE,
                maximizable = FALSE,
                collapsible = FALSE,
                solidHeader = TRUE,
                selectizeGroupUI(
                    id = "type_choices",
                    inline = TRUE,
                    params = list(
                        vernacularName = list(inputId = "vernacularName", title = "Vernacular Name:"),
                        scientificName = list(inputId = "scientificName", title = "Scientific Name:")),
                ),
                HTML('<br><br>'),
                uiOutput(outputId = 'get_only_image_id')),
            bs4Card(
                title = "Timeline",
                width = 12,
                style='width:500px;overflow-x: scroll;height:550px;overflow-y: scroll;',
                height='100%',
                status = "olive",
                color="olive",
                closable = FALSE,
                maximizable = FALSE,
                collapsible = FALSE,
                solidHeader = TRUE,
                viz_timeline_ui(id = "timeline")
            )
        ),
        tabBox(
            id = "results",
            width = 9, 
            side = 'right',
            collapsible = F,
            solidHeader = T,
            background = 'white',
            status = 'olive',
            headerBorder = F,
            title = tagList(shiny::icon("far fa-chart-bar"), "Results"),
            tabPanel(title = tagList(shiny::icon("map-location-dot"), "Map"),
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
                         column(width = 6, viz_bar_chart_ui(id = "chart_bar_sex")))
            )
        )
    )
)

dashboardPage(scrollToTop = T, dark = NULL, header, sidebar, body, fullscreen = T,
              preloader = list(html = waiter::spin_3()))


