# get_data.R - OFFICIAL VERSION
# Using baseballr v1.6.0+

# 1. Load the packages (CRITICAL STEP)
library(baseballr)
library(dplyr)
library(readr)

# 2. Create data directory
if (!dir.exists("data")) {
  dir.create("data")
}

print("Step 1: Downloading Velocity Data (Takes 1-2 mins)...")

# Get 2022 Data (Pre-Clock)
df_2022 <- statcast_search(start_date = "2022-04-01", 
                           end_date = "2022-04-07", 
                           player_type = "pitcher") %>%
  mutate(era = "Pre-Clock (2022)")

# Get 2023 Data (Post-Clock)
df_2023 <- statcast_search(start_date = "2023-04-01", 
                           end_date = "2023-04-07", 
                           player_type = "pitcher") %>%
  mutate(era = "Post-Clock (2023)")

# Combine and Clean
velocity_data <- bind_rows(df_2022, df_2023) %>%
  select(player_name, pitch_type, release_speed, era) %>%
  filter(pitch_type == "FF", !is.na(release_speed))

write_rds(velocity_data, "data/velocity_data.rds")
print("Velocity Data Saved!")

# ---

print("Step 2: Downloading Injury Data...")

# Fetch 2023 transactions using the function you now have!
injuries_data <- mlb_transactions(start_date = "2023-01-01", end_date = "2023-10-01") %>%
  filter(grepl("Injured List", description)) %>%
  select(date, player, team, description)

write_rds(injuries_data, "data/injuries_data.rds")
print("Injury Data Saved!")