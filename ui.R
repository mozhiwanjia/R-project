#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(shinydashboard)
library(dygraphs)
library(plotly)

Crash_severity<- c(
  "all"="all",
  "Fatal"="Fatal",
  "Hospitalisation"="Hospitalisation",
  "Medical treatment" ="Medical treatment",
  "Minor injury"="Minor injury",
  "Property damage only"="Property damage only"
)

speed <- c(
  "All" = "all",
  "0-50Km/h" = "0 - 50 km/h",
  "60Km/h" = "60 km/h",
  "70Km/h" = "70 km/h",
  "80-90Km/h" = "80 - 90 km/h",
  "100-110Km/h" = "100 - 110 km/h"
)

Vertial <- c(
  "All" = "all",
  "Crest" ="Crest",
  "Level" ="Level",
  "Grade" = "Grade",
  "Dip" ="Dip"
)

Horizon <- c(
  "All" = "all",
  "Curve-View Open" = "Curved - view open",
  "Straight" = "Straight",
  "Curved - view obscured" = "Curved - view obscured"
)


dashboardPage(
  dashboardHeader(title = "Noosa Shire Area"),
  dashboardSidebar(
    sidebarMenu(
      menuItem(
        "Maps", 
        tabName = "Car crash maps", 
        icon = icon("globe"),
        menuSubItem("Road View", tabName = "m_all", icon = icon("map")),
        menuSubItem("Crash Type", tabName = "m_pop", icon = icon("map"))
      ),
      menuItem(
        "Charts", 
        tabName = "Analysising Chart", 
        icon = icon("bar-chart"),
        menuSubItem("Time of Crash", tabName = "c_g", icon = icon("bar-chart")),
        menuSubItem("Crash Description Summary", tabName = "c_b", icon = icon("bar-chart")),
        menuSubItem("Casualty Number", tabName = "c_t", icon = icon("line-chart")),
        menuSubItem("Speed Limitation", tabName = "c_s", icon = icon("bar-chart"))
      )
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "m_all",
        box(
          title = "Road Surface and View Condition",
          collapsible = TRUE,
          width = "100%",
          height ="950px",
          leafletOutput("Go_map",width="100%",height="800px")
        ),
        
        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                      draggable = FALSE, top = 150, left = "auto", right = 20, bottom = "auto",
                      width = "auto", height = "auto",
                      hr(),
                      selectInput("speed", "Speed Limited", speed, selected = "All"),
                      selectInput("Vertical","Vertical Condition",Vertial,selected = "All" ),
                      selectInput("Horizon", "Horizon Condition", Horizon, selected = "All")
                     
        )
      ),
      tabItem(
        tabName = "m_pop",
        fluidRow(
          column(3,
                 wellPanel(
                   h4("Crash Type Navigation"),
                   selectInput("Crash_severity", "Crash Severity",Crash_severity,selected = "All"),
                   checkboxGroupInput("Crash_nature","Crash Description",
                                      c(
                                        "Head-on"= "Head-on",
                                        "Hit object"= "Hit object",
                                        "Collision - miscellaneous" = "Collision - miscellaneous",
                                        "Angle"="Angle",
                                        "Fall from vehicle"="Fall from vehicle",
                                        "Hit animal"="Hit animal",
                                        "Hit parked vehicle" ="Hit parked vehicle",
                                        "Hit pedestrian"="Hit pedestrian",
                                        "Non-collision - miscellaneous"="Non-collision - miscellaneous",
                                        "Overturned"="Overturned",
                                        "Rear-end" ="Rear-end",
                                        "Sideswipe"="Sideswipe",
                                        "Struck by external load"="Struck by external load"
                                        )
                                      ),
                     plotOutput("weekPlot")
                 )),
          column(9,
                   leafletOutput("Go_map2",width="100%",height="920px")
                 ))),
      tabItem(
        tabName = "c_g",
        box(
                  title = "Time of Crash",
                  collapsible = TRUE,
                  width = "100%",
                  height ="950px",
                  plotlyOutput("timePlot", width = "100%", height = "1000px")
              )),
      tabItem(
            tabName = "c_b",
            box(
                      title = "Description of Crash",
                      collapsible = TRUE,
                      width = "100%",
                      height ="950px",
                      plotOutput("typePlot", height = "800px")
                    )),
      tabItem(
        tabName = "c_t",
        tabBox(
          title = "Casualty Flow",
          width = "100%",
          height = "950px",
          tabPanel("Total Casualty",plotlyOutput("TotalCaualty")),
          tabPanel("Fatalilty Casualty", plotlyOutput("Fatality")),
          tabPanel("Hospitalised Casualty", plotlyOutput("Hospitalised")),
          tabPanel("Medically Treat Casualty", plotlyOutput("Medically")),
          tabPanel("Minor Injury", plotlyOutput("Minor"))
        )
      ),
      tabItem(
          tabName = "c_s",
          fluidRow(
            column(3,
                   wellPanel(
                     h4("Speed limitation and Crash Severity"),
                     checkboxGroupInput("Crash_severity2","Crash Severity",
                                        c(
                                          "all"="all",
                                          "Fatal"="Fatal",
                                          "Hospitalisation"="Hospitalisation",
                                          "Medical treatment" ="Medical treatment",
                                          "Minor injury"="Minor injury",
                                          "Property damage only"="Property damage only")
                                         ))),
                     column(
                       9, plotOutput("Speed",width = "auto", height = "800px")
                     )
                     
            )
          )
      )
    ))
