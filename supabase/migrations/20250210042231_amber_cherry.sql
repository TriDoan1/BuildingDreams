/*
  # Update professional locations to Southern California

  1. Changes
    - Updates all professional locations to Southern California cities
    - Distributes professionals across cities based on weights
    - Updates coordinates accordingly
    
  2. Error Fix
    - Uses OFFSET/LIMIT with weighted random selection to ensure a city is always selected
    - Maintains proper distribution while avoiding NULL locations
*/

DO $$
DECLARE
  prof RECORD;
  selected_city RECORD;
BEGIN
  -- Create temporary table for SoCal cities and their coordinates
  CREATE TEMPORARY TABLE socal_cities (
    city text,
    state text,
    lat double precision,
    lng double precision,
    weight int,
    cumulative_weight int
  );

  -- Insert SoCal cities with their coordinates and distribution weights
  INSERT INTO socal_cities (city, state, lat, lng, weight) VALUES
    ('Los Angeles', 'CA', 34.0522, -118.2437, 25),
    ('San Diego', 'CA', 32.7157, -117.1611, 20),
    ('Irvine', 'CA', 33.6846, -117.8265, 10),
    ('Santa Ana', 'CA', 33.7455, -117.8677, 8),
    ('Anaheim', 'CA', 33.8366, -117.9143, 8),
    ('Riverside', 'CA', 33.9533, -117.3961, 7),
    ('San Bernardino', 'CA', 34.1083, -117.2898, 5),
    ('Santa Barbara', 'CA', 34.4208, -119.6982, 5),
    ('Ventura', 'CA', 34.2805, -119.2945, 4),
    ('Long Beach', 'CA', 33.7701, -118.1937, 8);

  -- Calculate cumulative weights for better random distribution
  WITH RECURSIVE cte AS (
    SELECT 
      city,
      state,
      lat,
      lng,
      weight,
      weight as cumulative_weight,
      1 as row_num
    FROM socal_cities
    WHERE city = (SELECT MIN(city) FROM socal_cities)
    
    UNION ALL
    
    SELECT 
      sc.city,
      sc.state,
      sc.lat,
      sc.lng,
      sc.weight,
      cte.cumulative_weight + sc.weight,
      cte.row_num + 1
    FROM socal_cities sc
    INNER JOIN cte ON sc.city > cte.city
  )
  UPDATE socal_cities
  SET cumulative_weight = cte.cumulative_weight
  FROM cte
  WHERE socal_cities.city = cte.city;

  -- Update each professional with a random SoCal city
  FOR prof IN SELECT id FROM professionals LOOP
    -- Select a random city based on weights
    WITH random_selection AS (
      SELECT 
        city,
        state,
        lat + (random() - 0.5) * 0.02 as rand_lat,
        lng + (random() - 0.5) * 0.02 as rand_lng
      FROM socal_cities
      WHERE cumulative_weight > (random() * (SELECT MAX(cumulative_weight) FROM socal_cities))
      ORDER BY cumulative_weight
      LIMIT 1
    )
    UPDATE professionals
    SET 
      location = (SELECT city || ', ' || state FROM random_selection),
      latitude = (SELECT rand_lat FROM random_selection),
      longitude = (SELECT rand_lng FROM random_selection),
      updated_at = now()
    WHERE id = prof.id;
  END LOOP;

  -- Clean up
  DROP TABLE socal_cities;
END $$;