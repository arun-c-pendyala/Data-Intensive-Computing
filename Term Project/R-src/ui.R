
library(shiny)
library(shinythemes)


# Define UI 
shinyUI(fluidPage(theme= shinytheme("cosmo"),
  
  # Application title
  titlePanel(title= div(img(src = "imdb_pic.jpg", height = 100),"IMDB Movies Dataset")),
  
  
  
  
  navbarPage("Imdb",
        navbarMenu("Stats and Plots",
          
          tabPanel("Plot",
                   br(),br(),br(),
                   sidebarLayout(
                     
                     sidebarPanel(
                       br(),br(),
                       radioButtons("typeInput", "Top 10 movies by:",
                                    choiceNames  = c("Gross", "Movie Facebook Likes", "ImDb score","Budget","Cast Total Facebook Likes"),
                                    choiceValues = c("gross","movie_facebook_likes","imdb_score","budget","cast_total_facebook_likes"),
                                    selected = "gross"),
                       br(),br(),
                       sliderInput("yearInput", "Year Range", min = 1927, max = 2016,
                                   value = c(1990, 2010), pre = "Year ")
                       
                       
                     ),
                     mainPanel(
                       
                       
                       h3("Find out the top 10 Stats by different criteria",align="center"),
                       
                       plotOutput("bar_plot_top10"),br(),
                       br(),
                       p("The dataset has been taken from kaggle - https://www.kaggle.com/deepmatrix/imdb-5000-movie-dataset"),
                       
                       br(),
                       p("Logo owned by IMDB. No copyright infringement intended", style="font-size:0.7em")
                     )
                   )
                ),
          
          tabPanel("Pie", 
                   
                   sidebarLayout(
                     sidebarPanel(
                       numericInput("obs", "Top n genres - ordered by Gross:", 10, min = 1, max = 24)
                       
                      
                       
                       
                       
                     ),
                   
                   
                   mainPanel(
                     
                    
                     
                     h3("Genres arranged by Gross",align="center"),
                     h5("Data produced by Map Reduce",align="center"),
                     
                     plotOutput("pie_genre")
                   )
             
                 )
             
  
              ),
          
          tabPanel("Trends",
                   br(),br(),br(),
                   sidebarLayout(
                     
                     sidebarPanel(
                       br(),br(),
                       
                       uiOutput("trends"),
                       
                       br(),br()
                       
                     ),
                     mainPanel(
                      
                      
                       h3("Relation between FB likes and Gross",align="center"),
                       
                       plotOutput("trendsPlot")
                       
                     )
                   )
          )
          
  
  
  
    ),
    navbarMenu("Linear Model",
               
               tabPanel("Predictor",
                        
                        br(),br(),
                        
                        sidebarLayout(
                          sidebarPanel(
                            numericInput("budgetInput", "Budget in USD :", 10000000 , min = 100000  , max =12215500000)
                            
                            
                            
                            
                          ),
                          
                          mainPanel(
                            
                            
                            h3("Prediction of Gross from Budget",align="center"),
                            
                            plotOutput("GBplot"),
                            br(),
                            h5(textOutput("pred_text"),style="color:blue"),
                            br(),br()
                          )
                          
                          
                        )
                        
               ),
    
                tabPanel("Various LM",
                         
                         br(),br(),
                         
                         sidebarLayout(
                           sidebarPanel(
                             numericInput("size", "Select size of dataset in % :", 90 , min = 0, max =100),
                             br(),br()
                             
                      
                             
                           ),
                         
                           mainPanel(
                             
                             
                             h3("Various Linear Model",align="center"),
                             
                             plotOutput("LMPlot"),
                             textOutput("measures"),
                             br()
                           )
                         
                         
                         )
                         
                ),
               tabPanel("Multiple LM",
                        
                        br(),br(),
                        
                        sidebarLayout(
                          sidebarPanel(
                            numericInput("MultibudgetInput", "Budget in USD :", 10000000 , min = 100000 , max =12215500000),
                            
                            numericInput("durationInput", "Duration :", 120 , min = 30 , max =330),
                            
                            
                            numericInput("castInput", "Cast Total FB likes :", 60000 , min = 100 , max = 656730),
                            
                            numericInput("imdbInput", "IMDB Score :", 8 , min = 0 , max = 10)
                            
                            
                            
                            
                            
                          ),
                          
                          mainPanel(
                            
                            
                            h3("Prediction of Gross from Budget (Multiple Linear Regression)",align="center"),
                            
                      
                            br(),
                            h5(textOutput("multi_pred_text"),style="color:blue"),
                            br(),br()
                          )
                          
                          
                        )
                        
               )
               
               
               
               
    ), 
    tabPanel("Authors",
      h2("Authors:"),
      h4("1. Arun Chandra Pendyala"),
      h4("2. Abhilash Velalam"),
      h5("Graduate Students at University at Buffalo"),
      h5("Spring-2017")
    )
   # tabPanel("Documentation", 
            # tags$iframe(style="height:600px; width:100%; scrolling=yes", 
                         #src="TermProject.pdf"))
    
)))
