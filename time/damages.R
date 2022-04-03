library(openxlsx)
library(messydates)
library(lubridate)
library(tibble)
library(dplyr)
library(plotly)
library(htmlwidgets)


plot_ly <- F

path.time <- paste0(getwd(),"/time/")

df <- read.xlsx(paste0(path.time, "data.xlsx"))
df.syria <- read.xlsx(paste0(path.time, "data.xlsx"),
                      sheet = "data_syria")
# export XLSX to TSV
write.table(df.syria,  paste0(path.time, "data_syria.tsv"),
            quote = FALSE, sep='\t', col.names = TRUE)

# reformat dataframe and dates
df.syria.out <- data.frame(region = character(),
                           site = character(),
                           date = character(),
                           cause = character(),
                           type = character(),
                           density = integer())
for(i in 1:nrow(df.syria)){
  # intersect with the limits of the study: "2004-01-01..2019-12-31"
  var.date <- md_intersect(as_messydate("2004-01-01..2019-12-31"),
                           as_messydate(df.syria[i, "date"]))
  n.dates <- length(var.date)
  var.region <- rep(df.syria[i, "region"], n.dates)
  var.site <- rep(df.syria[i, "site"], n.dates)
  var.cause <- rep(df.syria[i, "cause"], n.dates)
  var.type <- rep(df.syria[i, "type"], n.dates)
  df.damage <- data.frame(region = var.region,
                          site = var.site,
                          date = var.date,
                          cause = var.cause,
                          type = var.type,
                          density = 1/n.dates)
  df.syria.out <- rbind(df.syria.out, df.damage)
}
# export XLSX to TSV
write.table(df.syria.out,  paste0(path.time, "df_syria_out.tsv"),
            quote = FALSE, sep='\t', col.names = TRUE)
# plot
df.syria.out$date <- as.Date(df.syria.out$date)
df.syria.out <- df.syria.out %>%
  group_by(date) %>%
  summarise(density = sum(density))
png(paste0(path.time, "df_syria_out.png"), width = 18, height = 12, res = 300, units = "cm")
plot(density ~ date, df.syria.out, xaxt = "n", type = "l")
axis(1, df.syria.out$date, format(df.syria.out$date, "%b %y"), cex.axis = .7)
dev.off()


if(plot_ly){
  p <- plot_ly(df, type = 'scatter', x = ~date, y = ~hp, color = ~threat,
               mode = 'line', stackgroup='one')
  p
  saveWidget(as_widget(p), paste0(getwd(),"/time/threats.html"))
}
