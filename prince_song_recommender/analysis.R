# Telvis Calhoun
# Analysis of Songs Data retrieved from the Million Song Data Set
# http://labrosa.ee.columbia.edu/millionsong/
library(xtable)
library(ggplot2)
library(slidify)
library(shiny)

load_csv_and_save_to_rds <- function() {
  # Load the million song CSV and save to a RDS file.
  # Will make the analysis quicker.
  
  print("Loading 1 million song data from disk. Be patient...")
  # NOTE: I've excluded this file from github because it very large
  df <- read.csv("data/songs.csv.gz")
  print("Saving data/songs.rds")
  saveRDS(df, "data/songs.rds")
  df
}

clean_data_and_filter_artist <- function(df=NULL) {
  if (is.null(df)) {
    print("Loading 1 million song data from disk. Be patient...")
    df <- readRDS("data/songs.rds")
  }
  names_with_prince <- unique(subset(df, 
                                     grepl("^Prince$|^Prince &|^Prince With", 
                                           artist_name, perl=TRUE))$artist_name)
  prince_df <- subset(df, grepl("^cPrince$|^Prince &|^Prince With", artist_name, perl=TRUE))
  
  # write.csv(prince_df, "data/prince.csv")
  # Lot's of the song_hotttnesss values are NA so remove them.
  prince_hott_df <- prince_df[!is.na(prince_df$song_hotttnesss),]
  
  # A few songs have 0.0 song_hotttnesss, including "Let's Go Crazy". Set them to the mean hotttnesss 
  prince_hott_df[(prince_hott_df$song_hotttnesss == 0), ]$song_hotttnesss <- mean(prince_df$song_hotttnesss, na.rm = TRUE)
  
  # select a few interesting columns
  prince_df_clean <- subset(prince_hott_df, select=c(title, tempo, loudness, song_hotttnesss))
  
  # sort by the hottttnesss
  prince_df_clean <- prince_df_clean[order(prince_df_clean$song_hotttnesss, decreasing = TRUE),]
  
  # save for later
  write.csv(prince_df_clean, "data/prince_clean.csv")
  
  # save RDS for running recommender from R console
  saveRDS(prince_df_clean, "data/prince_clean.rds")
  
  # save RDS for running recommender from 'shiny' app
  saveRDS(prince_df_clean, "prince_song_recommender/data/prince_clean.rds")
  
  prince_df_clean
}

gen_plots <- function(df) {
  # plot age vs wage. color by jobclass 
  obj <- qplot(song_hotttnesss, loudness, data=df)
  png("plots/hotttnesss_by_loudness.png", width = 960, height = 960, units = "px")
  print(obj)
  dev.off()
  print("Generated hotttnesss_by_loudness.png")
}

prince_song_recommender <- function(song_hotttnesss=0.5, loudness=-8, top_n=5, df = NULL, scale01=TRUE) {
  if (is.null(df)) {
    df <- readRDS("data/prince_clean.rds")  
  }

  range01 <- function(x, datums){(x-min(datums))/(max(datums)-min(datums))}
  if(scale01) {
    x1 <- c(song_hotttnesss, range01(loudness, df$loudness))
  } else {
    x1 <- c(song_hotttnesss, loudness)
  }
  n <- nrow(df)
  distances <- numeric(n)
  
  # calculate the distance between the query values and each
  # entry in the data.
  for (i in seq_len(n)){
    if (scale01){
      x2 <- c(df[i,]$song_hotttnesss, range01(df[i,]$loudness, df$loudness))
    } else {
      x2 <- c(df[i,]$song_hotttnesss, df[i,]$loudness)
    }
    distances[i] <- dist(rbind(x1, x2))
  }
  
  ord <- order(distances)
  ord <- ord[1:top_n]
  recs <- subset(df[ord, ], select=c("title", "loudness", "song_hotttnesss"))
  list(recommendations=recs, 
       ord=ord, 
       df=df, 
       song_hotttnesss=song_hotttnesss,
       loudness=loudness)
} 

prince_song_recommender_xtable <- function(recommender_data) {
  recs <- recommender_data$recommendations
  print(xtable(recs), type="html", include.rownames = FALSE)
} 


prince_song_recommender_plot <- function(recommender_data) {
  
  
  # get the indices for the recommendations
  ord <- recommender_data$ord
  song_hotttnesss <- recommender_data$song_hotttnesss
  loudness <- recommender_data$loudness
  df <- recommender_data$df
  n <- nrow(df)
  
  
  # find which indices are in the 'top N' list
  df$recommended <- seq(n) %in% ord
  p <- ggplot(aes(x=song_hotttnesss, y=loudness, colour=recommended), data=df) +
    geom_point() +  
    geom_point(aes(x=song_hotttnesss,y=loudness, colour=recommended),
                 size=5,shape=4,
                 data=data.frame(song_hotttnesss=song_hotttnesss,
                                 loudness=loudness, 
                                 recommended=TRUE)) +
    labs(y="Loudness (dB)") +
    labs(x="Song Hotttnesss [0.0, 1.0]") +
    labs(title="Recommendation plot with input values marked as 'X'")
    
  p
}


