# Script Name: Upload_Annotations_from_RavenPro.R
#
# Purpose: This script is intended to take a TXT output from the bioacoustics 
#          analysis program RavenPro and manipulate the data to make it more 
#          easily sorted and usable for statistical analysis. 

# Input: A TXT file output from RavenPro
# Output: A modified dataframe saved as a CSV file
#
# Dependencies: This script requires the tidyverse library to run. 
#
#**User Modifcations Required: The user needs to define the File Locations, and Output CSV name.**
#     You will see stars "*" on headers where edits are required.
#     You will also see an "OPTIONAL" section, you can choose to run this or not.
#
# Version: 2
# Date: Jan 30th, 2023
# Author: Tyne M. Baker
# Change Log: 
#   24JAN2023- V1- Initial drafting of functional script.
#   30JAN2023- V2- Split from RavenLite Script. Clean-up and formatting to match other upload ID scripts.
#   28FEB2023- V3- Test on Mac and improve script for cross-platform performance.

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
output_CSV_name <-"RavenPro_Annotation_data.csv"

# ------Load cluster TXT as Raw Data------

# Read in the TXT file as a dataframe
ID_rawdata <- read.table(source_filepath, sep="\t", header= TRUE)

# ------OPTIONAL: Remove Duplicate Rows------

#Raven's default view is to show you multiple views: spectrogram and waveform. 
#Additionally, some acousticians may add different views to accomodate their annotation needs.
#Before you export the annotation table from Raven you can uncheck views so only one
#is showing, then your table will be free of duplicates. 

#If you do not uncheck duplicate views prior to export, the following code can be used to remove duplicates.
ID_data <- ID_rawdata %>% distinct(Selection, .keep_all = TRUE)

# ------ Export modified dataframe to a new CSV ------

#View the final modified ID_data dataframe, verify it is complete.
view(ID_data)

#Export ID_data to a CSV, so you can import into other scripts or statitical analyses.
write.csv(ID_data, file.path(destination_filepath,output_CSV_name), row.names=FALSE)
