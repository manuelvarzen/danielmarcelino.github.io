# Example borrowed from jcheng5 @ github

library(shiny)
library(ggplot2)
 
dataset <- diamonds
 
shinyUI(pageWithSidebar(
   
  # Title appearing at the top of the page
  headerPanel("Diamonds Explorer"),
  
  # The sidebarPanel specifies the options presented to the user.  
  # Inputs come in various forms.  In this example we have a slider bar
  # for specifying sample size, 5 dropdown menus for selecting variables from
  # the dataset, and two checkboxes for specifying point jitter and smoothing.
  sidebarPanel(
    
    # This code produces a slider bar through which the user can specify
    # the input$sampleSize parameter.  
    sliderInput('sampleSize', 'Sample Size', min=1, max=nrow(dataset),
                value=min(1000, nrow(dataset)), step=500, round=0),
    
    # The three lines of code below provide the user with dropdown menus
    # through which to specify the x, y, and color arguments for ggplot
    
    # Basic syntax:
    # selectInput(inputID, label, choices) creates a dropdown menu
    # titled 'label' asking the user to select one of the 'choices'.
    # The user's selection is stored in a variable called input$inputID.
    
    selectInput('x', 'X', names(dataset)),
    selectInput('y', 'Y', names(dataset), names(dataset)[[2]]),
    selectInput('color', 'Color', c('None', names(dataset))),
    
    # The next two lines provide the user with a checkbox to specify 
    # logical values.  In this case, the user can specify whether to use jitter
    # and whether to overlay a smoother.
    checkboxInput('jitter', 'Jitter'),
    checkboxInput('smooth', 'Smooth'),
    
    # The next two lines provide the user with dropdown menus from which
    # To select faceting parameters.  Note that 'None' is provided
    # as one of the choices.
    selectInput('facet_row', 'Facet Row', c(None='.', names(dataset))),
    selectInput('facet_col', 'Facet Column', c(None='.', names(dataset)))
  ),
 
  # The server-side code constructs a renderPlot() specification 
  # that gets saved as output$plot.  
  # plotOutput(outputId) renders the renderPlot() given by output$outputId
  mainPanel(
    plotOutput('plot')
  )
))