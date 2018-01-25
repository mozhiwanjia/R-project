#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(ggplot2)
library(ggmap)
library(leaflet)
library(dygraphs)
library(plotly)
mydata <- read.csv("/Users/111/Desktop/1/5147/1.csv", header = TRUE)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  formulaMap <- reactive(
    {
      if(input$speed == "all"&&input$Vertical =="all"&&input$Horizon == "all"){
        newdata <- mydata;
        }
      else if (input$speed != "all"&&input$Vertical =="all"&&input$Horizon == "all"){
        newdata <- subset(mydata, mydata$Speed_limit == input$speed);
      }
      else if (input$speed != "all"&&input$Vertical !="all"&&input$Horizon == "all"){
      newdata <- subset(mydata, mydata$Speed_limit == input$speed & mydata&mydata$Vertical_alignment == input$Vertical);
      }
      else if (input$speed != "all"&&input$Vertical !="all"&&input$Horizon != "all"){
        newdata <- subset(mydata, mydata$Speed_limit == input$speed & mydata&mydata$Vertical_alignment == input$Vertical & mydata$Horizon_alignment == input$Horizon);
      }
      else if (input$speed == "all"&&input$Vertical !="all"&&input$Horizon != "all"){
        newdata <- subset(mydata, mydata&mydata$Vertical_alignment == input$Vertical&mydata$Horizon_alignment == input$Horizon );
      }
      else if(input$speed != "all"&&input$Vertical =="all"&&input$Horizon != "all"){
        newdata <- subset(mydata,  mydata$Horizon_alignment == input$Horizon & mydata$Speed_limit == input$speed);
      }
      else if(input$speed == "all"&&input$Vertical !="all"&&input$Horizon == "all"){
        newdata <- subset(mydata, mydata&mydata$Vertical_alignment == input$Vertical );
      }  
    }
  )
  
  formulaDesc <- reactive({
    if(input$Crash_severity == "all") {
    dataNew <- subset(mydata,  mydata$Crash_nature == input$Crash_nature)
    } else if (input$Crash_severity!="all") {
    dataNew <- subset(mydata, mydata$Crash_severity == input$Crash_severity & mydata$Crash_nature==input$Crash_nature)
    }
  })
  
  formulaSpeed <- reactive({
    if(input$Crash_severity2 == "all") {
      SpeedData <- do.call(cbind.data.frame, aggregate(ID~Speed_limit + Crash_severity, data = mydata, length))
    } else {
      SpeedData <- do.call(cbind.data.frame, aggregate(ID~Speed_limit + Crash_severity, data = mydata, length))
      SpeedData <- subset(SpeedData, SpeedData$Crash_severity == input$Crash_severity2)
    }
  })
  
  
