data <- "C:/Users/TH282424/Rprojects/Rdev/time/rtb/BIB 3665 fig 7.xlsx"
rtb <- openxlsx::read.xlsx(data, rowNames = TRUE, sheet = 3)
rtb[is.na(rtb)] <- 0
rtb <- as.matrix.data.frame(rtb)
ordre <- seriation::seriate(rtb, method = "PCA")
seriation::bertinplot(rtb, ordre, options = list(panel=panel.squares, spacing = 0))
# criterion(rtb, ordre)
