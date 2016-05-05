library(shiny)

shinyUI(
  pageWithSidebar(
    # Application Title
    headerPanel("Prince Song Recommender"),

    sidebarPanel(
      tags$p("Move the sliders from left or right to query the recommender."),
      
      tags$div(title="0db is the loudest, more negative values are quieter", 
               sliderInput('loudness', 
                  "loudness",
                  max = -3.691, 
                  min = -13.218,
                  value = -8.0,
                  step = -1
                  )),
      tags$div(title="1.0 is a very popular HIT song. Lower values are less-popular B-SIDE songs",
               sliderInput(
                'song_hotttnesss', 
                'song_hotttnesss',
                min=0.2, 
                max=1.0,
                value=0.5,
                step=0.1
              )),
      tags$a(href='http://telvis07.github.io/data_products_peer_review_slides/', 
             "Click here to view the presentation slides that describe this project")
    ),
    
    mainPanel(
      h3("Recommended songs by the recording artist 'Prince' based on loudness and popularity"),
      h4("You entered : Loudness"),
      verbatimTextOutput("loudness"),
      h4("You entered : Song Hotttnesss"),
      verbatimTextOutput("song_hotttnesss"),
      h4("Top 5 Recommendations"),
      htmlOutput("recommendations"),
      plotOutput("recommendations_plot")
    )
  )
)