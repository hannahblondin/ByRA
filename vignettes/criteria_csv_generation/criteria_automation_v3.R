#libraries
library(dplyr)
library(readr)

#DATA
## provide working directory and input csv path below
#setwd("set/working/directory")

## import data
crit <- read_csv("criteria_df.csv")

## force scenario field to character
crit$scenario <- as.character(crit$scenario)


# CREATE HEADER AND SPACER ROWS FOR FINAL TABLE
r1 <- c("HABITAT NAME", "species_sim", " ", " ", "CRITERIA TYPE")
space <- c("", "", "", "", "")
r3 <- c("HABITAT RESILIENCE ATTRIBUTES","", "", "", "")
r4 <- c("HABITAT STRESSOR OVERLAP PROPERTIES","", "", "", "")


#SET UP FOR LOOP 

## Drop row of criterion names
df <- crit[-1,]

## This dictates how many loops run based on the number of scenarios in the input table
runs <- unique(df$scenario)

## Create a df of just the critera names to later bind to the criteria tables
names <- crit[1,]

## Create boolean vectors identifying columns needed for each table
res <- grepl("score|resilience", colnames(crit)) 
stres <- grepl("score|stressor1", colnames(crit)) 

## Create empty list for appending to in the first for loop
errors <- list()

#START LOOP FOR TRANSPOSING DATA

# This loop checks for errors and creates a list of scenarios that have errors
for(i in 1:length(runs)){
  res_crit <- df[df$scenario == i,] #uses scenario column to subset dataframe
  numRows <- nrow(res_crit) #get number of rows in current df
  findNAs <- as.data.frame(cbind(lapply(res_crit, function(x) sum(is.na(x))))) #find the number of nas for each column
  colna <- rownames(subset(findNAs, (findNAs$V1 < numRows & findNAs$V1 > 0))) #find columns that have errors
  if(length(colna > 0)){
    scenNum <- i
    errors[[length(errors)+1]] <- paste("scenario ",scenNum,": ",paste(colna,collapse=", "))
  } }

# This loops checks for errors identified in the loop above and creates the csvs if no errors exist.
for(i in 1:length(runs)){
  if(length(errors) > 0){
    print("Errors were found in the following scenarios:")
    print(errors)
    stop("Exiting since errors exist in the input table.")
  }
  #transpose resilience criteria
  res_crit <- df[df$scenario == i,] #uses scenario column to subset dataframe
  res_crit <- bind_rows(names, res_crit) #adds column descriptions back in after subset
  res_crit <- res_crit[res]
  res_crit <- res_crit[ , colSums(is.na(res_crit)) == 0]
  res_crit <- t(res_crit)
  res_crit[res_crit == "scoretype"] <- ""
  
  #transpose stressor criteria
  
  stress_crit <- df[df$scenario == i,]
  stress_crit <- bind_rows(names, stress_crit)
  stress_crit <- stress_crit[stres]
  stress_crit <- stress_crit[ , colSums(is.na(stress_crit)) == 0]
  stress_crit <- t(stress_crit)
  stress_crit[stress_crit == "scoretype"] <- "gear_sim"
  
  
  #bind to top
  crit_tables <- rbind(r1,space, r3, res_crit,space,r4,stress_crit)
  write.table(crit_tables, paste0("criteria_scores_",i,".csv"), append = FALSE, sep = ",",
              row.names = FALSE, col.names = FALSE)
  
}

