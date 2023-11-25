library(shiny)
library(shinydashboard)
library(leaflet)

# Définir l'interface utilisateur
ui <- dashboardPage(
  dashboardHeader(title = "Mon Application Shiny"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Carte", tabName = "tabMap", icon = icon("map")),
      menuItem("Tableau", tabName = "tabTable", icon = icon("table")),
      selectInput("param1", "Nombre de fois", choices = c("1 fois", "2 fois", "3 fois")),
      checkboxInput("param2", "Cocher pour 'Bonjour'", value = FALSE)
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "tabMap",
              fluidRow(
                column(12, leafletOutput("map", height = "95vh"))
              )
      ),
      tabItem(tabName = "tabTable", 
              h2(textOutput("salutation"))
      )
    )
  )
)

# Définir la logique du serveur
server <- function(input, output) {
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 2.2137, lat = 46.2276, zoom = 6)
  })
  
  output$salutation <- renderText({
    n <- switch(input$param1,
                "1 fois" = 1,
                "2 fois" = 2,
                "3 fois" = 3)
    message <- if (input$param2) "Bonjour" else "Au revoir"
    paste(rep(message, n), collapse = " ")
  })
}

shinyApp(ui, server)
