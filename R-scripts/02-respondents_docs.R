# Iterate through the response files to create an excel doc of respondent 
# changes 
# 
# Erick Cohen 
# 2020-09-08

rm(list = ls()) # Start with a clean global environment

# Directory Information 
data_raw <- here::here("data-raw")
data_output <- here::here("data-output")
resources <- here::here("resources")

respondents_docs_path <- paste(data_raw, "word_docs", sep = "/")
respondents_unzipped_path <- paste(data_raw, "unzipped", sep = "/")

# list the respondent files 
respondents_docs_list <- 
  list.files(respondents_docs_path, full.names = TRUE)

respondent_file_list <- 
  list.files(respondents_docs_path) %>% 
  str_remove_all("ATL Assignment - ") %>% 
  str_remove_all(".docx") %>% 
  str_trim()

# load in necessary packages
library(tidyverse)
library(xml2)

# respondents_docs_list[1] %>% 
#   unzip(exdir = respondents_unzipped_path)

compile_dataframes <- function(file_num) {
  
  respondents_docs_list[file_num] %>% 
    unzip(exdir = respondents_unzipped_path)
  
  raw_xml_file <-   
    read_xml(paste(
      respondents_unzipped_path,
      "word", 
      "document.xml", 
      sep = "/"
    ))
  
  res_inserts <- 
    raw_xml_file %>% 
    xml_find_all("//w:ins")
  
  
  res_deletions <- 
    raw_xml_file %>% 
    xml_find_all(".//w:del") 
  
  change_id <- 
    res_inserts %>% 
    xml_attr("id")
  
  # author <- 
  #   res_inserts %>% 
  #   xml_attr("author")
  
  change <- 
    res_inserts %>% 
    xml_text() %>% 
    str_trim() %>% 
    as.vector()
  
  inserts_df <- 
    data.frame(change_id, change) %>% 
    add_column(change_type = "insert") %>% 
    add_column(author = respondent_file_list[file_num])
  
  # Now deletions 
  change_id <- 
    res_deletions %>% 
    xml_attr("id")
  
  # author <- 
  #   res_deletions %>% 
  #   xml_attr("author")
  
  change <- 
    res_deletions %>% 
    xml_text() %>% 
    str_trim() %>% 
    as.vector()
  
  deletions_df <- 
    data.frame(change_id, change) %>% 
    add_column(change_type = "deletion")  %>% 
    add_column(author = respondent_file_list[file_num])
  
  # bindrows 
  changes_df <- 
    bind_rows(inserts_df, deletions_df) %>% 
    mutate(change_id = as.numeric(change_id)) %>% 
    arrange((change_id))
  
  message(file_num)
  
  return(changes_df)
  
}

respondents_len <- 1:length(respondents_docs_list)

journal_df <- map_dfr(respondents_len, compile_dataframes)

write_csv(journal_df, path = paste(data_output, "journal_df.csv", sep = "/"))

message(
  paste0("All done! Please find your file in this directory: \n", data_output)
  )
###