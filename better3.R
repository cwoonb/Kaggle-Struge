
source(&quot;src/check_packages.R&quot;)
source(&quot;src/get_matches_meta.R&quot;)
check_packages(c(&quot;tidyverse&quot;,&quot;jsonlite&quot;, &quot;lubridate&quot;, &quot;pbapply&quot;, &quot;httr&quot;))
pubg_api_key &lt;-
  &quot;eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI4MzQyN2YzMC05Y2ZmLTAxMzgt
MzlmMS0xYmJkOWE0ZjQyNzEiLCJpc3MiOiJnYW1lbG9ja2VyIiwiaWF0IjoxNTkzNTIxOTkyL
CJwdWIiOiJibHVlaG9sZSIsInRpdGxlIjoicHViZyIsImFwcCI6Imp1bmdod2FuLWFsZnJlIn0.5k
CBiEQehbtYn2zg_SYdel0vnU6m1V4VKN3rRJMk-k8&quot;
####
## 1. 수집 가능한 토너먼트리스트 가져오기 ====
## tournaments 정보를 PUBG 서버에 요청하고, 그값을 json_tournaments_list에 저장합니다.
json_tournaments_list &lt;- &quot;https://api.pubg.com/tournaments&quot; %&gt;%
  httr::GET(add_headers(Authorization = pubg_api_key,
                        Accept = &quot;application/vnd.api+json&quot;)) %&gt;%
  httr::content(&quot;text&quot;, encoding = &quot;UTF-8&quot;) %&gt;%
  fromJSON()
## json_tournaments_list 에서 경기 메타에 관한 정보를 추출하여 tbl_tournaments_list에
저장합니다.
tbl_tournaments_list &lt;- tibble(type = json_tournaments_list$data$type,
                                  id = json_tournaments_list$data$id,
                                  createdAt = json_tournaments_list$data$attributes$createdAt)
