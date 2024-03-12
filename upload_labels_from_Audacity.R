# Script Name: Upload_Labels_from_Audacity.R
#
# Purpose: This script is intended to take a CSV output from the Acoustics 
#program Audacity and manipulate the data to make it more 
#easily sortable and usable for statistical analysis. 
#
# Input: A TXT file output from Audacity
# Output: A modified dataframe saved as a CSV file
#
# Dependencies: This script requires the tidyverse library to run.
#
# AI Disclosure: OpenAI's ChatGPT 3.5 was used as a coding assistance tool while developing this R Script.
#
#**User Modifcations Required: The user needs to define the File Locations, Output CSV name, and new Column headers**
#     You will see stars "*" on headers where edits are required.
#     You will also see an "OPTIONAL" section, you can choose to run this or not.
#
# Version: 4
# Date: March 12, 2024
# Author: Tyne M. Baker
# Change Log: 
#   24JAN2023- V1- Initial drafting of functional script.
#   30JAN2023- V2 Clean-up and formatting to match other upload ID scripts.
#   28FEB2023- V3- Test on Mac and improve script for cross-platform performance.
#   12MAR2024- V4- Added AI disclosure statement.

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
output_CSV_name <-"Audacity_Label_data.csv"

# ------Load label txt as Raw Data------
ID_rawdata <- read.table(source_filepath, sep="\t", header=FALSE)

#------Define Column Headers for your IDs*------

# Find the user-defined label with the most commas, and print it. 
max_index <- str_count(ID_rawdata$V3, ",")%>%
  which.max()
print(ID_rawdata[max_index,"V3"])


#Use the printed label to define column headers for your comma-delimited labelling schema. 
ID_headers<-c("insert","heading","names","for","each","item","between","commas")

#------Concatenate the returned rows so all data for each ID is on one row.------#

# create a sequence of every second row index
row_indices <- seq(2, nrow(ID_rawdata), 2)

# subset the dataframe using the row indices
df_subset <- ID_rawdata[row_indices, ]

# concatenate the rows of the subset with the rows above them
ID_data <- cbind(ID_rawdata[-row_indices, ], df_subset)

#label the existing columns
headers<- c("time_start","time_end","raw_ID","null","low_frequency","high_frequency")
colnames(ID_data)<-headers

#-----Split your comma-delimited labels into separate columns-----
message("The unmodified ID_data dataframe has ", ncol(ID_data), " columns")
ID_data<-separate(data = ID_data, col = raw_ID, into = c(ID_headers), sep = ",", remove = FALSE)
message ("The ID_data dataframe has ", ncol(ID_data), " columns, now")

#------OPTIONAL: Remove null or "\" row.-----

# Remove null column
ID_data <- subset(ID_data, select = -c(null))
message ("The ID_data dataframe has ", ncol(ID_data), " columns, now")

# ------ Export modified dataframe to a new CSV ------

#View the final modified ID_data dataframe, verify it is complete.
view(ID_data)

#Export ID_data to a CSV, so you can import into other scripts or statitical analyses.
write.csv(ID_data, file.path(destination_filepath,output_CSV_name), row.names=FALSE)
