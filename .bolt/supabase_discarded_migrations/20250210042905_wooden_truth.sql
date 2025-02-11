-- Update professional locations to top 50 Southern California cities
DO $$
DECLARE
  prof_record RECORD;
  city_record RECORD;
  city_counter INTEGER := 0;
BEGIN
  -- Create temporary table for top 50 SoCal cities
  CREATE TEMPORARY TABLE socal_cities_top50 (
    city_name text,
    state_code text,
    latitude double precision,
    longitude double precision,
    population integer
  );

  -- Insert top 50 most populated SoCal cities with coordinates
  INSERT INTO socal_cities_top50 (city_name, state_code, latitude, longitude, population) VALUES
    ('Los Angeles', 'CA', 34.0522, -118.2437, 3898747),
    ('San Diego', 'CA', 32.7157, -117.1611, 1386932),
    ('Long Beach', 'CA', 33.7701, -118.1937, 466742),
    ('Bakersfield', 'CA', 35.3733, -119.0187, 407615),
    ('Anaheim', 'CA', 33.8366, -117.9143, 346824),
    ('Santa Ana', 'CA', 33.7455, -117.8677, 310227),
    ('Riverside', 'CA', 33.9533, -117.3961, 314998),
    ('Chula Vista', 'CA', 32.6401, -117.0842, 275487),
    ('Irvine', 'CA', 33.6846, -117.8265, 307670),
    ('San Bernardino', 'CA', 34.1083, -117.2898, 222101),
    ('Oxnard', 'CA', 34.1975, -119.1771, 202063),
    ('Fontana', 'CA', 34.0922, -117.4350, 208393),
    ('Moreno Valley', 'CA', 33.9425, -117.2297, 208634),
    ('Huntington Beach', 'CA', 33.6595, -117.9988, 198711),
    ('Santa Clarita', 'CA', 34.3917, -118.5426, 228673),
    ('Garden Grove', 'CA', 33.7739, -117.9414, 171949),
    ('Oceanside', 'CA', 33.1959, -117.3795, 175742),
    ('Rancho Cucamonga', 'CA', 34.1064, -117.5931, 177751),
    ('Ontario', 'CA', 34.0633, -117.6509, 175265),
    ('Lancaster', 'CA', 34.6868, -118.1542, 173516),
    ('Palmdale', 'CA', 34.5794, -118.1165, 169450),
    ('Corona', 'CA', 33.8753, -117.5664, 169868),
    ('Escondido', 'CA', 33.1192, -117.0864, 151038),
    ('Orange', 'CA', 33.7879, -117.8531, 139911),
    ('Torrance', 'CA', 33.8358, -118.3406, 147067),
    ('Fullerton', 'CA', 33.8704, -117.9242, 143617),
    ('El Monte', 'CA', 34.0686, -118.0276, 109450),
    ('Victorville', 'CA', 34.5362, -117.2928, 134810),
    ('Costa Mesa', 'CA', 33.6411, -117.9187, 111918),
    ('Carlsbad', 'CA', 33.1581, -117.3506, 114746),
    ('Temecula', 'CA', 33.4936, -117.1484, 110003),
    ('Murrieta', 'CA', 33.5539, -117.2139, 118125),
    ('Westminster', 'CA', 33.7514, -117.9940, 91137),
    ('Ventura', 'CA', 34.2805, -119.2945, 110763),
    ('Tustin', 'CA', 33.7458, -117.8261, 80276),
    ('Newport Beach', 'CA', 33.6189, -117.9289, 85239),
    ('Mission Viejo', 'CA', 33.6000, -117.6719, 94267),
    ('Indio', 'CA', 33.7206, -116.2156, 89137),
    ('Menifee', 'CA', 33.6971, -117.1850, 102527),
    ('Hemet', 'CA', 33.7475, -116.9719, 89833),
    ('Lake Forest', 'CA', 33.6469, -117.6891, 86346),
    ('Chino', 'CA', 34.0122, -117.6889, 91403),
    ('Whittier', 'CA', 33.9792, -118.0327, 87306),
    ('Redondo Beach', 'CA', 33.8492, -118.3884, 67412),
    ('Laguna Niguel', 'CA', 33.5225, -117.7075, 65316),
    ('San Clemente', 'CA', 33.4269, -117.6120, 64581),
    ('Pico Rivera', 'CA', 33.9830, -118.0967, 62088),
    ('Perris', 'CA', 33.7825, -117.2286, 77879),
    ('Upland', 'CA', 34.0975, -117.6484, 79040),
    ('San Marcos', 'CA', 33.1434, -117.1661, 96664);

  -- Assign one professional to each city
  FOR city_record IN 
    SELECT * FROM socal_cities_top50 
    ORDER BY population DESC 
  LOOP
    -- Exit if we've processed 50 cities
    IF city_counter >= 50 THEN
      EXIT;
    END IF;

    -- Select a professional that hasn't been assigned to a top 50 city yet
    UPDATE professionals
    SET 
      location = city_record.city_name || ', ' || city_record.state_code,
      latitude = city_record.latitude + (random() - 0.5) * 0.01,
      longitude = city_record.longitude + (random() - 0.5) * 0.01,
      updated_at = now()
    WHERE id = (
      SELECT id 
      FROM professionals 
      WHERE NOT EXISTS (
        SELECT 1 
        FROM socal_cities_top50 sc 
        WHERE professionals.location = sc.city_name || ', ' || sc.state_code
      )
      LIMIT 1
    );

    city_counter := city_counter + 1;
  END LOOP;

  -- Log the results
  RAISE NOTICE 'Updated professionals distribution:';
  FOR city_record IN 
    SELECT 
      split_part(location, ',', 1) as city,
      COUNT(*) as prof_count
    FROM professionals 
    GROUP BY split_part(location, ',', 1)
    ORDER BY prof_count DESC
  LOOP
    RAISE NOTICE '% professionals in %', city_record.prof_count, city_record.city;
  END LOOP;

  -- Clean up
  DROP TABLE socal_cities_top50;
END $$;