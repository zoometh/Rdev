# ## Code to plot outputs for one flood
# ----
# housekeeping
#----
rm(list = ls())
mystarttime <- Sys.time()

library(reticulate) # to manage python envs 
use_condaenv('rgee', required = TRUE) # set correct python env

# load packages
library(rgee)
library(dplyr)
library(sf)
library(cptcity)
library(lubridate)

ee_Initialize() 

setwd("C:/Users/Anya Leenman/OneDrive - Nexus365/Research/2021/Floods_2D_riv_change/")

#-----

# Constants to use:
country <- 'Colombia'

myflood <- 303 # flood to plot up

savetodrive <- F # export anything to google drive?

snowfree_countries <- c('Colombia', 'Brazil')

flood_thr <- 80 # check previous script; should match
MAX_CLOUD_PROBABILITY <- 10 # max probability of cloud retained when masking clouds
# lower values = less clouds but some misclassification (and therefore masking out) of water/sediment as clouds
# higher values = less mis-masking of water, but more mis-classification of mid-river clouds as land (and therefore spurious change detection)
bands_inc_cloud <- c('B2', 'B3', 'B4', 'B8', 'B8A', 'B9', 'B11', 'B12') # bands to use (for cloud masking, and DeepwaterMap2 if using)
window_length <- 21 # days
nMths <- 1 # window length for "after flood" (to check for permanent vs transient)
months_to_check <- 1:24 # which months after the flood should be checked for whether transitions are permanent/transient?
# e.g. for '1', the first month to be checked STARTS 1 month after the end of the flood (And ends 2 mths after).
area_keep_threshold = 0.3 # minimum proportion of polygon that must have cloud-free data

# classification parameters (from Boothroyd et al)
mndwi_param <- -0.40;
ndvi_param <- 0.20;
cleaning_pixels <- 500; # Neighborhood can't be larger than this or comp too $$
run_cleaning <- T # should neighborhood-based noise filter be run? 

# is this debug version or real thing?
debugging = T # one flood or all of them?
gettinginfo = F # should we get statistics calculated over region?
writinginfo = F # should info be written to file?
channel_belt = T # compute channel maps for channel belt (incl bars)?
if(debugging == F){ # lil error trap in case I'm silly
  gettinginfo = T # should we get statistics calculated over region?
  writinginfo = T # should info be written to file?
}

# Earth engine datasets:
GEE_dataset <- 'COPERNICUS/S2_HARMONIZED'
cloud_dataset <- 'COPERNICUS/S2_CLOUD_PROBABILITY'
GRWL <- "projects/sat-io/open-datasets/GRWL/water_mask_v01_01"

# -----

# Load data with AOIs and timestamps for query
all_gauges <- st_read(paste0('./data/time_series/', country, '/windows/',
                             window_length, '_day/all_gauges.shp')) %>%
  # convert dates to character strings for reading by Earth Engine (python and r store dates differently; see here for more detail: https://cran.r-project.org/web/packages/rgee/vignettes/rgee02.html)
  mutate(pre_srt = as.character(pre_srt)) %>%
  mutate(pre_end = as.character(pre_end)) %>%
  mutate(post_srt = as.character(post_srt)) %>%
  mutate(post_end = as.character(post_end)) %>% 
  # filter to row w single polygon and start/end dates
  dplyr::filter(floodID == myflood) 

all_gauges <- all_gauges %>% # add extra columns to store outputs of loop
  mutate(area_change_px = NA, # in pixels
         cloudfree_area_m2 = NA, # in m2
         phi_val = NA, norm_overlap = NA,
         cloudfree_area_px = NA, # in pixels
         t0_wet = NA, t0_dry = NA, t1_wet = NA, t1_dry = NA,
         perm_dried_px = NA, perm_wet_px = NA, # count of permanently dried/wetted pixels
         Num_unreworked_pix = NA, frac_reworked = NA, 
         change_norm_by_AOI_area = NA, perm_wetting_norm_by_AOI_area = NA,
         water_area_preflood_in_px = NA, # water area in preflood timestamp, measured in pixels)
         water_area_postflood_in_px = NA,
         water_area_av_in_px = NA,# av across two timestamp
         n_afterflood_mths = NA, # number of afterflood months searched for water permanence
         cloudfree_percentage = NA) # percentage of AOI that is cloud

