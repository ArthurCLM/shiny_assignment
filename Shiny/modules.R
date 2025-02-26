#Responsable to do the
viz_leaflet_map_ui<-function(id, height){
  ns <- NS(id)
  leafletOutput(ns("map_viz"), height = height)
}

viz_leaflet_map_srv<-function(input, output, session, data, data_poly){
  
  output$map_viz <- renderLeaflet({
    leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
      addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
      addPolygons(data = data_poly, stroke = TRUE, 
                  group = 'poly',
                  opacity = 1.5, 
                  weight = 1, 
                  fill = T,
                  smoothFactor = 0.2,
                  fillOpacity = 0.2,
                  color = '#0d8a01',
                  fillColor = '#0d8a01',
                  label = list(HTML(paste0("<strong>Country</strong>: ", str_to_upper(data_poly$NAME_0),
                                           "<br/>",
                                           "<strong>Number of observations</strong>: ", nrow(data),
                                           "<br/>",
                                           "<strong>Number of images available</strong>: ", length(na.omit(data$accessURI)),
                                           "<br/>")
                  )),
                  labelOptions=labelOptions(textsize = "10px"))
    
  })
  
}



#Responsable to do the
viz_timeline_table_ui<-function(id){
  ns <- NS(id)
  DT::DTOutput(ns("tbl_viz"))
}

viz_timeline_table_srv<-function(input, output, session, data, ...){
  vars <- quos(...)
  
  output$tbl_viz <- DT::renderDT(server = T,{
    
    data() %>% 
      select(!!!vars) %>% 
      `colnames<-`(str_to_upper(names(.))) %>% 
      DT::datatable(extensions = c('Buttons',"Scroller"), options = list(
        dom = "Bfrpt",
        scrollX = TRUE,
        scrollY = TRUE,
        pageLength = 10,
        buttons = list(
          list(extend = 'excel', filename = "Table_timeline_species"))
      ),
      selection = list(mode = "single", selected = c(1)),
      class = "cell-border stripe",
      rownames = FALSE
      )
    
    
  })
  
}

#Responsable to do the timeline chart
viz_timeline_chart_ui<-function(id){
  ns <- NS(id)
  plotly::plotlyOutput(ns("plotly"), height = 250, width = '99%')
}

viz_timeline_chart_srv<-function(input, output, session, data, today, title_name){
  today <- enquo(today)
  output$plotly <- renderPlotly({
    
    data() %>%
      count(!!today) %>%
      plotly::plot_ly(x = today, y = ~n,
                      mode = 'lines+markers') %>% 
      layout(title = title_name, 
             plot_bgcolor = "#e5ecf6", 
             xaxis = list(title = 'Event Date'), 
             yaxis = list(title = 'Quantitative'))
    
  })
  
}

#Responsable to do the extra bar_charts
viz_bar_chart_ui<-function(id){
  ns <- NS(id)
  echarts4r::echarts4rOutput(ns("bar_charts"), width = '100%')
}

viz_bar_chart_srv<-function(input, output, session, data, var, var_name, title_name){
  var <- enquo(var)
  
  output$bar_charts <- echarts4r::renderEcharts4r({
    
  data() %>%
      count(!!var) %>%
      arrange(n)  %>% 
      e_charts_(x = var_name) %>%
      e_bar(serie = n, legend = FALSE, name = "Quantitative") %>%
      e_tooltip() %>%
      e_title(title_name) %>%
      e_y_axis(splitLine = list(show = TRUE)) %>%
      e_x_axis(show = TRUE)
    
  })
  
}

#Responsable to do the timeline
viz_timeline_ui<-function(id){
  ns <- NS(id)
  shiny::uiOutput(ns("viz_timeline"))
}

viz_timeline_srv<-function(input, output, session, data, today){
  today <- enquo(today)
  
      output$viz_timeline <- renderUI({
        
        min_year <- data() %>% pull(!!today) %>% min()
        max_year <- data() %>% pull(!!today) %>% max()
        
        if(nrow(data()) == nrow(df_poland) | nrow(data()) == 0){
          compile_result <- NULL
          
        }else{
          
          result <- lapply(1:nrow(data()), function(i){
            each <- data()[i,]
            information <- paste0("Locality: ", each$locality, '              ', "Name: ", each$scientificName)
            glue('bs4TimelineItem(title="",icon=icon("check"), color = "teal",time="", footer="{each$eventDate}",
            "{information}", border = F)')
          })
          
          compile_result <- lapply(1:length(result), function(i){
            eval(parse(text = result[i]))
          })
          
          
        }
        
        bs4Timeline(width = "100%", 
                    height='100%',
                    reversed = TRUE,
                    timelineEnd(color = "danger"),
                    bs4TimelineLabel(paste0("First occurence: ", min_year), status = "info"),
                    compile_result,
                    bs4TimelineLabel(paste0("Last occurence: ", max_year), status = "info"),
                    timelineStart(color = "secondary")
        )
    
  })
  
}