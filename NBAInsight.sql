SELECT *
FROM common_player_info;

-- Count all the players
SELECT COUNT(*) AS total_players
FROM common_player_info;

-- Count the number of players for each level of season experience.
SELECT season_exp, COUNT(*) as season_exp_count
FROM common_player_info
GROUP By season_exp
ORDER BY season_exp DESC;

-- Ranks jersey numbers by their frequency of use among players, excluding empty or null values.
SELECT jersey, COUNT(*) AS usage_count
FROM common_player_info
WHERE jersey != '' AND jersey IS NOT NULL
GROUP BY jersey
ORDER BY usage_count DESC, jersey ASC;

-- Count the number of players from each team who are flagged as part of the "Greatest 75", sorted by the count in descending order and then by team name.
SELECT 
    cpi.team_name,
    CONCAT(td.city) AS team_city,
    COUNT(*) AS player_count
FROM 
    common_player_info cpi
JOIN 
    team_details td ON cpi.team_name = td.nickname
WHERE 
    cpi.greatest_75_flag = 'Y'
GROUP BY 
    cpi.team_name, td.city, td.nickname
ORDER BY 
    player_count DESC, cpi.team_name ASC;

-- Count the number of players from each school
SELECT school, COUNT(*) AS school_count
FROM common_player_info
GROUP BY school
ORDER BY school_count DESC;

-- Count the number of players for each position
SELECT position, COUNT(*) AS position_count
FROM common_player_info
WHERE position != '' AND position IS NOT NULL
GROUP BY position
ORDER BY position_count DESC;

-- Calculate the avg height in inches for each position
Create view avg_height_by_position as
WITH height_converted AS (
  SELECT 
    position,
    (CAST(SUBSTRING_INDEX(height, '-', 1) AS SIGNED) * 12) + 
    CAST(SUBSTRING_INDEX(height, '-', -1) AS SIGNED) AS height_inches
  FROM common_player_info
)
SELECT 
  position,
  ROUND(AVG(height_inches), 2) AS avg_height_inches
FROM height_converted
GROUP BY position
ORDER BY avg_height_inches DESC;

-- Calculate the count and percentage of home game outcomes (wins/losses)
WITH game_counts AS (
  SELECT wl_home, COUNT(*) AS home_count
  FROM game
  GROUP BY wl_home
),
total_games AS (
  SELECT SUM(home_count) AS total
  FROM game_counts
)
SELECT 
  gc.wl_home, 
  gc.home_count,
  ROUND((gc.home_count * 100.0 / tg.total), 2) AS percentage
FROM 
  game_counts gc
CROSS JOIN 
  total_games tg
ORDER BY 
  gc.home_count DESC;

-- Find which game has the most attendance
WITH max_attendance_game AS (
    SELECT game_id, CAST(attendance AS SIGNED) AS attendance
    FROM game_info
    WHERE CAST(attendance AS SIGNED) = (
        SELECT MAX(CAST(attendance AS SIGNED)) 
        FROM game_info
    )
    LIMIT 1
)
SELECT g.game_date, g.matchup_home, g.min, g.pts_home, g.pts_away, mag.attendance
FROM game g
JOIN max_attendance_game mag ON g.game_id = mag.game_id;