# -----
# Def functions:
#------
# function to mask clouds out of sentinel data:
maskClouds <- function(img){
  clouds <- ee$Image(img$get('cloud_mask'))$select('probability')
  isNotCloud <- clouds$lt(MAX_CLOUD_PROBABILITY)
  return(img$updateMask(isNotCloud)$divide(10000)) # need to add /10000 scaling parameter
}

# // The masks for the 10m bands sometimes do not exclude bad data at
# // scene edges, so we apply masks from the 20m and 60m bands as well.
maskEdges <- function(s2_img){
  return(s2_img$updateMask(
    s2_img$select('B8A')$mask()$updateMask(s2_img$select('B9')$mask())))
}

# function to map water from chosen input bands:
mapWater <- function(img){
  # band ratios to use as inputs:
  ndvi_vals <- img$normalizedDifference(c("B8","B4"))
  # lswi_vals <- img$normalizedDifference(c("B8", "B11"))
  mndwi_vals <- img$normalizedDifference(c("B3", "B11"))
  evi_vals <- img$expression('2.5 * (Nir - Red) / (1 + Nir + 6 * Red - 7.5 * Blue)', 
                             c('Nir' = img$select('B8'), 
                               'Red' = img$select('B4'), 
                               'Blue'= img$select('B2')))
  # water (raw)
  water <- (mndwi_vals$gt(ndvi_vals)$
              Or(mndwi_vals$gt(evi_vals)))$
    And(evi_vals$lt(0.1)) # default 0.1 from Boothroyd et al 2020 code
  # channel belt (counts bars as 'river')
  if(channel_belt == T){
    activebelt <- (mndwi_vals$gte(mndwi_param))$And(ndvi_vals$lte(ndvi_param))
    water <- water$Or(activebelt)
  }
  return(water)
}

# function to detect snow (only apply if (!country %in% snowfree_countries) so 
# it runs as default unless country explicitly in snowfree list)
# following methods here: https://www.sciencedirect.com/science/article/pii/S2589915522000050
ndsi_param <- 0.5  # stick at front
snowthresh <- 0.9 # what proportion of cloud-free AOI must be snow covered before 
# AOI is rejected?
# must be high as water often misclassified as snow
mapSnow <- function(img){
  # band ratios to use as inputs:
  ndsi_vals <- img$normalizedDifference(c("B3", "B11"))
  # snow
  snow <- ndsi_vals$gt(ndsi_param)
  return(snow)
}

# function to create the image collection
my_imcol <- function(startdate, enddate){
  imcol <- ee$  # create collection
    ImageCollection(GEE_dataset)$ # query Earth Engine database
    select(bands_inc_cloud)$ # filter to bands of interest
    filterDate(startdate, enddate)$ # filter to time window of interest
    filterBounds(AOI)$ # filter to aoi for this gauge
    map(maskEdges) # apply func to mask out bad data at edges
}

# function to mask out clouds, reduce to min for each pixel:
rem_clouds <- function(imcol, startdate, enddate){
  # get image collection of s2cloudless data:
  s2Clouds <- ee$
    ImageCollection(cloud_dataset)$ # query GEE servers
    filterDate(startdate, enddate)$ # filter to time window of interest
    filterBounds(AOI) # filter to aoi for this gauge
  # Join S2 SR with cloud probability dataset to add cloud mask *for each image* :
  s2SrWithCloudMask <- ee$
    Join$saveFirst('cloud_mask')$
    apply('primary' = imcol, 
          'secondary' = s2Clouds,
          'condition' = ee$Filter$equals(
            'leftField'= 'system:index', 
            'rightField'= 'system:index'))
  # mask clouds and reduce to min
  imcol <- ee$ImageCollection(s2SrWithCloudMask)$map(maskClouds)$min()
  # note "min" is a reducer that turns ImageCollection to Image and also finds minimum 
  # was using median but it seems to misclassify cloud as water too often
  
  # note also that this method >> filtering image collection by % cloud as that would 
  # eliminate more cloudy scenes, even if part of a scene is not cloudy and might 
  # be useful.
}

