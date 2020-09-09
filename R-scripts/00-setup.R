# Set-up 

# Create directories 
data_raw <- here::here("data-raw")
data_output <- here::here("data-output")
resources <- here::here("resources")

dir_list <- list(data_raw, data_output, resources)

purrr::walk(dir_list, 
            ~ ifelse(!dir.exists(.x), 
                     dir.create(.x), 
                     message(paste0(.x, "exists"))
                     )
            )

message("Folder directories created.")
###