##This is map for the Overview from government perspective, These code is mainly explore a map for government to explore What are road conditions which cause crashs 
  observe({
    pal <- colorFactor(
      palette = 'Dark2',
      domain = mydata$Speed_limit
    )
  
                                     output$Go_map <- renderLeaflet({
                                      leaflet(data = formulaMap()) %>%
                                        addTiles()%>%
                                        addCircles(~Longitude,~Latitude,
                                                   color=~pal(Speed_limit)) %>%
                                         addLegend("bottomleft", pal = pal, values = mydata$Speed_limit, title = "Color Legend", layerId = "colorLegend")
                                      
                                                 ##clusterOptions  = markerClusterOptions())
                                       
                                     })
                                    
  })
                                       output$Bu_map <- renderLeaflet({
                                         leaflet(data = formulaMap()) %>%
                                           addTiles()%>%
                                           addCircles(~Longitude,~Latitude
                                                      # popup =paste(
                                                      #   "<strong>Crash_severity</strong>",formulaMap()$Crash_serverity, "<br>",
                                                      #   "<strong>Casualty</strong>",formulaMap()$Casualty_total, "<br>",
                                                      #   "<strong>Year:</strong>", formulaMap()$Year, "<br>", 
                                                      #   "<strong>Speed:</strong>", formulaMap()$Speed_limit, "<br>",
                                                      #   labelOptions = labelOptions(noHide = T)
                                                      # )
                                                      )
                                                      
                                         selectedData <- do.call(cbind.data.frame, aggregate(ID~input$Type + Year, data = mydata ,length))
                         
                                       })
                                       output$timePlot <- renderPlotly({
                                         timeData <- do.call(cbind.data.frame, aggregate(ID~Time, data = mydata, length))
                                         p <- ggplot(data = timeData, aes(x = Time, y = ID)) + labs(x = "Time") + labs(y = "Crashes") + geom_bar(stat = "identity")
                                         p = ggplotly(p, width = 1300, height = 800, autosize = T)
                                         p
                                       })
                                       
                                       output$typePlot <- renderPlot({
                                         typeData <- do.call(cbind.data.frame, aggregate(ID~Crash_nature, data = formulaMap(), length))
                                         p <- ggplot(data = typeData, aes(x = Crash_nature, y = ID, fill = Crash_nature, label = ID)) + labs(x = "Type") + labs(y = "Crashes") + geom_bar(stat = "identity") + 
                                           coord_flip() +
                                           geom_text(size = 3, position = position_stack(vjust = 0.5))
                                         p
                                       })
                                       
                                      
                                         
                                         output$Go_map2 <- renderLeaflet({
                                           leaflet(data = formulaDesc()) %>%
                                             addTiles()%>%
                                             addMarkers(~Longitude,~Latitude
                                                        ,popup =paste(
                                                          "<strong>Severity</strong>",formulaDesc()$Crash_severity, "<br>",
                                                          "<strong>Description</strong>",formulaDesc()$Crash_nature, "<br>",
                                                          "<strong>Year:</strong>", formulaDesc()$Year, "<br>", 
                                                          "<strong>Week:</strong>", formulaDesc()$Day_of_week, "<br>"
                                                        ))
                                           
                         
                                       })
                                         
                                       output$weekPlot <- renderPlot({
                                         weekData <- do.call(cbind.data.frame, aggregate(ID~Day_of_week, data = formulaDesc(), length))
                                         p <- ggplot(data = weekData, aes(x = Day_of_week, y = ID, label = ID)) + 
                                           labs(x="Week") + labs(y="Crashes") + 
                                           geom_bar(stat = "identity") + coord_flip() +
                                           geom_text(size = 3, position = position_stack(vjust = 0.5))
                                         p
                                       })
                                       
                                       output$TotalCaualty <- renderPlotly({
                                         TCData <- do.call(cbind.data.frame, aggregate(Casualty_total~Mon, data = mydata, sum))
                                         p <- ggplot(data = TCData, aes(x = Mon, y = Casualty_total, group = 1, label = Casualty_total)) +
                                           labs(x="Month") + labs(y = "Num of Crashes") +
                                           geom_line() + geom_text(size = 4)
                                         p = ggplotly(p, width = 1300, height = 800, autosize = T)
                                         p
                                       })
                                       
                                       output$Fatality <- renderPlotly({
                                         FCData <- do.call(cbind.data.frame, aggregate(Fatality_count~Mon, data = mydata, sum))
                                         p <- ggplot(data = FCData, aes(x = Mon, y = Fatality_count, group = 1, label = Fatality_count)) +
                                           labs(x="Month") + labs(y = "Num of Crashes") +
                                           geom_line() + geom_text(size = 5)
                                         p = ggplotly(p, width = 1300, height = 800, autosize = T)
                                         p
                                       })
                                       
                                       output$Hospitalised <- renderPlotly({
                                         HCdata <- do.call(cbind.data.frame, aggregate(Hospitalised_count~Mon, data = mydata, sum))
                                         p <- ggplot(data = HCdata, aes(x = Mon, y = Hospitalised_count, group = 1, label = Hospitalised_count)) +
                                           labs(x="Month") + labs(y = "Num of Crashes") +
                                           geom_line() + geom_text(size = 4)
                                         p = ggplotly(p, width = 1300, height = 800, autosize = T)
                                         p
                                       })
                                       
                                       output$Medically <- renderPlotly({
                                         MTCdata <- do.call(cbind.data.frame, aggregate(Medically_treated_count~Mon, data = mydata, sum))
                                         p <- ggplot(data = MTCdata, aes(x = Mon, y = Medically_treated_count, group = 1, label = Medically_treated_count)) +
                                           labs(x="Month") + labs(y = "Num of Crashes") +
                                           geom_line() + geom_text(size = 4)
                                         p = ggplotly(p, width = 1300, height = 800, autosize = T)
                                         p
                                       })
                                       
                                       output$Minor <- renderPlotly({
                                         MIdata <- do.call(cbind.data.frame, aggregate(Minor_injury_count~Mon, data = mydata, sum))
                                         p <- ggplot(data = MIdata, aes(x = Mon, y = Minor_injury_count, group = 1, label = Minor_injury_count)) +
                                           labs(x="Month") + labs(y = "Num of Crashes") +
                                           geom_line() + geom_text(size = 4)
                                         p = ggplotly(p, width = 1300, height = 800, autosize = T)
                                         p
                                       })
                                       
                                       output$Speed <- renderPlot({
                                         p <- ggplot(data = formulaSpeed(), aes(x=Speed_limit, y=ID, fill = Crash_severity)) +
                                           labs(x="Speed") + labs(y = "Crashes") +
                                           geom_bar(stat = "identity")
                                         p
                                       })
                                       
                                    
          
  
})
