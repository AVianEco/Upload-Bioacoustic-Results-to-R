# Script Name: Upload_ManualID_from_KailedescopePro.R
#
# Purpose: This script is intended to take a CSV output from the bioacoustics 
  #analysis program Kailedescope Pro and manipulate the data to make it more 
  #easily sortable and usable for statistical analysis. It can be used for outputs
  #from the Cluster Analysis (Cluster.csv) or AutoID for Bats (id.csv)
#
# Input: A CSV file output from Kailedescope Pro (cluster.csv or id.csv)
# Output: A modified dataframe saved as a CSV file
#
# Dependencies: This script requires the tidyverse library to run. 
#
#**User Modifcations Required: The user needs to define the File Locations, Output CSV name, and new Column headers.**
#     You will see stars "*" on headers where edits are required.
# 
# Version: 2
# Date: Jan 30th, 2023
# Author: Tyne M. Baker
# Change Log: 
#   24JAN2023- V1- Initial drafting of functional script.
#   25JAN2023- V2 Clean-up and formatting to match other upload ID scripts.
#   30JAN2023- V3 Clarify that this script can be used for AutoID for Bats and Cluster Analysis outputs.

# ------Clear the Workspace-------
rm(list = ls())

# ------Load Libraries------
library(tidyverse)

# ------Define File Locations and Output Name*------
# Find the file name and path to the saved cluster file on your computer.
source_filepath <- file.choose()

# Find the directory where you'd like to save the modified output csv.
destination_filepath <- choose.dir()

#Edit the file name within the "" below to name the output csv. Name it with a different name from the input file name.
output_CSV_name <-"KPRO_ID_data.csv"

# ------Load cluster CSV as Raw Data------

# Read in the CSV file (cluster.csv OR id.csv) as a character vector
ID_rawdata <- scan(source_filepath, what = "character", sep = "\n")

# Replace all the backslashes in cells of this dataframe with semi-colons
ID_rawdata <- gsub("\\", ";", ID_rawdata,fixed=TRUE)

# Convert the character vector into a data frame
ID_rawdata <- read.csv(textConnection(ID_rawdata), header = TRUE)

# See the dataframe you just made
view(ID_rawdata)

# ------Define New Column Headers*-----

# __Headers for the INDIR column__ #

#Print the first entry in the INDIR column.
head(ID_rawdata$INDIR,1)

#Examine the printed example, define column headers for each nested file folder listed between the semi-colons.
INDIR_headers<- c("insert","heading","names","for","each","item","between","semicolons")

# __Headers for the FOLDER column__ #

#Does the FOLDER column contains more than one category?
if(is.na(ID_rawdata$FOLDER[1]) || !str_detect(ID_rawdata$FOLDER[1], ";")) {
  print("No, skip to Headers for the MANUAL.ID. column")
} else {
  print("Yes, here is the first row")
  head(ID_rawdata$FOLDER, 1)
}

#If yes, examine the printed example and define column headers for each nested file folder listed between the semi-colons.
FOLDER_headers<- c("insert","heading","names","for","each","item","between","semicolons")

# __Headers for the MANUAL.ID. column__ #

# Find the "MANUAL.ID." with the most commas, and print it.
max_index <- str_count(ID_rawdata$MANUAL.ID., ",")%>%
                which.max()
print(ID_rawdata[max_index,"MANUAL.ID."])


#Use the printed label to define column headers for your comma-delimited labelling schema.
MANUAL.ID._headers<- c("insert","heading","names","for","each","item","between","commas")

# ------Split out the new columns------

#Create a new dataframe where we will do our manipulations
ID_data<- ID_rawdata
message("The unmodified ID_data dataframe has ", ncol(ID_data), " columns")

#Split out the filepaths in the INDIR column to new columns.
ID_data<-separate(data = ID_rawdata, col = INDIR, into = c(INDIR_headers), sep = ";", remove = FALSE)
message ("The ID_data dataframe has ", ncol(ID_data), " columns, now")

#Split out the filepaths in the FOLDER column to new columns, if necessary.
if(is.na(ID_data$FOLDER[1]) || !str_detect(ID_data$FOLDER[1], ";")) {
  message("No split necessary for FOLDER column, the ID_data dataframe still has ", ncol(ID_data), " columns.")
} else {
  ID_data <- separate(data = ID_data, col = FOLDER, into = c(FOLDER_headers), sep = ";", remove = FALSE)
  message("FOLDER column was split into ", ncol(ID_data), " new columns")
}

#Split out the annotations in the MANUAL.ID. column to new columns.
ID_data<-separate(data = ID_data, col = MANUAL.ID., into = c(MANUAL.ID._headers), sep = ",", remove = FALSE)
message("The ID_data dataframe has ", ncol(ID_data), " columns, now")

# ------ Export modified dataframe to a new CSV ------

#View the final modified ID_data dataframe, verify it is complete.
view(ID_data)

#Export ID_data to a CSV, so you can import into other scripts or statitical analyses.
write.csv(ID_data, file.path(destination_filepath,output_CSV_name), row.names=FALSE)

                   