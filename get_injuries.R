# get_injuries.R (Robust Version)
# Handles missing 'team' columns by checking multiple locations.

if (!require("jsonlite")) install.packages("jsonlite")
library(jsonlite)
library(dplyr)
library(readr)

print("Fetching Injury Data directly from MLB API...")

# 1. Fetch Data
url <- "https://statsapi.mlb.com/api/v1/transactions?sportId=1&startDate=2023-01-01&endDate=2023-10-01"
data <- fromJSON(url)
transactions <- data$transactions

print("Data downloaded. Cleaning up...")

# 2. Extract Team Name Safely
# The API sometimes stores the team in 'toTeam', 'fromTeam', or 'team'.
# We check which one exists.

if ("toTeam" %in% names(transactions)) {
  # Usually 'toTeam' works for transactions
  transactions$final_team <- transactions$toTeam$name
} else if ("team" %in% names(transactions)) {
  transactions$final_team <- transactions$team$name
} else {
  # Fallback
  transactions$final_team <- "MLB Team" 
}

# 3. Clean and Save
injuries_data <- transactions %>%
  filter(grepl("Injured List", description)) %>% # Keep only IL moves
  mutate(
    date = as.Date(date),
    player = person$fullName,
    team = final_team # Use the safely extracted column
  ) %>%
  select(date, player, team, description) %>%
  as_tibble()

write_rds(injuries_data, "data/injuries_data.rds")
print("Injury Data Saved! You are ready to build the website.")