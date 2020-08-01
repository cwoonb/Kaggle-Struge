knit_with_parameters('~/Github/esports-analysis-class/esports-analysis-02/chapter2.Rmd')
## ===
## Author : junghwan.alfred.yun@gmail.com
## ===
check_packages <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  result <- sapply(pkg, require, character.only = TRUE)
  return(result)
}
options(scipen = 999)
get_tournament_list <- function(api_key){
  apiHost <- "https://api.pubg.com"
  tournament_list <- file.path(apiHost, "tournaments") %>%
    httr::GET(httr::add_headers(Authorization = api_key,
                                Accept= "application/vnd.api+json")) %>%
    httr::content("text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
  tbl_tournament_list <- tibble(type = tournament_list$data$type,
                                id = tournament_list$data$id,
                                createdAt = tournament_list$data$attributes$createdAt)
  return(tbl_tournament_list)
}
source("src/check_packages.R")
source("src/get_matches_metadata.R")
source("src/check_packages.R")
source("src/get_matches_meta.R")
installed_packages <- check_packages(c("tidyverse","jsonlite", "lubridate", "pbapply", "httr"))
pubg_api_key <- "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiIyOGUwMWZiMC01MzlkLTAxMzctNmNlNy03OWM0NDRhODJhNTkiLCJpc3MiOiJnYW1lbG9ja2VyIiwiaWF0IjoxNTU3MzA1ODE3LCJwdWIiOiJibHVlaG9sZSIsInRpdGxlIjoicHViZyIsImFwcCI6Ii1hNjZiZjMzYS1iMzRmLTQxNjUtODc4ZC1kNjBlY2IwMmU1MTIifQ.n0ytPS69DjcV3BaobZbERu7-oALk4aVcqtDBBoWejMU"
pubg_api_key <- "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiIyOGUwMWZiMC01MzlkLTAxMzctNmNlNy03OWM0NDRhODJhNTkiLCJpc3MiOiJnYW1lbG9ja2VyIiwiaWF0IjoxNTU3MzA1ODE3LCJwdWIiOiJibHVlaG9sZSIsInRpdGxlIjoicHViZyIsImFwcCI6Ii1hNjZiZjMzYS1iMzRmLTQxNjUtODc4ZC1kNjBlY2IwMmU1MTIifQ.n0ytPS69DjcV3BaobZbERu7-oALk4aVcqtDBBoWejMU"
tbl_tournament <- get_tournament_list(authorKey = pubg_api_key)
tbl_tournament <- get_tournament_list(api_key = pubg_api_key)
tbl_tournament
tbl_tournament %>%
  print(n = 100)
tbl_tournament_matches <- get_matches_id_from_tournament(tournaments_id = "kr-pgskr",
                                                         api_key = pubg_api_key)
tbl_tournament_matches
tbl_matches_summary_stats <- get_match_summary_stats(match_id = tbl_tournament_matches$matchId[1],
                                                     api_key = pubg_api_key)
## ===
## Author : junghwan.alfred.yun@gmail.com
## ===
get_tournament_list <- function(api_key){
  apiHost <- "https://api.pubg.com"
  tournament_list <- file.path(apiHost, "tournaments") %>%
    httr::GET(httr::add_headers(Authorization = api_key,
                                Accept= "application/vnd.api+json")) %>%
    httr::content("text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
  tbl_tournament_list <- tibble(type = tournament_list$data$type,
                                id = tournament_list$data$id,
                                createdAt = tournament_list$data$attributes$createdAt)
  return(tbl_tournament_list)
}
get_matches_id_from_tournament <- function(tournaments_id, api_key){
  list_matches <- file.path("https://api.pubg.com", "tournaments", tournaments_id) %>%
    httr::GET(httr::add_headers(Authorization= api_key,
                                Accept= "application/vnd.api+json")) %>%
    httr::content("text",  encoding = "UTF-8") %>%
    jsonlite::fromJSON()
  tbl_matches <- tibble("type" = list_matches$included$type,
                        "matchId" = list_matches$included$id,
                        "matchTime" = list_matches$included$attributes$createdAt) %>%
    arrange(matchTime) %>%
    mutate(matchTime = str_replace_all(matchTime,":","_"))
  return(tbl_matches)
}
get_match_summary_stats <- function(match_id, api_key){
  json_match_summary <- file.path("https://api.pubg.com", "shards/tournament/matches", list_matchId[i]) %>%
    httr::GET(httr::add_headers(Authorization= authorKey, Accept= "application/vnd.api+json")) %>%
    httr::content("text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
}
tbl_matches_summary_stats <- get_match_summary_stats(match_id = tbl_tournament_matches$matchId[1],
                                                     api_key = pubg_api_key)
get_match_summary_stats <- function(match_id, api_key){
  json_match_summary <- file.path("https://api.pubg.com", "shards/pc-tournament/matches", match_id) %>%
    httr::GET(httr::add_headers(Authorization= authorKey, Accept= "application/vnd.api+json")) %>%
    httr::content("text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
}
tbl_matches_summary_stats <- get_match_summary_stats(match_id = tbl_tournament_matches$matchId[1],
                                                     api_key = pubg_api_key)
get_match_summary_stats <- function(match_id, api_key){
  json_match_summary <- file.path("https://api.pubg.com", "shards/pc-tournament/matches", match_id) %>%
    httr::GET(httr::add_headers(Authorization= api_key, Accept= "application/vnd.api+json")) %>%
    httr::content("text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
}
tbl_matches_summary_stats <- get_match_summary_stats(match_id = tbl_tournament_matches$matchId[1],
                                                     api_key = pubg_api_key)
tbl_matches_summary_stats
tbl_match_summary <- json_match_summary$included$attributes$stats %>%
  as_tibble() %>%
  filter(name != "NA")
match_id = tbl_tournament_matches$matchId[1]
api_key = pubg_api_key
json_match_summary <- file.path("https://api.pubg.com", "shards/pc-tournament/matches", match_id) %>%
  httr::GET(httr::add_headers(Authorization= api_key, Accept= "application/vnd.api+json")) %>%
  httr::content("text", encoding = "UTF-8") %>%
  jsonlite::fromJSON()
tbl_match_summary <- json_match_summary$included$attributes$stats %>%
  as_tibble() %>%
  filter(name != "NA")
tbl_match_summary
json_match_summary <- file.path("https://api.pubg.com", "shards/pc-tournament/matches", match_id) %>%
  httr::GET(httr::add_headers(Authorization= api_key, Accept= "application/vnd.api+json")) %>%
  httr::content("text", encoding = "UTF-8") %>%
  jsonlite::fromJSON()
get_match_summary_stats <- function(match_id, api_key){
  json_match_summary <- file.path("https://api.pubg.com", "shards/pc-tournament/matches", match_id) %>%
    httr::GET(httr::add_headers(Authorization= api_key, Accept= "application/vnd.api+json")) %>%
    httr::content("text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
  tbl_match_summary <- json_match_summary$included$attributes$stats %>%
    as_tibble() %>%
    filter(name != "NA")
  return(tbl_match_summary)
}
json_match_summary$included$attributes$URL
json_match_summary$included$attributes$URL %>% na.omit()
telemetry <- json_match_summary$included$attributes$URL
is.na(telemetry)
telemetry[is.na(telemetry)]
telemetry_path <- telemetry[!is.na(telemetry)]
telemetry_path
source("src/check_packages.R")
source("src/get_matches_meta.R")
tbl_matches_telemetry <- get_match_telemetry_url(match_id = tbl_tournament_matches$matchId[1],
                                                 api_key = pubg_api_key)
tbl_matches_telemetry
tbl_matches_telemetry <- get_match_telemetry_url(match_id = tbl_tournament_matches$matchId[1],
                                                 api_key = pubg_api_key) %>%
  fromJSON()
tbl_matches_summary_stats
tbl_tournament_matches
tbl_tournament_matches_old <- tbl_tournament_matches %>%
  head()
tbl_tournament_matches %>%
  filter(matchID %in% tbl_tournament_matches_old$matchId)
tbl_tournament_matches <- get_matches_id_from_tournament(tournaments_id = "kr-pgskr",
                                                         api_key = pubg_api_key)
tbl_tournament_matches_old <- tbl_tournament_matches %>%
  head()
tbl_tournament_matches
tbl_tournament_matches %>%
  filter(matchId %in% tbl_tournament_matches_old$matchId)
tbl_tournament_matches %>%
  filter(!matchId %in% tbl_tournament_matches_old$matchId)