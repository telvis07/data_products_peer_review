source("analysis.R")

shinyServer(
  function(input, output) {
    # Get recommender data
    rec_data <- reactive({prince_song_recommender(loudness = input$loudness, 
                                                 song_hotttnesss = input$song_hotttnesss)})

    output$loudness <- renderPrint({input$loudness})
    output$song_hotttnesss <- renderPrint({input$song_hotttnesss})
    output$recommendations <- renderPrint({prince_song_recommender_xtable(rec_data())})
    output$recommendations_plot <- renderPlot({prince_song_recommender_plot(rec_data())})
  }
)