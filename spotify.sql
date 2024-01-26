/*create spotify table*/
CREATE TABLE spotify (
	track_id SERIAL PRIMARY KEY,
	track_name VARCHAR(125),
	artists_name VARCHAR(135),
	artist_count INT,
	released_year INT,
	released_month INT,
	released_day INT,
	in_spotify_playlists INT,
	in_spotify_charts INT,
	streams INT,
	in_apple_playlists INT,
	in_apple_charts INT,
	in_deezer_playlists INT,
	in_deezer_charts INT,
	in_shazam_charts INT,
	bpm INT,
	key VARCHAR(2),
	mode VARCHAR(5),
	danceability INT,
	valence INT,
	energy INT,
	acousticness INT,
	instrumentalness INT,
	liveness INT,
	speechiness INT,
	cover_url VARCHAR (64)
);

/*create spotify table
COPY spotify FROM '/Users/preciousime/Desktop/spotify.csv' WITH CSV HEADER;*/

/*change the streams datatype*/
ALTER TABLE spotify
ALTER COLUMN streams TYPE BIGINT;

SELECT * FROM spotify;

/*rank most streamed songs track on spotify*/
SELECT * FROM
	(SELECT track_name, artists_name, released_year, streams,
	in_spotify_charts + in_apple_charts + in_deezer_charts + in_shazam_charts AS in_charts,
	DENSE_RANK() OVER(ORDER BY streams DESC) AS song_rank
	FROM spotify) top_streams
WHERE song_rank <= 10
ORDER BY streams DESC;

/*songs in the most number of charts*/
SELECT track_name, artists_name, released_year, streams,
	in_spotify_charts + in_apple_charts + in_deezer_charts + in_shazam_charts AS in_charts,
	DENSE_RANK() OVER(ORDER BY streams DESC)
	FROM spotify
WHERE (in_spotify_charts + in_apple_charts + in_deezer_charts + in_shazam_charts) IS NOT NULL
ORDER BY in_charts DESC
LIMIT 10;

/*Top 10 songs with the highest energy-liveness ratio, a popular measure of song quality*/
SELECT track_name, streams, CAST((energy/liveness) AS NUMERIC(2,0)) AS energy_liveness FROM spotify
ORDER BY energy_liveness DESC
LIMIT 10;

/*top 10 prominent artists on spotify (highest number of streams)*/
SELECT artists_name, 
	SUM(streams) AS artists_streams, 
	CAST(100 * SUM(streams)/(SELECT SUM(streams) FROM spotify)AS INT) AS percent_streams, 
	COUNT(artists_name) AS no_of_tracks ,
	CAST(100 * COUNT(artists_name)/(SELECT COUNT(track_id) FROM spotify)AS NUMERIC(2,1)) AS percent_tracks
FROM spotify
GROUP BY artists_name
ORDER BY artists_streams DESC, no_of_tracks DESC
LIMIT 10;

/*list all tracks by the top artist (highest number of streams)*/
SELECT * FROM spotify
WHERE artists_name = (SELECT artists_name FROM spotify
					   GROUP BY artists_name
					   ORDER BY SUM(streams) DESC
					   LIMIT 1);

/*number of songs and streams per year for years with greater than or equal to 10 tracks*/
SELECT released_year, 
	COUNT(track_name) AS no_of_tracks, 
	CAST(SUM(streams)/1000000000 AS NUMERIC(4,1))||'M' AS no_of_streams,
	CAST(AVG(bpm) AS INT) AS avg_bpm,
	CAST(AVG(danceability) AS INT) AS avg_danceability,
	CAST(AVG(valence) AS INT) AS avg_valence,
	CAST(AVG(energy) AS INT) AS avg_energy,
	CAST(AVG(acousticness) AS INT) AS avg_acousticness,
	CAST(AVG(instrumentalness) AS INT) AS avg_instrumentalness,
	CAST(AVG(liveness) AS INT) AS avg_liveness,
	CAST(AVG(speechiness) AS INT) AS avg_speechiness
FROM spotify
GROUP BY released_year
HAVING COUNT(track_name)>= 10
ORDER BY released_year;

/*what types of songs are released during different seasons*/
SELECT
	CASE
		WHEN released_month IN ('12','1','2') THEN 'Winter'
		WHEN released_month IN ('3','4','5') THEN 'Spring'
		WHEN released_month IN ('6','7','8') THEN 'Summer'
		WHEN released_month IN ('9','10','11') THEN 'Fall'
	END AS released_season, COUNT(*) AS tracks_per_season,
	CAST(SUM(streams)/1000000000 AS NUMERIC(4,1))||'M' AS no_of_streams,
	CAST(AVG(bpm) AS INT) AS avg_bpm,
	CAST(AVG(danceability) AS INT) AS avg_danceability,
	CAST(AVG(valence) AS INT) AS avg_valence,
	CAST(AVG(energy) AS INT) AS avg_energy,
	CAST(AVG(acousticness) AS INT) AS avg_acousticness,
	CAST(AVG(instrumentalness) AS INT) AS avg_instrumentalness,
	CAST(AVG(liveness) AS INT) AS avg_liveness,
	CAST(AVG(speechiness) AS INT) AS avg_speechiness
FROM spotify
GROUP BY released_season;

/*what makes a song to be streamed*/
SELECT track_name, artists_name, released_year, streams,
	bpm, danceability, valence, energy, acousticness, liveness, speechiness
FROM spotify
ORDER BY streams DESC
LIMIT 10;
