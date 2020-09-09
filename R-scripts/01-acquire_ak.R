# Acquire Answer Key
# Get the answer key data into a dataframe 

# Directory Information 
data_raw <- here::here("data-raw")
data_output <- here::here("data-output")
resources <- here::here("resources")

ifelse(!dir.exists(paste0(data_raw, "/ak_unziped")), 
       dir.create(paste0(data_raw, "/ak_unziped")), 
       message("Dir exists.")
       )

answer_key_path <- paste0(data_raw, "/ATL_Key.docx")
ak_unzipped_path <- paste0(data_raw, "/ak_unziped")
ak_raw_xml_doc_path <- paste0(ak_unzipped_path, "/word/comments.xml")

# Load in necessary packages
library(tidyverse)
library(xml2)


# Path to Answer Key 
unzip(answer_key_path, exdir = ak_unzipped_path)


# Get comments from XML 
ak_raw_xml <- 
  read_xml(ak_raw_xml_doc_path)

# View the xml structure
xml_structure(ak_raw_xml)

ak_raw_xml %>% 
  xml_find_all(".//w:comment")

