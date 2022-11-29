shinyServer(function(input, output, session) {
    
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

    #Creating the default map using module
    callModule(viz_leaflet_map_srv, "map", data = df_poland, data_poly = poly_poland)
    
    #Using leafletProxy to change the map according the change of the filters.
    observe({
        
        if((length(input[["type_choices-vernacularName"]])==0 & length(input[["type_choices-scientificName"]])==0) | nrow(data_filtered()) == 0){
          leafletProxy('map-map_viz') %>% clearMarkers()
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
          
          leafletProxy('map-map_viz', data = coords) %>% 
            clearMarkers() %>% 
            addProviderTiles(provider = providers$CartoDB.DarkMatter) %>% 
            leaflet::addAwesomeMarkers(group = "inf",
                                      lng = ~longitudeDecimal, lat = ~latitudeDecimal,
                                      label = coords$label, 
                                      labelOptions=labelOptions(textsize = "12px"),
                                      popup = ~ if_else(is.na(accessURI), 
                                                        'Image not available', 
                                                        paste0("<img src = ", accessURI, " width = 150>")
                                                        ),
                                      options = popupOptions(closeButton = T, textsize = "10px", keepInView = T)
                                      )
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
               title_name = 'Bar chart of the taxonRank.')
    
    callModule(viz_bar_chart_srv, "chart_bar_kingdom", data = data_filtered, 
               var = kingdom, var_name = 'kingdom', 
               title_name = 'Bar chart of the kingdom.')
    
    callModule(viz_bar_chart_srv, "chart_bar_lifeStage", data = data_filtered, 
               var = lifeStage, var_name = 'lifeStage',
               title_name = 'Bar chart of the lifeStage.')
    
    callModule(viz_bar_chart_srv, "chart_bar_sex", data = data_filtered, 
               var = sex, var_name = 'sex',
               title_name = 'Bar chart of the sex.')
    
    #Time line
    callModule(viz_timeline_srv, "timeline", data = data_filtered, today = eventDate)
    
    
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
    
    #Part that make the extra filter appear.
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
    
    
    
}) 
