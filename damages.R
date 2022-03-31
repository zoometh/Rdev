library(plotly)
library(htmlwidgets)
library(openxlsx)

df <- read.xlsx(paste0(getwd(),"/time/data.xlsx"))
p <- plot_ly(df, type = 'scatter', x = ~date, y = ~hp, color = ~threat,
             mode = 'line', stackgroup='one')
saveWidget(as_widget(p), "threats.html")
