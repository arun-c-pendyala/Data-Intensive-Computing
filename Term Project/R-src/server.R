

library(shiny)
library(dplyr)
library(ggplot2)
library(plotrix)
library(randomcoloR)
library(stringr)
library(waffle)
library(scales)

# Define server logic 
shinyServer(function(input, output) {
   
  data <- read.csv(file="movie_metadata.csv")
  data_genre <- read.csv(file="movie_genre.csv")
  data[data==""] <- NA
  
  #facebook likes vs gross
  likes <- select(data,movie_title,movie_facebook_likes,gross,title_year,content_rating) %>% na.omit()
  
  output$trends <- renderUI({
    
    selectInput("boxInput", "Content Rating",
                sort(unique(data$content_rating)),
                selected = "PG-13")
  })
  
  filtered_fb_likes <- reactive({
    if (is.null(input$boxInput)) {
      return(NULL)
    }    
    
    likes %>%
      filter(content_rating == input$boxInput)
             
      
  })
  
  output$trendsPlot <- renderPlot({
    if (is.null(filtered_fb_likes())) {
      return()
    }
    ggplot(filtered_fb_likes(),
           aes(x=movie_facebook_likes,
               y=gross,
               color=title_year))+
      geom_point()
  })
  
  #top_10 in movies
  top_10 <- reactive({
  top_gross <- select_(data,"movie_title",input$typeInput,"content_rating","title_year")
  
  arrange_(top_gross,lazyeval::interp(~desc(var), var = as.name(input$typeInput))) %>% filter(title_year>=input$yearInput[1],title_year<=input$yearInput[2]) %>% na.omit() %>% unique()  %>% head(n=10) #get top 10 unique movies by selected criteria
  })
  
  output$pie_genre <- renderPlot({   # pie chart
    
        data_genre_pie <- head(data_genre, n= input$obs) 
        
        ggplot(arrange(data_genre_pie, gross), aes(x="", y= gross, fill= genre))+ geom_bar(width = 1, stat = "identity") + coord_polar("y", start=0) 
    
         })
  
  
  
  
  
  output$bar_plot_top10 <- renderPlot({  # top 10 bar plot
    
   top_10_df <- as.data.frame(top_10())  
   colnames(top_10_df) <- c("movie_title","value","rating")
   
   top_10_df$rating <- factor(top_10_df$rating)
   
   
   
   ggplot(top_10_df , aes(x = movie_title , y = value,fill = rating)) +theme(axis.text.x=element_text(angle=90,hjust=1), plot.title = element_text(hjust = 0.5))+ geom_bar(stat="identity",width=0.7) + labs(x= "Movie Title" ,y= input$typeInput) + ggtitle("Top 10 stats") + scale_x_discrete(labels= function(x) str_wrap(x, width = 10))
   
   })
  
  budget <- select(data,movie_title,budget,gross,movie_facebook_likes,imdb_score,cast_total_facebook_likes)
  budget <- na.omit(budget)
  
  # plot lm model with variability
  output$LMPlot <- renderPlot({
    
    
    
    training_size = input$size/100
    train_samples<-sample(1:nrow(budget), training_size*nrow(budget), replace=FALSE)
    budget_subset <- subset(budget[train_samples,],select=c(movie_title,gross,budget))
    
    

    model <- lm(formula=gross ~ budget  ,data=budget_subset)
    
    coefs <- coef(model)
    
    palette <- distinctColorPalette(50)
    color_sample <- sample(palette,1, replace= FALSE)
    
    plot(budget_subset$budget,budget_subset$gross,pch=19,col=color_sample,xlab= 'budget',ylab='Gross',main='Simple Lm model',xlim=c(0,3*10^8)) #+ xlim(0,1000)+ ylim(0,2000)
    abline(coefs[1],coefs[2])
    
    
    
    
    
  })
  # Summary
  output$measures <- renderText({
    
    training_size = input$size/100
    train_samples<-sample(1:nrow(budget), training_size*nrow(budget), replace=FALSE)
    budget_subset <- subset(budget[train_samples,],select=c(movie_title,gross,budget))
    
    
    
    model <- lm(formula=gross ~ budget  ,data=budget_subset)
    
    coefs <- coef(model)
    r_stat <- summary(model)$r.squared
    f_stat <- summary(model)$fstatistic
   
    paste("Summary: ","R^2 Value is:" , r_stat )
    
    
  })
  
  
  # Predicted gross
  output$pred_text <- renderText({
    
    model <- lm(formula=gross ~ budget,data=budget)
    
    
    coefs <- coef(model)
    y <- coefs[2]*input$budgetInput + coefs[1]
    
    paste("The predicted gross in USD: ", y)
   
  })
  
  
  # Predicted gross for multiple linear regression
  output$multi_pred_text <- renderText({
    data <- na.omit(data)
    model <- lm(formula=gross ~ budget + duration + cast_total_facebook_likes + imdb_score ,data=data)
    
    
    coefs <- coef(model)
    y <- coefs[2]*input$MultibudgetInput+ coefs[3]*input$durationInput+ coefs[4]*input$castInput + coefs[5]*input$imdbInput  + coefs[1]
    
    paste("The predicted gross in USD : ", y)
    
  })
  
  
  
  
  #plot lm model
  output$GBplot <- renderPlot({
    
    model <- lm(formula=gross ~ budget,data=budget)
    
    
    coefs <- coef(model)
    y <- coefs[2]*input$budgetInput + coefs[1]
    
    
    palette <- distinctColorPalette(50)
    color_sample <- sample(palette,1, replace= FALSE)
    
    
    plot(budget$budget,budget$gross,pch=19,col=color_sample,xlab='Budget',ylab='Gross',main='Predictor model',xlim=c(0,3*10^8)) #+ xlim(0,1000)+ ylim(0,2000)
    abline(coefs[1],coefs[2])
    points(input$budgetInput,y,col="black",pch=17)
    
  })
  
  
  
  
  
  
})
