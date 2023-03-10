# Script Name: Upload_Annotations_from_RavenLite.R
#
# Purpose: This script is intended to take a TXT output from the bioacoustics 
#          analysis program RavenLite and manipulate the data to make it more 
#          easily sorted and usable for statistical analysis. 

# Input: A TXT file output from RavenLite
# Output: A modified dataframe saved as a CSV file
#
# Dependencies: This script requires the tidyverse library to run. 
#
#**User Modifcations Required: The user needs to define the File Locations, Output CSV name, and new Column headers.**
#     You will see stars "*" on headers where edits are required.
#     You will also see an "OPTIONAL" section, you can choose to run this or not.
#
# Version: 2
# Date: Jan 30th, 2023
# Author: Tyne M. Baker
# Change Log: 
#   24JAN2023- V1- Initial drafting of functional script.
#   30JAN2023- V2- Split from RavenPro Script. Clean-up and formatting to match other upload ID scripts.

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
output_CSV_name <-"RavenLite_Annotation_data.csv"

# ------Load cluster TXT as Raw Data------

# Read in the TXT file as a dataframe
ID_rawdata <- read.table(source_filepath, sep="\t", header= TRUE)

# ------Define New Column Headers for "Annotation" Column*-----

# Find the "Annotation" with the most commas, and print it.
max_index <- str_count(ID_rawdata$Annotation, ",")%>%
  which.max()
print(ID_rawdata[max_index,"Annotation"])

#Use the printed label to define column headers for your comma-delimited labelling schema.
ID_headers<- c("insert","heading","names","for","each","item","between","commas")

# ------OPTIONAL: Remove Duplicate Rows------

#Raven's default view is to show you multiple views: spectrogram and waveform. 
  #Additionally, some acousticians may add different views to accomodate their annotation needs.
  #Before you export the annotation table from raven you can uncheck views so only one
  #is showing, then your table will be free of duplicates. 

#If you do not uncheck duplicate views prior to export, the following code can be used to remove duplicates.
ID_data <- ID_rawdata %>% distinct(Selection, .keep_all = TRUE)

# ------Split out the new columns------

#separate annotation into comma delimited columns using previously defined Annotation_headers
message("The unmodified ID_data dataframe has ", ncol(ID_data), " columns")
ID_data<-separate(data = ID_data, col = Annotation, into = c(ID_headers), sep = ",", remove = FALSE)
message ("The ID_data dataframe has ", ncol(ID_data), " columns, now")

# ------ Export modified dataframe to a new CSV ------

#View the final modified ID_data dataframe, verify it is complete.
view(ID_data)

#Export ID_data to a CSV, so you can import into other scripts or statitical analyses.
write.csv(ID_data, file.path(destination_filepath,output_CSV_name), row.names=FALSE)
