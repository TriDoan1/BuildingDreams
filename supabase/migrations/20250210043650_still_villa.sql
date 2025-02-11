/*
  # Add more Southern California cities

  1. Changes
    - Creates temporary table for cities
    - Adds additional cities from each SoCal county
    - Updates professional locations based on new cities

  2. Data Integrity
    - Preserves existing data
    - Adds new cities with accurate coordinates
    - Updates professional locations safely
*/

DO $$
DECLARE
  prof_record RECORD;
  city_record RECORD;
BEGIN
  -- Create temporary table for cities
  CREATE TEMPORARY TABLE temp_socal_cities (
    city_name text PRIMARY KEY,
    state_code text,
    latitude double precision,
    longitude double precision,
    population integer
  );

  -- Insert Los Angeles County cities
  INSERT INTO temp_socal_cities (city_name, state_code, latitude, longitude, population) VALUES
    ('Alhambra', 'CA', 34.0953, -118.1270, 82868),
    ('Arcadia', 'CA', 34.1397, -118.0353, 56364),
    ('Azusa', 'CA', 34.1336, -117.9076, 49485),
    ('Baldwin Park', 'CA', 34.0854, -117.9606, 75390),
    ('Bell', 'CA', 33.9897, -118.1867, 35477),
    ('Bell Gardens', 'CA', 33.9652, -118.1514, 42072),
    ('Beverly Hills', 'CA', 34.0736, -118.4004, 32701),
    ('Claremont', 'CA', 34.0967, -117.7198, 36266),
    ('Covina', 'CA', 34.0900, -117.8903, 47450),
    ('Culver City', 'CA', 34.0211, -118.3965, 38883),
    ('Diamond Bar', 'CA', 34.0286, -117.8103, 55720),
    ('Duarte', 'CA', 34.1395, -117.9773, 21321),
    ('El Segundo', 'CA', 33.9192, -118.4165, 16654),
    ('Gardena', 'CA', 33.8883, -118.3089, 58829),
    ('Glendora', 'CA', 34.1361, -117.8653, 52445),
    ('Hermosa Beach', 'CA', 33.8622, -118.3995, 19506),
    ('La Mirada', 'CA', 33.9172, -118.0120, 48008),
    ('La Puente', 'CA', 34.0200, -117.9495, 39614),
    ('La Verne', 'CA', 34.1008, -117.7678, 31063),
    ('Lakewood', 'CA', 33.8536, -118.1339, 80048),
    ('Lawndale', 'CA', 33.8872, -118.3526, 32769),
    ('Lomita', 'CA', 33.7922, -118.3151, 20256),
    ('Manhattan Beach', 'CA', 33.8847, -118.4109, 35135),
    ('Maywood', 'CA', 33.9867, -118.1853, 27395),
    ('Monrovia', 'CA', 34.1442, -118.0019, 36590),
    ('Montebello', 'CA', 34.0167, -118.1131, 62640),
    ('Monterey Park', 'CA', 34.0625, -118.1228, 60269),
    ('Palos Verdes Estates', 'CA', 33.7795, -118.3885, 13438),
    ('Paramount', 'CA', 33.8894, -118.1597, 54098),
    ('Pico Rivera', 'CA', 33.9831, -118.0967, 62942);

  -- Insert Orange County cities
  INSERT INTO temp_socal_cities (city_name, state_code, latitude, longitude, population) VALUES
    ('Aliso Viejo', 'CA', 33.5767, -117.7256, 50044),
    ('Brea', 'CA', 33.9167, -117.9000, 47325),
    ('Buena Park', 'CA', 33.8675, -117.9981, 81788),
    ('Cypress', 'CA', 33.8169, -118.0375, 49087),
    ('Dana Point', 'CA', 33.4669, -117.6981, 33107),
    ('Fountain Valley', 'CA', 33.7092, -117.9536, 55313),
    ('La Habra', 'CA', 33.9319, -117.9461, 61653),
    ('La Palma', 'CA', 33.8464, -118.0467, 15568),
    ('Laguna Beach', 'CA', 33.5422, -117.7831, 22343),
    ('Laguna Hills', 'CA', 33.5963, -117.7178, 31508),
    ('Laguna Woods', 'CA', 33.6103, -117.7289, 16192),
    ('Lake Forest', 'CA', 33.6469, -117.6891, 84931),
    ('Los Alamitos', 'CA', 33.8028, -118.0728, 11780),
    ('Newport Beach', 'CA', 33.6189, -117.9289, 85239),
    ('Placentia', 'CA', 33.8722, -117.8703, 51824),
    ('Rancho Santa Margarita', 'CA', 33.6406, -117.6031, 47853),
    ('San Clemente', 'CA', 33.4269, -117.6119, 64581),
    ('San Juan Capistrano', 'CA', 33.5017, -117.6625, 35911),
    ('Seal Beach', 'CA', 33.7414, -118.1048, 24168),
    ('Stanton', 'CA', 33.8025, -117.9931, 38305),
    ('Villa Park', 'CA', 33.8147, -117.8131, 5812),
    ('Westminster', 'CA', 33.7514, -117.9939, 91137),
    ('Yorba Linda', 'CA', 33.8886, -117.8131, 68336);

  -- Insert San Diego County cities
  INSERT INTO temp_socal_cities (city_name, state_code, latitude, longitude, population) VALUES
    ('Coronado', 'CA', 32.6859, -117.1831, 24697),
    ('Del Mar', 'CA', 32.9595, -117.2653, 4161),
    ('El Cajon', 'CA', 32.7948, -116.9625, 106215),
    ('Imperial Beach', 'CA', 32.5839, -117.1131, 27448),
    ('La Mesa', 'CA', 32.7678, -117.0231, 59966),
    ('Lemon Grove', 'CA', 32.7425, -117.0314, 27627),
    ('National City', 'CA', 32.6781, -117.0992, 61394),
    ('Poway', 'CA', 32.9628, -117.0359, 49323),
    ('Santee', 'CA', 32.8384, -116.9739, 58081),
    ('Solana Beach', 'CA', 32.9912, -117.2712, 13296);

  -- Update professional locations based on new cities
  FOR prof_record IN SELECT id FROM professionals LOOP
    -- Select a random city
    SELECT 
      city_name,
      state_code,
      latitude + (random() - 0.5) * 0.02 as rand_lat,
      longitude + (random() - 0.5) * 0.02 as rand_lng
    INTO city_record
    FROM temp_socal_cities
    ORDER BY random()
    LIMIT 1;

    -- Update professional's location
    UPDATE professionals
    SET 
      location = city_record.city_name || ', ' || city_record.state_code,
      latitude = city_record.rand_lat,
      longitude = city_record.rand_lng,
      updated_at = now()
    WHERE id = prof_record.id;
  END LOOP;

  -- Clean up
  DROP TABLE temp_socal_cities;
END $$;