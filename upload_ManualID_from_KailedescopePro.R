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
# AI Disclosure: OpenAI's ChatGPT 3.5 was used as a coding assistance tool while developing this R Script.
#
#**User Modifcations Required: The user needs to define the File Locations, Output CSV name, and new Column headers.**
#     You will see stars "*" on headers where edits are required.
# 
# Version: 9
# Date: March 12, 2024
# Author: Tyne M. Baker
# Change Log: 
#   24JAN2023- V1- Initial drafting of functional script.
#   25JAN2023- V2 Clean-up and formatting to match other upload ID scripts.
#   30JAN2023- V3 Clarify that this script can be used for AutoID for Bats and Cluster Analysis outputs.
#   28FEB2023- V4 Test on Mac and improve script for cross-platform performance.
#   01MAR2023- V5 Fix import of headers from CSV to have consistent import.
#   02MAR2023- V6 Fix file path splitting method to be more concise and ensure a reserved is used.
#   03MAR2023- V7 Add a checking step for the max number of delimiters in the FOLDER column.
#   20APR2023- V8 MAC tests and small bug fixes.
#   12MAR2024- V9- Added AI disclosure statement.

# ------Clear the Workspace-------
rm(list = ls())

# ------Load Libraries------
library(tidyverse)
library(tcltk)

# ------Define File Locations and Output Name*------
# Find the file name and path to the saved cluster file on your computer.
source_filepath <- file.choose()

# Find the directory where you'd like to save the modified output csv.
destination_filepath <- tk_choose.dir()

#Edit the file name within the "" below to name the output csv. Name it with a different name from the input file name.
output_CSV_name <-"KPRO_ID_data.csv"

# ------Load cluster CSV as Raw Data and Clean Headers------

#Read in CSV file
ID_rawdata <- read.table(source_filepath, sep=",", header= TRUE)

#Get column names from the original csv file
raw_headers <- as.character(read.csv(source_filepath, nrow=1, header=FALSE))

# Clean these headers by replacing spaces with underscores and asterisks with empty strings
clean_headers <- str_replace_all(raw_headers, c(" " = "_", "\\*" = ""))

#replace the headers in the raw dataset with the cleaned headers
colnames(ID_rawdata)<-clean_headers

# See the dataframe you just made
view(ID_rawdata)

# ------Define New Column Headers*-----

#All headers MUST be unique. 
  #You cannot have any repeats when creating the following Header groups, within
  #and between groups. It will result in replacement of previously split columns 
  #as you progress through code.

# __Headers for the INDIR column__ #

#Print the first entry in the INDIR column.
head(ID_rawdata$INDIR,1)

#Examine the printed example, define column headers for each nested file folder listed between the semi-colons.
INDIR_headers<- c("insert","heading","names","for","each","item","between","slashes")

# __Headers for the FOLDER column__ #

#Does the FOLDER column contains more than one category?
if(is.na(ID_rawdata$FOLDER[1]) || !str_detect(ID_rawdata$FOLDER[1], "\\\\")) {
  message("No, skip to Headers for the MANUAL_ID column")
} else {
  max_index_FOLDER <- str_count(ID_rawdata$FOLDER, "\\\\")%>%
    which.max()
  message("Yes, here is the FOLDER row with the most delimiters: ", ID_rawdata[max_index_FOLDER,"FOLDER"])
}

#If yes, examine the message and define column headers for each nested file folder listed between the semi-colons.
FOLDER_headers<- c("insert","heading","names","for","each","item","between","slashes")

# __Headers for the MANUAL_ID column__ #

# Find the "MANUAL_ID" with the most commas, and print it.
max_index_ID <- str_count(ID_rawdata$MANUAL_ID, ",")%>%
                which.max()
message("Here is the MANUAL_ID row with the most delimiters: ", ID_rawdata[max_index_ID,"MANUAL_ID"])

#Use the message to define column headers for your comma-delimited labelling schema.
MANUAL_ID_headers<- c("insert","heading","names","for","each","item","between","commas")

# ------Split out the new columns------

#Create a new dataframe where we will do our manipulations
ID_data<- ID_rawdata
message("The unmodified ID_data dataframe has ", ncol(ID_data), " columns")

#Split out the filepaths in the INDIR column to new columns.
ID_data<-separate(data = ID_data, col = INDIR, into = c(INDIR_headers), sep = "\\\\", remove = FALSE)
message ("INDIR column was split over ",length(INDIR_headers)," new columns.
         The ID_data dataframe has ", ncol(ID_data), " columns, now")

#Split out the filepaths in the FOLDER column to new columns, if necessary.
if(is.na(ID_data$FOLDER[1]) || !str_detect(ID_data$FOLDER[1], "\\\\")) {
  message("No split necessary for FOLDER column, the ID_data dataframe still has ", ncol(ID_data), " columns.")
} else {
  ID_data <- separate(data = ID_data, col = FOLDER, into = c(FOLDER_headers), sep = "\\\\", remove = FALSE)
  message("FOLDER column was split over ",length(FOLDER_headers)," new columns. 
          The ID_data dataframe has ", ncol(ID_data), " columns, now.")
}

#Split out the annotations in the MANUAL.ID. column to new columns.
ID_data<-separate(data = ID_data, col = MANUAL_ID, into = c(MANUAL_ID_headers), sep = ",", remove = FALSE)
message("MANUAL.ID. column was split over ",length(MANUAL_ID_headers)," new columns. 
        The ID_data dataframe has ", ncol(ID_data), " columns, now")

# ------ Export modified dataframe to a new CSV ------

#View the final modified ID_data dataframe, verify it is complete.
view(ID_data)

#Export ID_data to a CSV, so you can import into other scripts or statitical analyses.
write.csv(ID_data, file.path(destination_filepath,output_CSV_name), row.names=FALSE)

                   