library(googlesheets4)
library(stringr)
library(ggplot2)
library(ggrepel)


gsheet.base <- 'https://docs.google.com/spreadsheets/d/'
gsheet.url <- '1oiOaKQu5sqj0IV99PY7Qr1FpvQ0QaEqH1pMKK9uDALw/edit#gid=0'
gsheet <- paste0(gsheet.base, gsheet.url)
xl <- read_sheet(gsheet)
xl.tags.list <- str_split(xl$tags, ",")
tags <- str_to_title(trimws(unlist(xl.tags.list)))
df.tags <- data.frame(table(tags))
df.tags <- df.tags[order(df.tags$Freq, decreasing = TRUE),]
jpeg(paste0(getwd(), '/tags_occur.jpg'), width = 25, height = 17,
     res = 300, unit='cm')
ggplot(df.tags, aes(x = tags, y = Freq)) +
  geom_bar(aes(fill = tags), stat = "identity", position ="dodge") +
  # geom_text_repel(aes(label = tags), max.overlaps = 40, size = 3) +
  theme(axis.title.x = element_blank()#,
        #  axis.text.x = element_blank()#,
        #        legend.position = "bottom",
        #  legend.title = element_blank(),
        #legend.text = element_text(size = 7),
        #  legend.key.size = unit(.7, "line")
  )+
  scale_fill_discrete(guide = "none")+
  coord_flip()
dev.off()

