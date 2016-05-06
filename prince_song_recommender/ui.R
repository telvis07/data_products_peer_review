library(shiny)

shinyUI(
  pageWithSidebar(
    # Application Title
    headerPanel("Prince Song Recommender"),

    sidebarPanel(
      tags$div(title="0db is the loudest, more negative values are quieter", 
               sliderInput('loudness', 
                  "Step 1: slide LEFT if you like quiet songs and RIGHT for loud songs",
                  max = -4, 
                  min = -13,
                  value = -8.0,
                  step = -1,
                  post = " dB"
                  )),
      tags$div(title="1.0 is a very popular HIT song. Lower values are less-popular B-SIDE songs",
               sliderInput(
                'song_hotttnesss', 
                'Step 2: slide LEFT if you hate what\'s on the radio and RIGHT if you love popular songs',
                min=0.2, 
                max=1.0,
                value=0.5,
                step=0.1
              )),
      tags$a(href='http://telvis07.github.io/data_products_peer_review_slides/', 
             "Click here to view the presentation slides that describe this project"),
      tags$br(),
      tags$br(),
      tags$a(href="https://en.wikipedia.org/wiki/Prince_(musician)",
             "Click here for more info about Prince")
    ),
    
    mainPanel(
      h3("Step 3: View the top 5 recommended Prince songs based on your preferences."),
      htmlOutput("recommendations"),
      h3("Step 4: View your preferences (marked by X) compared to recommended and non-recommended songs."),
      plotOutput("recommendations_plot"),
      h4("You entered : Loudness"),
      verbatimTextOutput("loudness"),
      h4("You entered : Song Hotttnesss"),
      verbatimTextOutput("song_hotttnesss")
    )
  )
)