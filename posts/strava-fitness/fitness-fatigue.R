library(rStrava)

stoken <- httr::config(token = strava_oauth(
  Sys.getenv("STRAVA_APP_NAME"),
  Sys.getenv("STRAVA_CLIENT_ID"), 
  Sys.getenv("STRAVA_CLIENT_SECRET"), 
  app_scope="activity:read_all"
))

user_id <- Sys.getenv("STRAVA_USER_ID")



