# Example borrowed from jcheng5 @ github

library(shiny)
library(ggplot2)
 
shinyServer(function(input, output) {
 
  # This 'reactive' call creates an expression called dataset() 
  # whose value updates whenever the user's specifications change.
  # In this case, dataset() is a random subsample of size input$sampleSize
  # from the full diamonds dataset.  
  dataset <- reactive({
    diamonds[sample(nrow(diamonds), input$sampleSize),]
  })
 
  # The renderPlot() call does the main work on the server side.  The result
  # is an output variable stored as output$plot, which gets rendered in the
  # mainPanel of the app.
  output$plot <- renderPlot({
    
    # This line uses the reactive dataset() defined above to construct a 
    # ggplot scatterplot.
    # aes_string() is just like aes(), except that it takes as input
    # quoted variable names instead of unquoted ones. 
    # e.g., aes_string(x = "carat", y = "price") is the same as
    #       aes(x = carat, y = price)
    p <- ggplot(dataset(), aes_string(x=input$x, y=input$y)) + geom_point()
    
    # If the user specified a color variable other than 'None', 
    # the plot gets updated to have colour=input$color
    if (input$color != 'None')
      p <- p + aes_string(color=input$color)
    
    # Remember that facets are specified by a formula argument
    # We saw facet_wrap.  facet_grid is similar.
    # If facet_row and facet_col are left unspecified by the user,
    # then facets = '. ~ .', and nothing happens.
    # Otherwise, facet_grid is used to produce a faceted plot
    facets <- paste(input$facet_row, '~', input$facet_col)
    if (facets != '. ~ .')
      p <- p + facet_grid(facets)
    
    # If the user checks the "Jitter" box, jitter is added to the plot
    if (input$jitter)
      p <- p + geom_jitter()
    # If the user checks the "Smooth" box, a smoother is overlaid
    if (input$smooth)
      p <- p + geom_smooth()
    
    # In order to produce a plot, we need to write print(p).  Just writing
    # p won't work.
    print(p)
    
  }, height=700)
  
})