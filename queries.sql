CREATE DATABASE video_game;

USE video_game;

CREATE TABLE IF NOT EXISTS games (
Title VARCHAR(240),
Release_Date DATE,
Team VARCHAR(240),
Rating DECIMAL(4,2),
Time_Listed INT,
Number_of_Reviews INT,
Genres VARCHAR(240),
Plays INT,
Playing INT,
Backlogs INT,
Wishlist INT
);


CREATE TABLE IF NOT EXISTS vgsales (
Name VARCHAR(240),
Plateform VARCHAR(240),
Year VARCHAR(20),
Genre VARCHAR(240),
Publisher VARCHAR(240),
NA_Sales FLOAT,
EU_Sales FLOAT,
JP_Sales FLOAT,
Other_Sales FLOAT,
Global_Sales FLOAT
);

SET GLOBAL local_infile = 1;


LOAD DATA LOCAL INFILE 'C:\\Users\\Rohit Gupta\\Desktop\\video game analysis\\games_cleaned.csv'
INTO TABLE games
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Title, Release_Date, Team, Rating, Time_Listed, Number_of_Reviews, Genres, Plays, Playing, Backlogs, Wishlist);


LOAD DATA LOCAL INFILE 'C:\\Users\\Rohit Gupta\\Desktop\\video game analysis\\vgsales_cleaned.csv'
INTO TABLE vgsales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Name, Plateform, Year, Genre, Publisher, NA_Sales, EU_Sales, JP_Sales, Other_Sales, Global_Sales);

-- Creating the final table for powerbi Analysis
CREATE TABLE video_game_final AS
SELECT
	g.Title AS Title,
	v.`Name` AS Game_Name,
	g.Release_Date AS Release_Date,
	v.Plateform AS Plateform,
	v.Publisher AS Publisher,
	CASE 
        -- Check if the Teams column CONTAINS the Publisher value
        WHEN g.Team LIKE CONCAT('%', v.Publisher, '%') THEN
            -- Check which side of the comma the Publisher is on
            CASE
                -- If the Publisher is the FIRST part (before the comma)
                WHEN TRIM(SUBSTRING_INDEX(g.Team, ',', 1)) = v.Publisher THEN
                    -- Select the SECOND part (the Developer Team)
                    TRIM(SUBSTRING_INDEX(g.Team, ',', -1))
                
                -- If the Publisher is the SECOND part (after the comma)
                WHEN TRIM(SUBSTRING_INDEX(g.Team, ',', -1)) = v.Publisher THEN
                    -- Select the FIRST part (the Developer Team)
                    TRIM(SUBSTRING_INDEX(g.Team, ',', 1))
                
                -- If the Publisher is NOT found, or there's no comma, assume the whole field is the Developer Team
                ELSE 
                    g.Team
            END
        -- If there's no match with Publisher, assume the whole field is the Developer Team
        ELSE
            g.Team
    END AS Developer_Team,
	g.Team AS Team,
	g.Rating AS Rating,
	g.Time_Listed AS Times_Listed,
	g.Number_of_Reviews AS Number_of_Reviews,
	g.Genres AS Genres,
	v.Genre AS Genre,
	g.Plays AS Plays,
	g.Playing AS Playing,
	g.Backlogs AS Backlogs,
	g.Wishlist AS Wishlist,
	YEAR(g.Release_Date) AS Year,
	v.NA_Sales AS NA_Sales,
	v.EU_Sales AS EU_Sales,
	v.JP_Sales AS JP_Sales,
	v.Other_Sales AS Other_Sales,
	v.Global_Sales AS Global_Sales
FROM games AS g
INNER JOIN vgsales AS v ON g.Title = v.`Name`;

-- viewing the final dataset -- 
SELECT * FROM video_game_final;