####
## 2. 토너먼트에 포함된 경기리스트 가져오기 ====
## 수집하고 싶은 토너먼트 ID 선택하기
tournaments_id &lt;- &quot;kr-bws20&quot;
## 선택한 토너먼트 ID를 기준으로 PUBG 서버에 경기 정보를 요청하고, 그값을
list_tournaments_matches에 저장합니다.
json_tournaments_matches &lt;- str_c(&quot;https://api.pubg.com/tournaments/&quot;, tournaments_id)
%&gt;%
  httr::GET(add_headers(Authorization = pubg_api_key,
                        Accept = &quot;application/vnd.api+json&quot;)) %&gt;%
  httr::content(&quot;text&quot;, encoding = &quot;UTF-8&quot;) %&gt;%
  fromJSON()
## json_tournaments_matches에서 개별 경기 정보를 추출하여 tbl_tournaments_matches
저장합니다.
tbl_tournaments_matches &lt;- tibble(type = json_tournaments_matches$included$type,
                                     matchId = json_tournaments_matches$included$id,
                                     createdAt =
                                       json_tournaments_matches$included$attributes$createdAt)
## 경기 데이터가 생산된 날짜를 오름차순으로 정렬하고, 시간정보의 &quot;:&quot; 값을 &quot;_&quot; 값으로
치환합니다.
tbl_tournaments_matches &lt;- tbl_tournaments_matches %&gt;%
  arrange(createdAt) %&gt;%
  mutate(createdAt = str_replace_all(createdAt, &quot;:&quot;, &quot;_&quot;))
####
## 3. 경기데이터 내 요약 정보 가져오기 ====
## 수집하고 싶은 경기 ID 선택하기
match_id &lt;- tbl_tournaments_matches$matchId[1]
## 선택한 경기 ID를 기준으로 경기정보를 요청하고, 그 값을 json_match_summary에
저장합니다.
json_match_summary &lt;- str_c(&quot;https://api.pubg.com/shards/tournament/matches/&quot;,
                               match_id) %&gt;%
  httr::GET(add_headers(Authorization = pubg_api_key,
                        Accept = &quot;application/vnd.api+json&quot;)) %&gt;%
  httr::content(&quot;text&quot;, encoding = &quot;UTF-8&quot;) %&gt;%
  fromJSON()
json_match_summary_included &lt;- json_match_summary$included
## 참가 선수 / 팀 정보
json_match_roster &lt;- json_match_summary_included %&gt;%
  filter(type == &quot;roster&quot;)
tbl_match_roster &lt;- tibble(roster_type = json_match_roster$type,
                              team_id = json_match_roster$id,
                              rank = json_match_roster$attributes$stats$rank,
                              teamId = json_match_roster$attributes$stats$teamId,
                              roster = json_match_roster$relationships$participants$data) %&gt;%
  unnest(cols = c(roster)) %&gt;%
  select(type, id, rank, teamId)
## 참가 선수 스탯 정보
json_match_summary &lt;- json_match_summary_included %&gt;%
  filter(type == &quot;participant&quot;)
tbl_match_summary &lt;- tibble(&quot;type&quot; = json_match_summary$type,
                               &quot;id&quot; = json_match_summary$id,
                               &quot;stats&quot; = json_match_summary$attributes$stats)
## 참가 선수 스탯 정리
tbl_match_summary_stats &lt;- tibble(&quot;playerId&quot; = tbl_match_summary$id,
                                     &quot;playerName&quot; = tbl_match_summary$stats$name,
                                     &quot;winPlace&quot; = tbl_match_summary$stats$winPlace,
                                     &quot;kills&quot; = tbl_match_summary$stats$kills,
                                     &quot;deathType&quot; = tbl_match_summary$stats$deathType,
                                     &quot;assists&quot; = tbl_match_summary$stats$assists,
                                     &quot;damageDealt&quot; = tbl_match_summary$stats$damageDealt,
                                     &quot;timeSurvived&quot; = tbl_match_summary$stats$timeSurvived,
                                     &quot;longestKill&quot; = tbl_match_summary$stats$longestKill,
                                     &quot;headshotKills&quot; = tbl_match_summary$stats$headshotKills,
                                     &quot;teamKills&quot; = tbl_match_summary$stats$teamKills,
                                     &quot;vehicleDestroys&quot; = tbl_match_summary$stats$vehicleDestroys,
                                     &quot;killStreaks&quot; = tbl_match_summary$stats$killStreaks,
                                     &quot;rideDistance&quot; = tbl_match_summary$stats$rideDistance,
                                     &quot;walkDistance&quot; = tbl_match_summary$stats$walkDistance,
                                     &quot;swimDistance&quot; = tbl_match_summary$stats$swimDistance,
                                     &quot;revives&quot; = tbl_match_summary$stats$revives,
                                     &quot;DBNOs&quot; = tbl_match_summary$stats$DBNOs,
                                     &quot;weaponsAcquired&quot; = tbl_match_summary$stats$weaponsAcquired,
                                     &quot;heals&quot; = tbl_match_summary$stats$heals,
                                     &quot;boosts&quot; = tbl_match_summary$stats$boosts) %&gt;%
  arrange(playerName)
tmp &lt;- tbl_match_summary_stats %&gt;%
  mutate(moveDistance = rideDistance + walkDistance + swimDistance) %&gt;%
  mutate(rideDistance_ratio = (rideDistance / moveDistance) %&gt;%
           round(digits = 2))
telemetry_url &lt;- get_match_telemetry_url(match_id = tbl_tournaments_matches$matchId[1],
                                            api_key = pubg_api_key)
download.file(telemetry_url,
              &quot;json/telemetry.json&quot;)
json_match_telemetry &lt;- fromJSON(telemetry_url)
json_match_telemetry &lt;- fromJSON(&quot;json/telemetry.json&quot;)
# list_match_telemetry &lt;- jsonlite::read_json(&quot;json/telemetry.json&quot;)
# names(list_match_telemetry) &lt;- lapply(list_match_telemetry,
# function(x){x$`_T`})
json_match_telemetry$`_T` %&gt;% unique()
json_match_telemetry$`_T` %&gt;%
  table() %&gt;%
  as_tibble() %&gt;%
  arrange(desc(n)) %&gt;%
  print(n = 50)
## 선수 위치정보 수집하기
telemetry_LogPlayerPosition &lt;- json_match_telemetry[json_match_telemetry$`_T` ==
                                                         &quot;LogPlayerPosition&quot;,]
tbl_player_position &lt;- tibble(&quot;timestamp&quot; = telemetry_LogPlayerPosition$`_D`,
                                 &quot;isGame&quot; = telemetry_LogPlayerPosition$common$isGame,
                                 &quot;player_name&quot; = telemetry_LogPlayerPosition$character$name,
                                 &quot;team_id&quot; = telemetry_LogPlayerPosition$character$teamId,
                                 &quot;player_health&quot; = telemetry_LogPlayerPosition$character$health,
                                 &quot;position_x&quot; = telemetry_LogPlayerPosition$character$location$x,
                                 &quot;position_y&quot; = telemetry_LogPlayerPosition$character$location$y,
                                 &quot;position_z&quot; = telemetry_LogPlayerPosition$character$location$z)
## 선수 사격정보 수집하기
telemetry_player_shooting &lt;- json_match_telemetry[(json_match_telemetry$`_T` ==
                                                        &quot;LogPlayerAttack&quot;),]
tbl_player_shooting &lt;- tibble(&quot;timestamp&quot; = telemetry_player_shooting$`_D`,
                                 &quot;isGame&quot; = telemetry_player_shooting$common$isGame,
                                 &quot;player_name&quot; = telemetry_player_shooting$attacker$name,
                                 &quot;team_id&quot; = telemetry_player_shooting$attacker$teamId,
                                 &quot;player_health&quot; = telemetry_player_shooting$attacker$health,
                                 &quot;weapon&quot; = telemetry_player_shooting$weapon$itemId,
                                 &quot;position_x&quot; = telemetry_player_shooting$attacker$location$x,
                                 &quot;position_y&quot; = telemetry_player_shooting$attacker$location$y,
                                 &quot;position_z&quot; = telemetry_player_shooting$attacker$location$z)
## 선수 데미지 정보 수집하기
telemetry_player_damage &lt;- json_match_telemetry[(json_match_telemetry$`_T` ==
                                                      &quot;LogPlayerTakeDamage&quot;),]
tbl_player_damage &lt;- tibble(&quot;timestamp&quot; = telemetry_player_damage$`_D`,
                               &quot;isGame&quot; = telemetry_player_damage$common$isGame,
                               &quot;attacker_name&quot; = telemetry_player_damage$attacker$name,
                               &quot;attacker_team_id&quot; = telemetry_player_damage$attacker$teamId,
                               &quot;attacker_health&quot; = telemetry_player_damage$attacker$health,
                               &quot;attacker_position_x&quot; = telemetry_player_damage$attacker$location$x,
                               &quot;attacker_position_y&quot; = telemetry_player_damage$attacker$location$y,
                               &quot;attacker_position_z&quot; = telemetry_player_damage$attacker$location$z,
                               &quot;victim_name&quot; = telemetry_player_damage$victim$name,
                               &quot;victim_team_id&quot; = telemetry_player_damage$victim$teamId,
                               &quot;victim_health&quot; = telemetry_player_damage$victim$health,
                               &quot;victim_position_x&quot; = telemetry_player_damage$victim$location$x,
                               &quot;victim_position_y&quot; = telemetry_player_damage$victim$location$y,
                               &quot;victim_position_z&quot; = telemetry_player_damage$victim$location$z,
                               &quot;damage_type&quot; = telemetry_player_damage$damageTypeCategory,
                               &quot;damage_causer_name&quot; =
                                 telemetry_player_damage$damageCauserName,
                               &quot;damage_reason&quot; = telemetry_player_damage$damageReason,
                               &quot;damage&quot; = telemetry_player_damage$damage)
tbl_player_damage_by_gun &lt;- tbl_player_damage %&gt;%
  filter(damage_type == &quot;Damage_Gun&quot;)
## 선수별 데미지 현황
tbl_player_damage_by_gun %&gt;%
  group_by(attacker_name) %&gt;%
  summarise(&quot;make_damage&quot; = n(),
            &quot;total_damage&quot; = sum(damage)) %&gt;%
  mutate(&quot;active_damage&quot; = total_damage/make_damage) %&gt;%
  arrange(desc(active_damage))
tbl_player_damage_by_gun %&gt;%
  group_by(attacker_name, damage_reason) %&gt;%
  summarise(&quot;make_damage&quot; = n(),
            &quot;total_damage&quot; = sum(damage))
tbl_player_attack_by_gun &lt;- tbl_player_shooting %&gt;%
  filter(weapon != &quot;&quot;) %&gt;%
  group_by(player_name) %&gt;%
  summarise(attack_cnt = n())
tbl_player_damage_by_gun_adj &lt;- tbl_player_damage_by_gun %&gt;%
  group_by(attacker_name) %&gt;%
  summarise(&quot;make_damage&quot; = n(),
            &quot;total_damage&quot; = sum(damage)) %&gt;%
  mutate(&quot;active_damage&quot; = total_damage/make_damage) %&gt;%
  arrange(desc(active_damage)) %&gt;%
  select(player_name = attacker_name, make_damage, total_damage, active_damage)
tbl_player_attack_damage &lt;- left_join(tbl_player_attack_by_gun,
                                         tbl_player_damage_by_gun_adj)
tbl_player_attack_damage
