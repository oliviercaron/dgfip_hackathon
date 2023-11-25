library(shiny)
library(shinydashboard)
library(plotly)
library(tidyverse)
library(rjson)

# Chargement et préparation des données
communes_data <- read.csv("data/v_commune_2023.csv") %>%
  filter(DEP %in% c(16)) %>%
  select(COM, NCCENR) %>%
  rename(code = COM, nom = NCCENR) %>%
  mutate(cfe = round(runif(n(), min = 2.5, max = 15.7),2)) %>%
  mutate(hover_text = paste0(nom, "<br>", cfe))

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
                column(12, plotlyOutput("map", height = "95vh"))  # Modification ici
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
  output$map <- renderPlotly({  # Utiliser renderPlotly
    url <- 'data/communes-16-charente.geojson'
    geojson <- rjson::fromJSON(file=url)
    g <- list(
      fitbounds = "locations",
      visible = FALSE,
      scope = "france"
    )
    fig <- plot_ly() 
    fig <- fig %>% add_trace(
      type="choroplethmapbox",
      geojson=geojson,
      locations=communes_data$code,
      z=communes_data$cfe,
      text = communes_data$hover_text,
      hoverinfo = "text",
      colorscale="Viridis",
      reversescale=TRUE,
      featureidkey="properties.code",
      marker=list(line=list(
        width=0.5),
        opacity=0.8
      )
    )
    fig <- fig %>% colorbar(title = "cef")
    fig <- fig %>% layout(
      mapbox=list(
        style="carto-positron",
        zoom =7,  # Ajuster le niveau de zoom pour mieux cadrer le département 16
        center=list(lon= 0.1, lat=45.7)  # Coordonnées centrées sur le département 16
      )
    )
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
