# summary <- data.frame(value = Mesolithic$Microliths)
# ggplot(summary, aes(y = 0)) +
#   geom_point(aes(x = value), shape = 17, color = "darkred") +
#   geom_text(aes(x = value, label = value), vjust = -1.5) +
#   theme_minimal() + theme(panel.grid = element_blank())

library(shiny)
library(plotly)
library(archdata)

data("Mesolithic")

white.font <- list(
  family = "Courier New",
  size = 14,
  color = "white")

ui <- fluidPage(
  tags$style('.container-fluid {
                             background-color: #000000;
              }'),
  selectInput("choice", "", choices = colnames(Mesolithic), selected = "Microliths"),
  plotlyOutput("graph")
)

server <- function(input, output, session){
  output$graph <- renderPlotly({
    plot_ly(Mesolithic,
            x = ~get(input$choice),
            y = 0,
            type = 'scatter',
            mode = 'markers') %>%
      layout(plot_bgcolor='#000000',
             xaxis = list(
               title = input$choice,
               gridcolor = '#000000'),
             yaxis = list(
               title = '',
               showticklabels = FALSE,
               zerolinecolor = '#ffff',
               gridcolor = '#000000')
      )
  })
}

shinyApp(ui, server)