#---------
# for each combo of a flood event and an aoi around the gauge that measured it:
# (rewrite as an apply function not a loop - though bottleneck might be at input/output
# for reading from file? Experiment with timings for a subset of gauges/floods)
#----------
for(i in 1:nrow(all_gauges)){ 
  dat <- all_gauges[i,] # get row from table of aois and dates
  AOI <- dat$geometry %>% # get aoi polygon
    sf_as_ee()
  pre_flood2 <- my_imcol(dat$pre_srt, dat$pre_end)
  post_flood2 <- my_imcol(dat$post_srt, dat$post_end)
  
  # get number of images in ImageCollections:
  (n_images <- pre_flood2$size()$getInfo())
  (n_images_post <- post_flood2$size()$getInfo()) 
  
  # remove clouds and reduce to min for each pixel:
  pre_flood2 <- rem_clouds(pre_flood2, dat$pre_srt, dat$pre_end)
  post_flood2 <- rem_clouds(post_flood2, dat$post_srt, dat$post_end)
  
  # copy cloud mask from one to the other so both have matching cloud mask:
  pre_flood2 <- pre_flood2$updateMask(post_flood2$mask())
  post_flood2 <- post_flood2$updateMask(pre_flood2$mask())
  
  # if either image collection is empty:
  if((n_images < 1) | (n_images_post < 1)){
    print(paste0('At i = ', i, ' no images in date range for at least one of pre or post'))
    next # move on to next flood event
  }
  
  # get total polygon area in number of pixels, but ACCOUNT FOR CLOUDS, 
  # i.e. need to extract total number of non-NULL cells within AOI:
  A <- pre_flood2$reduceRegion(
    reducer = ee$Reducer$count(), # gets total num of non-NULL cells
    geometry = AOI, 
    scale = 10,
    maxPixels = 1e30
  )
  
  A <- A$get("B2")$getInfo() # extract count of non-null cells within AOI
  all_gauges$cloudfree_area_px[i] <- A # assign to output df
  A_raw <- A * 10 * 10 # convert to area in m2 by multiplying by cell size
  all_gauges$cloudfree_area_m2[i] <- A_raw # assign total area to data frame
  if(A_raw < (area_keep_threshold * dat$area)){
    print('Not enough cloudfree data')
    next
  }# code below skipped if cloudfree area < some threshold of total AOI area
  
  # test for snow cover:
  if(!country %in% snowfree_countries){ # default is to run UNLESS country is
    # included in list of snowfree countries
    snow_pre <- mapSnow(pre_flood2)
    snow_pre_count <- snow_pre$reduceRegion(
      reducer = ee$Reducer$sum(), # gets total num of snow cells
      geometry = AOI, 
      scale = 10,
      maxPixels = 1e30
    )$get('nd')$getInfo() # extract count of non-null cells within AOI
    if(snow_pre_count / A > snowthresh ){
      print(paste0('SNOW ALERT at preflood, i = ', i))
      # next
    }
    snow_post <- mapSnow(post_flood2)
    snow_post_count <- snow_post$reduceRegion(
      reducer = ee$Reducer$sum(), # gets total num of non-NULL cells
      geometry = AOI, 
      scale = 10,
      maxPixels = 1e30
    )$get('nd')$getInfo() # extract count of non-null cells within AOI
    if(snow_post_count / A > snowthresh ){
      print(paste0('SNOW ALERT at postflood, i = ', i))
      # next
    }
  }
  
  all_gauges$cloudfree_percentage[i] <- (A_raw / dat$area) * 100
  
  # Water segmentation/extraction/mapping (from Zou et al 2018; 
  # code adapted from Boothroyd et al 2020 WIRES water paper):
  #--------
  water_pre <- mapWater(pre_flood2) # apply function defined at beginning
  water_post <- mapWater(post_flood2)
  
  #------------------------------------------------------
  # generate after-flood water mask using months specified:
  #------------------------------------------------------
  water_after_sum <- ee$Image(0) # empty layers
  cloudfree_count <- ee$Image(1) # start with empty layer of 1s because we divide is_wetting_permanent by the number of afterflood timestamps + 1 
  # loop through specified after-flood months of interest:
  for(j in 1:length(months_to_check)){
    after_flood <- my_imcol(startdate = as.character(as.Date(dat$post_end) %m+% months(j)), 
                            enddate = as.character(as.Date(dat$post_end) %m+% months(j + nMths)))
    after_flood <- rem_clouds(imcol = after_flood, startdate = as.character(as.Date(dat$post_end) %m+% months(j)), 
                              enddate = as.character(as.Date(dat$post_end) %m+% months(j + nMths)))
    # error trap:
    if(after_flood$bandNames()$getInfo()[1] != 'B2'){
      print('No data in this after_flood imcol; breaking out of loop')
      break
    }
    water_after <- mapWater(after_flood) # map water
    # copy of the cloud mask
    cloudfree_after <- ee$Image(1)$ # blank image of 1s
      updateMask(water_after$mask())$ # give it the cloud mask of the water mask layer
      unmask() # zeros in cloud areas
    # touch up the cloud mask for the water map:
    water_after <- water_after$unmask()$ # apply zeros in cloud holes
      updateMask(water_post$mask()) # apply cloud mask from flood layers so all data use same mask
    water_after_sum <- water_after$add(water_after_sum) # add to total after-flood stack water-presence stack
    cloudfree_count <- cloudfree_after$add(cloudfree_count) # add to total after-flood cloud stack
  }
  if(j <12 ){
    print('not enough post-flood data')
    next
  }
  all_gauges$n_afterflood_mths[i] <- j
  
  #----------------------------------------------------------------------------
  # noise filtering:
  #----------------------------------------------------------------------------
  
  # GRWL:
  GRWL_mask <- ee$ 
    ImageCollection(GRWL)$ # query Earth Engine database
    filterBounds(AOI)$ # filter to aoi for this gauge - isn't working super well
    mean()$ # is it reasonable to take the mean? Should just mosaic really...
    divide(255) # rescale to binary (But this converts to float...)
  GRWL_unmasked <- GRWL_mask$unmask() # add zeros in non-water areas
  
  # mask using a giant water map (only run cleaningpixels code on 1 layer, not 2)
  # same pixels cleaned from both layers 
  giantwatermask <- water_pre$add(water_post)$
    add(GRWL_unmasked)$
    unmask(GRWL_unmasked)
  giantwatermask <- giantwatermask$
    where(giantwatermask$gt(0),1)$ # reclassify all to 1
    updateMask(giantwatermask$gt(0))$ # select only water
    uint8() # convert to integer
  giantwatermask <- giantwatermask$
    updateMask(giantwatermask$ 
                 connectedPixelCount(cleaning_pixels, F)$ # calculate size of clumps
                 gte(cleaning_pixels)) # remove clumps smaller than cleaning_pixels (is this actually happening though?)
  
  # -----
  # compute change detection for channel mask and water mask
  # -----
  # v1: Andy Wickert's version
  # use non-masked data so that non-water = 0, water = 1
  # 1a. normalized overlap:
  # -----
  # compute difference:
  D_water_map_raw <- water_post$subtract(water_pre)
  D_water_map <- D_water_map_raw$
    abs() # take absolute vals
  # so that 0 = no change (either land, or water); 1 = change (either to or from water)
  
  # should cleaning-pixels be run using code above?
  if(run_cleaning == F){
    water_pre_corrected <- water_pre
    water_post_corrected <- water_post
  }
  if(run_cleaning == T){
    D_water_map2 <- D_water_map$updateMask(giantwatermask$mask())$ # mask out lakes/noise/crap
      unmask()$ # re-add zeros in all holes created by above mask
      updateMask(water_pre$mask()) # add the cloud mask back in
    cleaned_cells <- D_water_map2$subtract(D_water_map)$
      add(1)
    D_water_map <- D_water_map2 # rename 
    # correct water masks so that cells removed from change map are marked 'dry' in both water masks:
    water_pre_corrected <- water_pre$multiply(cleaned_cells)
    water_post_corrected <- water_post$multiply(cleaned_cells)
  }
  
  # mask so that only cells showing change are left ( reduces risk of hitting maxPixels, 
  # even though the count() reducer is slightly slower than sum()).
  D_water_map_change <- D_water_map$updateMask(D_water_map$gt(0))
  
  # Update mask for raw change map with only changed pixels:
  D_water_map_raw <- D_water_map_raw$updateMask(D_water_map_change$mask())
  
  # then, for raw change map:
  # if pixel = 1 (i.e. became wet):
  is_wetting_permanent <- D_water_map_raw$updateMask(D_water_map_raw$gt(0))$ # mask to cells that became wet
    #   is pixel wet in afterflood data? add to check: 
    add(water_after_sum)$
    divide(cloudfree_count)
  #     if pixel remained wet, 1+1+1+1 / n = 1 so yes, 
  #     if pixel became dry again 1+0+0+0/n = 1/4 so no
  #     if pixel became dry again but THEN got wet again a lot later? 1+1+1+0 = 3/4 so not permanent
  # mask to ONLY cells that became permanently wet
  permanently_wetted <- is_wetting_permanent$updateMask(is_wetting_permanent$eq(1))
  permanently_wetted_int <- permanently_wetted$uint8()
  permanently_wetted_vector <- permanently_wetted_int$reduceToVectors(
    scale= 10,
    geometry= AOI,
    geometryType= 'polygon',
    maxPixels= 1e8,
    eightConnected = T,
    labelProperty = 'zone')
  # make layer of cells that are transiently wetted so these can be marked as 'dry' in the corrected post-flood water map:
  transiently_wetted_step <- is_wetting_permanent$
    updateMask(is_wetting_permanent$lt(1))
  transiently_wetted <- transiently_wetted_step$
    where(transiently_wetted_step$neq(0), 0)$ # reclassify so transiently wetted = 0 
    unmask(1) # and everything else = 1. Then multiply this by post-flood water mask to set transiently 'wet' cells to 'dry'
  water_post_corrected <- water_post_corrected$multiply(transiently_wetted)
  
  # if pixel = -1 (i.e. became dry due to channel abandonment or transient stage reduction):
  is_drying_permanent <- D_water_map_raw$updateMask(D_water_map_raw$lt(0))$ # mask to cells that became dry
    add(water_after_sum)
  #   is pixel dry in all afterflood data? multiply to check: if pixel remained dry it is permanently abandoned, so 
  #     -1 + 0 + 0 + 0 + 0 = -1
  #   is pixel became wet again at any point (e.g. re-inundated due to stage change) it is only transiently abandoned e.g. due to stage, so
  #     -1 + 0 + 0 + 0 + 1 = 0 (or above)
  permanently_dried <- is_drying_permanent$updateMask(is_drying_permanent$eq(-1))
  permanently_dried_int <- permanently_dried$uint8()
  permanently_dried_vector <- permanently_dried_int$reduceToVectors(
    scale= 10,
    geometry= AOI,
    geometryType= 'polygon',
    maxPixels= 1e8,
    eightConnected = T,
    labelProperty = 'zone')
  # make layer of cells that are transiently dried so these can be marked as 'dry' in the corrected pre-flood water map:
  transiently_dried_step <- is_drying_permanent$updateMask(is_drying_permanent$gt(-1))
  transiently_dried <- transiently_dried_step$
    where(transiently_dried_step$neq(-1),0)$ # reclassify so transiently dried = 0
    unmask(1) # and everything else = 1. Then multiply this by pre-flood water mask to set transiently 'wet' cells to 'dry'
  water_pre_corrected <- water_pre_corrected$multiply(transiently_dried)
  
  if(gettinginfo == T){ # getting data for each flood:
    # water surface area before flood (as metric for 'river size'):
    water_area_pre <- water_pre_corrected$reduceRegion(
      reducer = ee$Reducer$sum(), # adds all ones, i.e. water cells ()
      geometry = AOI,
      scale = 10,
      maxPixels = 1e30
    )
    water_area_pre <- water_area_pre$get('nd')$getInfo()
    all_gauges$water_area_preflood_in_px[i] <- water_area_pre
    
    # water surface area after flood
    water_area_post <- water_post_corrected$reduceRegion(
      reducer = ee$Reducer$sum(), # adds all ones, i.e. water cells ()
      geometry = AOI,
      scale = 10,
      maxPixels = 1e30
    )
    water_area_post <- water_area_post$get('nd')$getInfo()
    all_gauges$water_area_postflood_in_px[i] <- water_area_post
    
    # average water surface area:
    water_area_avg <- mean(c(water_area_pre, water_area_post), na.rm = T)
    all_gauges$water_area_av_in_px[i] <- water_area_avg
    
    # sum permanently dried/wetted cells + save to dataframe
    dried_count <- permanently_dried$reduceRegion(
      reducer = ee$Reducer$count(),
      geometry = AOI,
      scale = 10,
      maxPixels = 1e30
    )
    dried_count <- dried_count$get('nd')$getInfo()
    all_gauges$perm_dried_px[i] <- dried_count
    wetted_count <- permanently_wetted$reduceRegion(
      reducer = ee$Reducer$count(),
      geometry = AOI,
      scale = 10,
      maxPixels = 1e30
    )
    wetted_count <- wetted_count$get('nd')$getInfo()
    all_gauges$perm_wet_px[i] <- wetted_count
    all_gauges$perm_wetting_norm_by_AOI_area[i] <- wetted_count / A # normalise by count of cloudfree cells for metric of change
  }
  
  # re-add maps of permanent drying and wetting for map of 'real' channel change:
  D_water_map_change <- permanently_wetted$unmask(permanently_dried)
  
  D <- D_water_map_change$reduceRegion( # count all to get number of pixels with change
    reducer = ee$Reducer$count(),
    geometry = AOI, # all pixels within the AOI
    scale = 10,
    maxPixels = 1e30 # set this to max!
  )
  
  if(gettinginfo == T){
    D <- D$get("nd")$getInfo() 
    all_gauges$area_change_px[i] <- D # assign to data frame
    test <- (dried_count + wetted_count) / D # error trap
    if(test < 0.99 | test > 1.01){ # summed dry/wet cells must be within 1% of total change calculated
      print ('Dried and wetted cells do not sum to equal change count!!')
      break
    }
  }
  
  # for random scatter parameter (phi):
  # first calculate fraction of wet and dry pixels in t0 and t1:
  t0_wet <- water_pre_corrected$reduceRegion( # first get n cells dry or wet
    reducer = ee$Reducer$sum(), 
    geometry = AOI,
    scale = 10,
    maxPixels = 1e30)
  if(gettinginfo == T){
    t0_wet <- t0_wet$get("nd")$getInfo() # number of wet cells
    t0_wet <- t0_wet / A # convert to proportion by dividing by total n cells
    all_gauges$t0_wet[i] <- t0_wet
    t0_dry <- 1 - t0_wet # proportion dry = anything not wet
    all_gauges$t0_dry[i] <- t0_dry
  }
  
  # rep for t1 (post flood timestep)
  t1_wet <- water_post_corrected$reduceRegion(
    reducer = ee$Reducer$sum(),
    geometry = AOI,
    scale = 10,
    maxPixels = 1e30)
  if(gettinginfo == T){
    t1_wet <- t1_wet$get("nd")$getInfo() # number of wet cells
    t1_wet <- t1_wet / A# convert to proportion
    all_gauges$t1_wet[i] <- t1_wet
    t1_dry <- 1 - t1_wet # proportion dry = anything not wet
    all_gauges$t1_dry[i] <- t1_dry
    # compute phi:
    phi_param <- t0_wet * t1_dry + t0_dry * t1_wet
    all_gauges$phi_val[i] <- phi_param
    
    # normalized overlap:
    normo <- 1 - (D / (A * phi_param)) # remember A is number of non-null cells (not area)
    # values close to 1 indicate flow map practically unchanged
    # values < 0 indicate change is > that which we'd expect if same prop. of wet/dry were randomly scattered.
    all_gauges$norm_overlap[i] <- normo
  }
  
  # ----
  # 1b reworking of the fluvial surface (page 400, Wickert et al)
  #----
  # first calculate total number of unreworked pixels:
  N_water_map <- water_post_corrected$add(water_pre_corrected)# add so that 1 = once channel
  # and 2 = always channel and 0 = never channel (i.e. unreworked)
  # mask to just the zero values (unreworked):
  N_water_map <- N_water_map$updateMask(N_water_map$eq(0))
  # count the zeros:
  N <- N_water_map$reduceRegion(
    reducer = ee$Reducer$count(),
    geometry = AOI, 
    scale = 10,
    maxPixels = 1e30
  )
  if(gettinginfo == T){
    N <- N$get("nd")$getInfo()
    all_gauges$Num_unreworked_pix[i] <- N
    # then compute fraction reworked (Wickert et al, eqn 7):
    f_R <- 1 - (N / (A * t0_dry))
    all_gauges$frac_reworked[i] <- f_R
    
    # ----
    # 1c Instantaneous Channel Planform Change (Wickert et al p 401)
    # some of their assumptions not met here (e.g. that noise dist same for both t-steps, 
    # or that  rate of channel mvt is same for nearby timestamps (window can be several mths long!))
    # so instead used v simple Area of change (in pixels) metric; also norm by A of polygon (in pixels)
    # ----
    # Area of change already calculated above (D)
    # normalized area of change:
    D_norm <- D / A
    all_gauges$change_norm_by_AOI_area[i] <- D_norm
  }
  
  #-------------
  # some pretty plots:
  #-------------
  if(debugging == T){
    # visualising change outlines:
    # Create an empty image into which to paint the features, cast to byte.
    empty <- ee$Image()$byte()
    
    # Paint all the polygon edges with the same number and 'width', display.
    outline_wetted <- empty$paint(
      featureCollection = permanently_wetted_vector,
      color = 1,
      width = 2
    )
    outline_dried <- empty$paint(
      featureCollection = permanently_dried_vector,
      color = 1,
      width = 2
    )
    outline_AOI <- empty$paint(
      featureCollection = AOI,
      color = 1,
      width = 2
    )
    
    Map$centerObject(AOI)
    m <- Map$addLayer(
      eeObject = pre_flood2,
      visParams = list(
        bands = c("B4", "B3", "B2"),
        max = 0.2),
      shown = T,
      name = "rgb_pre"
    ) +
      Map$addLayer(
        eeObject = post_flood2,
        visParams = list(
          bands = c("B4", "B3", "B2"),
          max = 0.2),
        shown = F,
        name = "rgb_post"
      ) +
      # Map$addLayer(snow_pre, shown = F) +
      # Map$addLayer(snow_post, shown = F)+
      Map$addLayer(
        eeObject = D_water_map_change,
        visParams = list(min = 0, max = 1,
                         palette = c('000000', 'FFFF00')),
        shown = F,
        name = "change_addition"
      ) +
      
      Map$addLayer(
        eeObject = water_pre_corrected,
        visParams = list(min = 0, max = 1,
                         palette = c('000000', 'FFFF00')),
        shown = F,
        name = "water_pre"
      ) +
      Map$addLayer(
        eeObject = water_post_corrected,
        visParams = list(min = 0, max = 1,
                         palette = c('000000', '0000FF')),
        shown = F,
        name = "water_post"
      ) +
      
      Map$addLayer(water_after_sum, name = 'Water after sum') +
      Map$addLayer(permanently_wetted, visParams = list(palette = c('FFFF00')),
                   name = 'permanently eroded') +
      Map$addLayer(transiently_wetted_step, visParams = list(palette = c('FFB6C1')),
                   name = 'transiently eroded') +
      # Map$addLayer(permanently_dried,
      #              visParams = list(
      #                palette = c('0000FF')
      #              ), 
      #              name = 'permanently abandoned',
      #              shown = T) +
      Map$addLayer(outline_wetted, list(palette = "FFFF00"), "Permanently eroded") +
      # Map$addLayer(outline_dried, list(palette = "0000FF"), "Permanently abandoned") +
      Map$addLayer(outline_AOI, list(palette = "FFFFFF"), "AOI")
      
      print(m)
  }
  
  
  print(paste0('Flood # ', dat$floodID, ' done!'))
}
if(writinginfo == T){
  all_gauges2 <- as_tibble(all_gauges) %>%
    dplyr::select(-geometry) 
  # write.csv(all_gauges2,
  #           file = paste0('./data/outputs/', country, '_', window_length,
  #                         'day_windows_change_', today(), '.csv'),
  #           row.names = F
  # )
  constants_used <- data.frame(area_keep_threshold,
                               bands_inc_cloud,
                               channel_belt,
                               cleaning_pixels,
                               MAX_CLOUD_PROBABILITY,
                               mndwi_param,
                               ndvi_param,
                               run_cleaning,
                               flood_thr)
  # write.csv(constants_used,
  #           file = paste0('./data/outputs/', country, '_', window_length,
  #                         'day_windows_change_', today(), '_parameters.csv'),
  #           row.names = F
  # )
}
if(savetodrive == T){
  # bounding box w/in which to download images:
  b_box <- AOI$bounds()
  # # pre_flood3 <- pre_flood2$select('B2', 'B3', 'B4')
  # # task1 <- ee$batch$Export$image$toDrive(
  # #   image = pre_flood3,
  # #   description = paste0('preflood ', country, ' ', myflood),
  # #   folder = 'earthengine',
  # #   region = b_box,
  # #   scale = 10,
  # #   fileFormat = 'GeoTIFF'
  # # )
  # task1$start()
  # ee_monitoring(task1)
  # # postflood
  # post_flood3 <- post_flood2$select('B2', 'B3', 'B4')
  # task2 <- ee$batch$Export$image$toDrive(
  #   image = post_flood3,
  #   description = paste0('postflood ', country, ' ', myflood),
  #   folder = 'earthengine',
  #   region = b_box,
  #   scale = 10,
  #   fileFormat = 'GeoTIFF'
  # )
  # task2$start()
  # ee_monitoring(task2)
  # # change detection
  # task3 <- ee$batch$Export$table$toDrive(
  #   collection = permanently_wetted_vector,
  #   description = paste0(country, '_', myflood, '_perm_eroded_vector'),
  #   folder = 'earthengine',
  #   fileFormat = "shp"
  # )
  # task3$start()
  # ee_monitoring(task3)
  
  # water masks:
  # preflood:
  task1 <- ee$batch$Export$image$toDrive(
    image = water_pre_corrected,
    description = paste0('preflood water ', country, ' ', myflood),
    folder = 'earthengine',
    region = b_box,
    scale = 10,
    fileFormat = 'GeoTIFF'
  )
  task1$start()
  ee_monitoring(task1)
  
  # postflood:
  task2 <- ee$batch$Export$image$toDrive(
    image = water_post_corrected,
    description = paste0('postflood water ', country, ' ', myflood),
    folder = 'earthengine',
    region = b_box,
    scale = 10,
    fileFormat = 'GeoTIFF'
  )
  task2$start()
  ee_monitoring(task2)
}
my_end_time <- Sys.time()
(time_taken <- my_end_time - mystarttime)
