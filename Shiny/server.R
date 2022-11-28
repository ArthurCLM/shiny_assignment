shinyServer(function(input, output, session) {
    
    output$menu <- renderMenu({
        mylist <- list(menuItem("Species", tabName = "species", icon = shiny::icon('tree')))
        shinydashboard::sidebarMenu(mylist)
        
    })
    
    observeEvent(c(input[["type_choices-vernacularName"]], input[["type_choices-scientificName"]]),{
      output$get_only_image_id <- renderUI({
        if(length(input[["type_choices-vernacularName"]])>0 | length(input[["type_choices-scientificName"]])>0){
          awesomeCheckbox(
            inputId = "only_image_id",
            label = "Only spots with images available?",
            value = FALSE,
            status = "success"
          )
        }

      })
    })

    observeEvent(input[["type_choices-reset_all"]],{
      updateAwesomeCheckbox(session = session, inputId = "only_image_id", value = FALSE)
    })
      
    #The first data that is filtered by the columns 'vernacularName' and 'scientificName'
    data_type_choices <- callModule(
      module = selectizeGroupServer,
      id = "type_choices",
      data = df_poland,
      vars = c("vernacularName", "scientificName")
      )
      
    #The second data that is filtered by if the observation/specie has a image.
    data_filtered <- reactive({
      if(isTRUE(input$only_image_id)){
        data_type_choices() %>% filter(!is.na(accessURI))
      }else{
        data_type_choices()
        }
      })

    #Creating the default map
    output$map <- renderLeaflet({
      leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
      addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
      addPolygons(data= poly_poland, stroke = TRUE, 
                  opacity = 1.5, 
                  weight = 1, 
                  fill = T,
                  smoothFactor = 0.2,
                  fillOpacity = 0.2,
                  color = '#0d8a01',
                  fillColor = '#0d8a01',
                  label = list(HTML(paste0("<strong>Country</strong>: ", str_to_upper(poly_poland$NAME_0),
                                             "<br/>",
                                             "<strong>Number of observations</strong>: ", nrow(df_poland),
                                             "<br/>",
                                             "<strong>Number of images available</strong>: ", length(na.omit(df_poland$accessURI)),
                                             "<br/>")
                                    )))

    })
    
    #Using leafletProxy to change the map according the change of the filters.
    observe({
        
        if((length(input[["type_choices-vernacularName"]])==0 & length(input[["type_choices-scientificName"]])==0) | nrow(data_filtered()) == 0){
          leafletProxy('map') %>% clearMarkers()
        }else{

          coords <- data_filtered() %>%  
            rowwise() %>%
            dplyr::mutate(label = list(HTML(paste0("<strong>Id</strong>: ", id,
                                                   "<br/>",
                                                   "<strong>Country</strong>: ", country,
                                                   "<br/>",
                                                   "<strong>Vernacular Name</strong>: ", vernacularName,
                                                   "<br/>",
                                                   "<strong>Scientific Name</strong>: ", scientificName,
                                                   "<br/>",
                                                   "<strong>Kingdom</strong>: ", kingdom,
                                                   "<br/>",
                                                   "<strong>Family</strong>: ", family,
                                                   "<br/>",
                                                   "<strong>Sex</strong>: ", sex,
                                                   "<br/>",
                                                   "<strong>Date</strong>: ",eventDate,
                                                   "<br/>",
                                                   "<strong>Image available?</strong>: ", if_else(is.na(accessURI), 'No', 'Yes!'))))) %>% 
            ungroup
          
          leafletProxy('map', data = coords) %>% 
            clearMarkers() %>% 
            addProviderTiles(provider = providers$CartoDB.DarkMatter) %>% 
            leaflet::addCircleMarkers(radius = 4,
                                      group = "points",
                                      color = '#0d8a01',
                                      lng = ~longitudeDecimal, lat = ~latitudeDecimal,
                                      weight = 2, 
                                      stroke = T,
                                      opacity = 1, label = coords$label, 
                                      popup = ~ if_else(is.na(accessURI), 
                                                        'Image not available', 
                                                        paste0("<img src = ", accessURI, " width = 200>"))) 
          
        }
    })
    
    # Table of timeline of the observed species and the timeline chart, all of these in callModule
    callModule(viz_timeline_table_srv, "table_timeline", data = data_filtered, 
               id, eventDate, latitudeDecimal, longitudeDecimal,
               vernacularName, scientificName, country, kingdom, family)
         
    callModule(viz_timeline_chart_srv, "chart_timeline", data = data_filtered, 
               today = eventDate,
               title_name = 'Timeline of the species that were observed.')
    
    # Bar charts callModule for taxi Rank, kingdom, lifeStage, sex, respectively.
    callModule(viz_bar_chart_srv, "chart_bar_taxonRank", data = data_filtered, 
               var = taxonRank, var_name = 'taxonRank',
               title_name = 'Bar chart of the taxonRank of those species that were observed.')
    
    callModule(viz_bar_chart_srv, "chart_bar_kingdom", data = data_filtered, 
               var = kingdom, var_name = 'kingdom', 
               title_name = 'Bar chart of the kingdom of those species that were observed.')
    
    callModule(viz_bar_chart_srv, "chart_bar_lifeStage", data = data_filtered, 
               var = lifeStage, var_name = 'lifeStage',
               title_name = 'Bar chart of the lifeStage of those species that were observed.')
    
    callModule(viz_bar_chart_srv, "chart_bar_sex", data = data_filtered, 
               var = sex, var_name = 'sex',
               title_name = 'Bar chart of the sex of those species that were observed.')
    
    #Shinyalert if in one time there is no observation to see.
    shiny::observeEvent(input$only_image_id, {
      if (isTRUE(input$only_image_id) & nrow(data_filtered())==0) {
        shinyWidgets::sendSweetAlert(
          session = session,
          title = "Information.",
          text =  "There isn't image available for this selection.",
          type = "warning"
        )
      }
    })
    
    #Switch button just to switch
    shiny::observeEvent(input$switch, {
        if (input$switch != TRUE) {
            shinyjs::addClass(selector = "body", class = "sidebar-collapse")
        } else {
            shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
        }
    })

    
}) 
