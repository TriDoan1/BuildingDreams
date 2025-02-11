-- Ensure minimum distribution and weighted random assignment for remaining professionals
DO $$
DECLARE
  prof_record RECORD;
  city_record RECORD;
  professionals_count INTEGER;
  remaining_professionals INTEGER;
BEGIN
  -- Create temporary table for SoCal cities and their coordinates
  CREATE TEMPORARY TABLE socal_cities (
    city_name text,
    state_code text,
    latitude double precision,
    longitude double precision,
    weight int,
    cumulative_weight int DEFAULT 0,
    assigned_count int DEFAULT 0
  );

  -- Insert SoCal cities with their coordinates and distribution weights
  INSERT INTO socal_cities (city_name, state_code, latitude, longitude, weight) VALUES
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

  -- Calculate cumulative weights
  UPDATE socal_cities sc1
  SET cumulative_weight = (
    SELECT SUM(sc2.weight)
    FROM socal_cities sc2
    WHERE sc2.city_name <= sc1.city_name
  );

  -- Get total number of professionals
  SELECT COUNT(*) INTO professionals_count FROM professionals;
  
  -- First, ensure at least one professional per city
  FOR city_record IN SELECT * FROM socal_cities LOOP
    -- Select a random professional that hasn't been assigned yet
    UPDATE professionals
    SET 
      location = city_record.city_name || ', ' || city_record.state_code,
      latitude = city_record.latitude + (random() - 0.5) * 0.02,
      longitude = city_record.longitude + (random() - 0.5) * 0.02,
      updated_at = now()
    WHERE id = (
      SELECT id 
      FROM professionals 
      WHERE location NOT LIKE ANY (ARRAY[
        'Santa Barbara, CA',
        'Ventura, CA',
        'San Bernardino, CA',
        'Riverside, CA',
        'Anaheim, CA',
        'Santa Ana, CA',
        'Irvine, CA',
        'Long Beach, CA',
        'San Diego, CA',
        'Los Angeles, CA'
      ])
      LIMIT 1
    );

    -- Update assigned count
    UPDATE socal_cities
    SET assigned_count = assigned_count + 1
    WHERE city_name = city_record.city_name;
  END LOOP;

  -- Distribute remaining professionals based on weights
  FOR prof_record IN 
    SELECT id 
    FROM professionals 
    WHERE location NOT LIKE ANY (ARRAY[
      'Santa Barbara, CA',
      'Ventura, CA',
      'San Bernardino, CA',
      'Riverside, CA',
      'Anaheim, CA',
      'Santa Ana, CA',
      'Irvine, CA',
      'Long Beach, CA',
      'San Diego, CA',
      'Los Angeles, CA'
    ])
  LOOP
    -- Select a random city based on weights
    UPDATE professionals
    SET 
      location = (
        SELECT city_name || ', ' || state_code
        FROM socal_cities
        WHERE cumulative_weight > (random() * (SELECT MAX(cumulative_weight) FROM socal_cities))
        ORDER BY cumulative_weight
        LIMIT 1
      ),
      latitude = (
        SELECT latitude + (random() - 0.5) * 0.02
        FROM socal_cities
        WHERE cumulative_weight > (random() * (SELECT MAX(cumulative_weight) FROM socal_cities))
        ORDER BY cumulative_weight
        LIMIT 1
      ),
      longitude = (
        SELECT longitude + (random() - 0.5) * 0.02
        FROM socal_cities
        WHERE cumulative_weight > (random() * (SELECT MAX(cumulative_weight) FROM socal_cities))
        ORDER BY cumulative_weight
        LIMIT 1
      ),
      updated_at = now()
    WHERE id = prof_record.id;

    -- Update assigned count for the selected city
    UPDATE socal_cities
    SET assigned_count = assigned_count + 1
    WHERE city_name = (
      SELECT city_name
      FROM socal_cities
      WHERE cumulative_weight > (random() * (SELECT MAX(cumulative_weight) FROM socal_cities))
      ORDER BY cumulative_weight
      LIMIT 1
    );
  END LOOP;

  -- Log the distribution
  RAISE NOTICE 'Professional distribution across cities:';
  FOR city_record IN 
    SELECT city_name, state_code, assigned_count 
    FROM socal_cities 
    ORDER BY assigned_count DESC
  LOOP
    RAISE NOTICE '% %: % professionals', 
      city_record.city_name, 
      city_record.state_code, 
      city_record.assigned_count;
  END LOOP;

  -- Clean up
  DROP TABLE socal_cities;
END $$;