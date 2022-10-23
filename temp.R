library(shiny)
library(plotly)

ShinyUi <- fluidPage(
  tags$head(tags$script('
                        var dimension = [0, 0];
                        $(document).on("shiny:connected", function(e) {
                        dimension[0] = window.innerWidth;
                        dimension[1] = window.innerHeight;
                        Shiny.onInputChange("dimension", dimension);
                        });
                        $(window).resize(function(e) {
                        dimension[0] = window.innerWidth;
                        dimension[1] = window.innerHeight;
                        Shiny.onInputChange("dimension", dimension);
                        });
                        ')),

  plotlyOutput("distPlot", width = "auto")

)

ShinyServer <- function(input, output, session) {


  #To make the responsive to the change in UI size
  observeEvent(input$dimension,{

    output$distPlot <- renderPlotly({

      p <- ggplot(iris, aes(x = Sepal.Length, y=Sepal.Width))  +
        geom_point(shape=1, alpha = 0.5, color = "grey50")
      ggplotly(p, width = (0.95*as.numeric(input$dimension[1])), height = as.numeric(input$dimension[2]))

    })

  })

}


# Run the application
shinyApp(ui = ShinyUi, server = ShinyServer)
