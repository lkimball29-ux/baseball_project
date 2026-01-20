library(baseballr)
library(dplyr)
library(readr)

# --- CONFIGURATION ---
# We define the monthly chunks to avoid crashing the server
dates_2022 <- list(
  c("2022-04-07", "2022-05-01"),
  c("2022-05-02", "2022-06-01"),
  c("2022-06-02", "2022-07-01"),
  c("2022-07-02", "2022-08-01"),
  c("2022-08-02", "2022-09-01"),
  c("2022-09-02", "2022-10-05")
)

dates_2023 <- list(
  c("2023-03-30", "2023-05-01"),
  c("2023-05-02", "2023-06-01"),
  c("2023-06-02", "2023-07-01"),
  c("2023-07-02", "2023-08-01"),
  c("2023-08-02", "2023-09-01"),
  c("2023-09-02", "2023-10-01")
)

# --- HELPER FUNCTION ---
download_chunk <- function(date_range, label) {
  print(paste("Downloading", label, "data from", date_range[1], "to", date_range[2], "..."))
  
  tryCatch({
    df <- statcast_search(start_date = date_range[1], 
                          end_date = date_range[2], 
                          player_type = "pitcher")
    
    # IMMEDIATE FILTERING (Crucial to save memory!)
    df_clean <- df %>%
      filter(pitch_type == "FF") %>% # Fastballs only
      select(player_name, game_date, pitch_type, release_speed) %>%
      mutate(era = label)
    
    return(df_clean)
  }, error = function(e) {
    print(paste("Error downloading chunk:", date_range[1]))
    return(NULL) # Skip if error
  })
}

# --- EXECUTION ---

# 1. Download 2022
data_22_list <- lapply(dates_2022, download_chunk, label = "Pre-Clock (2022)")
full_22 <- bind_rows(data_22_list)

# 2. Download 2023
data_23_list <- lapply(dates_2023, download_chunk, label = "Post-Clock (2023)")
full_23 <- bind_rows(data_23_list)

# 3. Combine
print("Combining Data...")
final_dataset <- bind_rows(full_22, full_23)

# 4. Save
print(paste("Saving", nrow(final_dataset), "pitches to file..."))
write_rds(final_dataset, "data/velocity_data.rds")
print("DONE! You now have full season data.")