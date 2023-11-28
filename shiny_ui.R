library(shiny)
library(shinydashboard)
library(plotly)
library(tidyverse)
library(rjson)
library(DT)

# Chargement et préparation des données
communes_data <- read.csv("data/v_commune_insee_2023.csv") #codes et noms des communes selon l'INSEE
communes_data <- communes_data %>%
  filter(DEP %in% c(16)) %>% #filtrage sur la Charente
  select(COM, NCCENR) %>%
  rename(code = COM, nom = NCCENR) %>%
  mutate(cfe = round(runif(n(), min = 227, max = 7046),2)) %>%
  mutate(hover_text = paste0(nom, "<br>", cfe))

# Définition interface utilisateur
ui <- dashboardPage(
  dashboardHeader(title = "Attractivité fiscale"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Carte", tabName = "tabMap", icon = icon("map")),
      menuItem("Tableau", tabName = "tabTable", icon = icon("table")),
      selectInput("taxe", "Taxe", choices = c("Cotisation financière des entreprises", "Toutes taxes", "Taxe d'habitation", "Taxe foncière", "Taxe bâti", "Taxe non bâti")),
      checkboxGroupInput("checkboxes", "Choisissez les options", 
                         choices = list("Artisan" = 1, "Activité saisonnière" = 2, "Création d'établissement" = 3)),
      numericInput("surface", "Surface du local (m²):", value = 50),
      numericInput("nb_employes", "Nombre d'employés:", value = 10),
      selectInput("typeActivite", "Type d'activité de l'entreprise :",
                  choices = c(
                    "Non incluse" = "aucune",
                    "Agriculture (Exploitants, groupements d'employeurs, GIE)",
                    "Art (Peintres, sculpteurs, graveurs, dessinateurs, artistes)",
                    "Artisanat (Travaux pour particuliers, matériaux fournis ou non)",
                    "Avocats (CAPA, exonération limitée à 2 ans après début d'activité)",
                    "Coopératives (Coopératives et unions d'artisans, patrons bateliers, maritimes)",
                    "Création (Auteurs, compositeurs, chorégraphes, traducteurs, droits d'auteur)",
                    "Enseignement (Établissements privés sous contrat avec l'État)",
                    "Entreprises (Activité dans un bassin urbain à dynamiser, ZDP)",
                    "Énergie (Production de biogaz, électricité, chaleur par méthanisation)",
                    "Immobilier (Organismes HLM, location partie habitation personnelle)",
                    "Médecine (Médecins, auxiliaires de santé, cabinet secondaire)",
                    "Photographie (Photographes auteurs, œuvres d'art, droits d'auteur)",
                    "Ports (Grands ports maritimes, autonomes, collectivités territoriales)",
                    "Presse (Éditeurs de publications périodiques, services de presse en ligne)",
                    "Public (Collectivités territoriales, organismes de l'État)",
                    "Pêche (Pêcheurs, sociétés de pêche artisanale, inscrits maritimes)",
                    "Santé (Sages-femmes, garde-malades non-infirmiers)",
                    "Scop (Sociétés coopératives et participatives)",
                    "Spectacle (Artistes lyriques et dramatiques, entrepreneurs de spectacles)",
                    "Sport (Sportifs pour la pratique d'un sport)",
                    "Syndicats (Syndicats professionnels, étude et défense des droits/intérêts)",
                    "Tourisme (Exploitants de meublé de tourisme classé, chambre d'hôtes)",
                    "Transport (Chauffeurs de taxis ou d'ambulances, 1 ou 2 voitures)",
                    "Vente (Vendeurs à domicile indépendants, rémunération < 7259 €)",
                    "Zoologie (Établissements zoologiques, activité agricole)"
                  ))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "tabMap",
              fluidRow(
                column(12, plotlyOutput("map", height = "95vh"))
              )
      ),
      tabItem(tabName = "tabTable",
              h2("Tableau des données"),
              DT::DTOutput("dataTable")
      )
    )
  )
)

# Logique serveur
server <- function(input, output) {
  
    # Expression réactive pour ajuster les données en fonction de la sélection de l'utilisateur
  reactive_communes_data <- reactive({
    data <- communes_data
    
    if (input$typeActivite != "aucune") {
      data <- data %>% mutate(cfe = 0) %>%
      mutate(hover_text = paste0(nom, "<br>", cfe))  # Recalculer hover_text ici
    }
    data
  })
  
  
  output$map <- renderPlotly({  # Utiliser renderPlotly
    data <- reactive_communes_data()
    url <- 'data/charente.json'
    geojson <- rjson::fromJSON(file=url)
    g <- list(
      fitbounds = "locations",
      visible = FALSE,
      scope = "france"
    )
    custom_colorscale <- list(
      c(0, "red"),  # rouge à 0%
      c(0.5, "yellow"),  # jaune à 50%
      c(1, "green")  # vert à 100%
    )
    fig <- plot_ly() 
    fig <- fig %>% add_trace(
      type="choroplethmapbox",
      geojson=geojson,
      locations=data$code,
      z=data$cfe,
      text = data$hover_text,
      hoverinfo = "text",
      colorscale = custom_colorscale,
      reversescale=TRUE,
      featureidkey="properties.code",
      marker=list(line=list(
        width=0.5),
        opacity=0.8
      )
    )
    fig <- fig %>% colorbar(title = "CFE")
    fig <- fig %>% layout(
      mapbox=list(
        style="carto-positron",
        zoom =7,  # Ajuster le niveau de zoom pour mieux cadrer le département 16
        center=list(lon= 0.1, lat=45.7)  # Coordonnées centrées sur le département 16
      )
    )
  })
  
  output$dataTable <- renderDT({
    data <- reactive_communes_data() %>%# Utiliser données réactives en réajustant données
      select(nom,cfe) %>%
      arrange(cfe)
    col_names <- c("Commune", "Cotisation foncière des entreprises")
    datatable(data,
              options = list(
                pageLength = 10,
                language = list(
                  search = "Chercher",
                  lengthMenu = "Afficher _MENU_ valeurs"
                )
              ),
              colnames = col_names)
  })
  
  output$taxe <- renderText({
    # Récupérer la valeur sélectionnée dans le selectInput 'taxe'
    selected_taxe <- input$taxe
    
    # Retourner le texte choisi pour l'afficher
    return(selected_taxe)
  })
}

shinyApp(ui, server)
