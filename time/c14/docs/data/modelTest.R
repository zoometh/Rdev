# create a SpdModelTest for a given set of radiocarbon
# ex. dataframe 'DK'
# identifier            mt_hg c14_lab_code c14bp c14sd
# 1        I2605             J1c6    Poz-83483  4710    35
# 2        I5366          X2b+226    OxA-34470  4775    34
# 3        I3068           T2c1d1    UBA-29003  4820    34
# 4        I4949              T2b  PSUAMS-2513  4715    20
# 5        I5374              H1c    OxA-16460  4008    39
# 6        I4303               H3  PSUAMS-2260  5820    30
# 7        I4304        T2c1d+152  PSUAMS-2226  5830    35
# 8        I4305         T2b3+151  PSUAMS-2225  5860    35
# 9  BerryAuBac1            U5b1a    SacA-5455  6325    35
# 10      Bichon            U5b1h    OxA-27763 11855    50

library(rcarbon)

# DK <- df.MesoNeo.b
# # DK.caldates=calibrate(x=DK$C14Age,errors=DK$C14SD,calCurves='intcal20')
DK.caldates <- calibrate(x = DK$c14bp,
                         errors = DK$c14sd,
                         calCurves = 'intcal20')
DK.spd <- spd(DK.caldates,
              timeRange=c(max(DK$c14bp) - 1950,
                          min(DK$c14bp) - 1950)
) 
# plot(DK.spd) 
# plot(DK.spd,runm=200,add=TRUE,type="simple",col="darkorange",lwd=1.5,lty=2) #using a rolling average of 200 years for smoothing
nsim <- 10
# DK.bins = binPrep(sites=DK$SiteID,ages=DK$C14Age,h=100)
DK.bins <- binPrep(sites=DK$identifier,ages=DK$c14bp,h=100)
uninull <- modelTest(DK.caldates,
                     errors = DK$c14sd,
                     bins = DK.bins,
                     nsim = nsim,
                     # timeRange=c(8000,4000),
                     # model = "uniform",
                     # runm=100,
                     raw=TRUE
                     )
SpdModelTest_MesoNeo <- uninull
save(SpdModelTest_MesoNeo, file = "SpdModelTest_MesoNeo.RData")
save(SpdModelTest_MesoNeo, file = "SpdModelTest_MesoNeo.R")
saveRDS(SpdModelTest_MesoNeo, file = "SpdModelTest_MesoNeo.rds")
# save(uninull, file = "SpdModelTest_MesoNeo.R")
p2pTest(x= uninull,
        p1=df.MesoNeo.b[1, "c14bp"],
        p2=df.MesoNeo.b[2, "c14bp"])
getwd()
