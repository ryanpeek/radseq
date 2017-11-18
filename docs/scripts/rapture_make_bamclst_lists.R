# RAPTURE bamlist & bamclst creation for different groups/sites
# 2017-Jun

# This script can be used to generate bamlists and bamlist_clst files for different subsampled groups.
# The following pieces should have already occurred and the subsampled bamlists should already be locally 
# available in a "data_output" folder within your R Project.

# STEPS 1A -- 1C HAPPEN ON TERMINAL/COMMAND LINE
# 1A. SUBSAMPLE ON FARM ----------------------------------------------------

# sbatch -p high -t 24:00:00 02b_run_subsample.sh bam_sort_list 30000

# 1B. MAKE BAMLIST_FLT FILE ------------------------------------------------

# ls *flt_100000* > bamlist_flt_100k

# 1C. USE SFTP TO GRAB FILE ------------------------------------------------

# cd to location where your RProject/data_output folder lives
# sftp -P 2022 USERNAME@farm.cse.ucdavis.edu
# cd to location where the subsampled bamlist lieves (e.g., cd projects/rana_rapture/fastq)
# use GET to pull files from cluster/farm to your local drive and PUT for opposite
# get bamlist_flt_100k

# 2. LOAD LIBRARIES ----------------------------------------------------------

suppressMessages({
  library(tidyverse);
  library(lubridate);
  library(magrittr)
})

options(scipen = 12) # to avoid issues with paste functions, & joining on subsample number

# 3. GET DATA ----------------------------------------------------------------

# set subsample number (so need corresponding subsampled bamlist locally, see Steps 1A-1C)
bamNo<-100

# set site name (will be appended into filename)
site<-"RASI_all"

# Examples: "NFA_sites", "NFA", "YUB", "SM-RASI", "RANA", "AMER_YUB", "MFA_RUB", "RASI_all"

# The METADATA: 
metadat<- read_csv("data_output/rapture01_metadata.csv")
# NOTE # metadata can include any all info you want, but at minimum needs a "Seq" column 
# with the full plate/well code...e.g., "SOMM165_CGGAAT_RA_GGACAAGCTATGCAGG". Additional
# columns I use include: 
# "Seq"              "plate_barcode"    "well_barcode"     "PlateID"          "Collection"      
# "Samples"          "RAD_ID"           "Well"             "SampleID"         "SPP_ID"          
# "lat"              "lon"              "YYYY"           "HUC_8"            "HUC_10"          
# "HU_8_Name"        "SampleType"       "Extract_ul"       "LabID"            "Collector"       
# "Project"          "Elevation_m"      "conc_ng.uL"       "Locality"         "Locality_details"

# this is the filtered subsampled list: (based on files named like: bamlist_flt_50k)
# modify per user's naming convention
bams <- read_tsv(paste0("data_output/bamlists/bamlist_flt_",bamNo,"k"), col_names = F)

# remove the *000 component for join, requires fixing scipen for digits
subsamp<-bamNo*1000
bams$X1<-gsub(pattern = paste0(".sort.flt_",subsamp,".bam"), replacement = "", bams$X1)
# should look like this now: "SOMM165_AAATGG_RA_GGAACGAACGTGCAGG"
# instead of: "SOMM165_AAATGG_RA_GGAACGAACGTGCAGG.sort.flt_100000.bam"


# 4. FILTER BY: -----------------------------------------------------------

# any number of filtering options can occur...below a few different versions

# 4a. FILTER BY HUC OR REGIONS --------------------------------------------

# NFA (H8) & AMER/YUB
#h8<- c("North Fork American", "Upper Yuba", "South Fork American")
#h8<- c("North Fork American")

# join samples with platelist:
#dat <- filter(metadat, HU_8_Name %in% h8)

# 4b. FILTER BY PLATE -----------------------------------------------------

# MUSSULMAN SAMPLES ONLY:
#dat<- filter(metadat, RAD_ID=="RAD-212" | RAD_ID=="RAD-213") %>% filter(is.na(YYYY))

# ALL RANIDS
#dat<- filter(metadat, Collection=="WSU4")

# 4c. FILTER BY SITE NAME -------------------------------------------------

# filter by site name:
# dim(metadat[startsWith(x = metadat$Locality, "NFA"),])
# dim(metadat[startsWith(x = metadat$Locality, "NFY"),])
# dim(metadat[startsWith(x = metadat$Locality, "MFA"),])
# dim(metadat[startsWith(x = metadat$Locality, "RUB"),])

# Specific Sites Only: NFA
#dat <- metadat[startsWith(x = metadat$Locality, "NFA"),]

# Specific Sites Only: MFA_RUB
#dat <- metadat[startsWith(x = metadat$Locality, "MFA")| startsWith(x = metadat$Locality, "RUB"),]

# 4d. FILTER BY SPECIES ---------------------------------------------------

# filter to RASI ONLY for both NFA and WSU samples
dat <- filter(metadat, SPP_ID=="RASI" | SPP_pc1=="RASI")

# 5. JOIN WITH FLT SUBSAMPLE LIST -----------------------------------------

# check col names for join...should be BAMFILE name with plate/well ID
dfout <- inner_join(dat, bams, by=c("Seq"="X1")) %>% arrange(Seq)

# 6. WRITE TO BAMLIST -----------------------------------------------------

# Write to bamlist for angsd call:
write_delim(as.data.frame(paste0(dfout$Seq, ".sort.flt_",subsamp,".bam")),
           path = paste0("data_output/bamlists/bamlist_",site,"_",bamNo,"k"), col_names = F)

# 7. WRITE CLST FILE ---------------------------------------------------------

names(dfout) # check and see what you've got

# use dplyr to select and rename, modify as needed
clst_out1<-dfout %>% 
  dplyr::select(Locality, SampleID, HUC_10) %>% 
  dplyr::rename(FID=Locality, IID=SampleID, CLUSTER=HUC_10) %>% 
  mutate(CLUSTER=1) # use this if 3rd col is irrelevant
head(clst_out1)

# count NAs in your clst file
clst_out1 %>% filter(is.na(FID)) %>% tally

# if NAs, replace with "NO_ID"
clst_out1 <- clst_out1 %>% mutate(FID=if_else(is.na(FID), "NO_ID", FID))

# Write a clst file for PCA plots:
write_delim(clst_out1, path=paste0("data_output/bamlists/bamlist_",site,"_",bamNo,"k_clst"))


# 8. BASH: PCA CALC SITES --------------------------------------------------

# Use angsd to run pca_calc_sites script: 
# sbatch -p high -t 24:00:00 03_pca_calc_sites.sh bamlist_YUB_100k yub_100k

# 9. BASH: MAKE PCA PLOTS --------------------------------------------------

# sbatch -p med -t 12:00:00 04_pca_plot.sh yub_100k bamlist_YUB_100k_clst

# can check datestamp with ls -l FILE*
# then sftp and "get" to get pdfs back to your computer (see step 1C).
