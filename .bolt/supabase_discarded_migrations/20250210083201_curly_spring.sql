-- Create temporary table for top cities in each county
CREATE TEMPORARY TABLE socal_cities (
  city_name text,
  county text,
  state_code text,
  latitude double precision,
  longitude double precision,
  population integer,
  weight integer
);

-- Insert top 30 cities for each county
INSERT INTO socal_cities (city_name, county, state_code, latitude, longitude, population, weight) VALUES
  -- Los Angeles County (30 cities)
  ('Los Angeles', 'Los Angeles', 'CA', 34.0522, -118.2437, 3898747, 25),
  ('Long Beach', 'Los Angeles', 'CA', 33.7701, -118.1937, 466742, 8),
  ('Santa Clarita', 'Los Angeles', 'CA', 34.3917, -118.5426, 228673, 5),
  ('Glendale', 'Los Angeles', 'CA', 34.1425, -118.2551, 196543, 4),
  ('Pomona', 'Los Angeles', 'CA', 34.0551, -117.7500, 151348, 3),
  ('Torrance', 'Los Angeles', 'CA', 33.8358, -118.3406, 147067, 3),
  ('Pasadena', 'Los Angeles', 'CA', 34.1478, -118.1445, 141371, 3),
  ('Downey', 'Los Angeles', 'CA', 33.9401, -118.1331, 111772, 2),
  ('West Covina', 'Los Angeles', 'CA', 34.0686, -117.9394, 106098, 2),
  ('Norwalk', 'Los Angeles', 'CA', 33.9022, -118.0817, 103949, 2),
  ('Burbank', 'Los Angeles', 'CA', 34.1808, -118.3090, 103695, 2),
  ('South Gate', 'Los Angeles', 'CA', 33.9547, -118.2020, 94396, 2),
  ('Compton', 'Los Angeles', 'CA', 33.8958, -118.2201, 95605, 2),
  ('Carson', 'Los Angeles', 'CA', 33.8317, -118.2820, 91394, 2),
  ('Santa Monica', 'Los Angeles', 'CA', 34.0195, -118.4912, 91577, 2),
  ('Hawthorne', 'Los Angeles', 'CA', 33.9164, -118.3525, 86199, 2),
  ('Whittier', 'Los Angeles', 'CA', 33.9792, -118.0327, 85331, 2),
  ('Alhambra', 'Los Angeles', 'CA', 34.0953, -118.1270, 83089, 2),
  ('Lakewood', 'Los Angeles', 'CA', 33.8536, -118.1339, 80048, 2),
  ('Bellflower', 'Los Angeles', 'CA', 33.8817, -118.1170, 76878, 2),
  ('Baldwin Park', 'Los Angeles', 'CA', 34.0854, -117.9606, 75390, 2),
  ('Lynwood', 'Los Angeles', 'CA', 33.9307, -118.2114, 69772, 2),
  ('Redondo Beach', 'Los Angeles', 'CA', 33.8492, -118.3884, 66748, 2),
  ('Pico Rivera', 'Los Angeles', 'CA', 33.9830, -118.0967, 62088, 2),
  ('Montebello', 'Los Angeles', 'CA', 34.0167, -118.1131, 62640, 2),
  ('Monterey Park', 'Los Angeles', 'CA', 34.0625, -118.1228, 60269, 2),
  ('Gardena', 'Los Angeles', 'CA', 33.8883, -118.3089, 58829, 2),
  ('Diamond Bar', 'Los Angeles', 'CA', 34.0286, -117.8103, 55720, 2),
  ('Arcadia', 'Los Angeles', 'CA', 34.1397, -118.0353, 56364, 2),
  ('Paramount', 'Los Angeles', 'CA', 33.8894, -118.1597, 54098, 2),

  -- Orange County (30 cities)
  ('Anaheim', 'Orange', 'CA', 33.8366, -117.9143, 346824, 7),
  ('Santa Ana', 'Orange', 'CA', 33.7455, -117.8677, 310227, 6),
  ('Irvine', 'Orange', 'CA', 33.6846, -117.8265, 307670, 6),
  ('Huntington Beach', 'Orange', 'CA', 33.6595, -117.9988, 198711, 4),
  ('Garden Grove', 'Orange', 'CA', 33.7739, -117.9414, 171949, 3),
  ('Fullerton', 'Orange', 'CA', 33.8704, -117.9242, 143617, 3),
  ('Orange', 'Orange', 'CA', 33.7879, -117.8531, 139911, 3),
  ('Costa Mesa', 'Orange', 'CA', 33.6411, -117.9187, 111918, 2),
  ('Mission Viejo', 'Orange', 'CA', 33.6000, -117.6719, 94267, 2),
  ('Westminster', 'Orange', 'CA', 33.7514, -117.9939, 91137, 2),
  ('Newport Beach', 'Orange', 'CA', 33.6189, -117.9289, 85239, 2),
  ('Buena Park', 'Orange', 'CA', 33.8675, -117.9981, 81788, 2),
  ('Lake Forest', 'Orange', 'CA', 33.6469, -117.6891, 84931, 2),
  ('Tustin', 'Orange', 'CA', 33.7458, -117.8261, 80276, 2),
  ('Yorba Linda', 'Orange', 'CA', 33.8886, -117.8131, 68336, 2),
  ('San Clemente', 'Orange', 'CA', 33.4269, -117.6119, 64581, 2),
  ('Laguna Niguel', 'Orange', 'CA', 33.5225, -117.7075, 65316, 2),
  ('La Habra', 'Orange', 'CA', 33.9319, -117.9461, 61653, 2),
  ('Fountain Valley', 'Orange', 'CA', 33.7092, -117.9536, 55313, 2),
  ('Aliso Viejo', 'Orange', 'CA', 33.5767, -117.7256, 50044, 2),
  ('Rancho Santa Margarita', 'Orange', 'CA', 33.6406, -117.6031, 47853, 2),
  ('Cypress', 'Orange', 'CA', 33.8169, -118.0375, 49087, 2),
  ('Brea', 'Orange', 'CA', 33.9167, -117.9000, 47325, 2),
  ('Stanton', 'Orange', 'CA', 33.8025, -117.9931, 38305, 2),
  ('Dana Point', 'Orange', 'CA', 33.4669, -117.6981, 33107, 2),
  ('Laguna Hills', 'Orange', 'CA', 33.5963, -117.7178, 31508, 2),
  ('Laguna Beach', 'Orange', 'CA', 33.5422, -117.7831, 22343, 2),
  ('Seal Beach', 'Orange', 'CA', 33.7414, -118.1048, 24168, 2),
  ('La Palma', 'Orange', 'CA', 33.8464, -118.0467, 15568, 2),
  ('Villa Park', 'Orange', 'CA', 33.8147, -117.8131, 5812, 2),

  -- Riverside County (30 cities)
  ('Riverside', 'Riverside', 'CA', 33.9533, -117.3961, 314998, 6),
  ('Moreno Valley', 'Riverside', 'CA', 33.9425, -117.2297, 208634, 4),
  ('Corona', 'Riverside', 'CA', 33.8753, -117.5664, 169868, 3),
  ('Murrieta', 'Riverside', 'CA', 33.5539, -117.2139, 118125, 2),
  ('Temecula', 'Riverside', 'CA', 33.4936, -117.1484, 110003, 2),
  ('Jurupa Valley', 'Riverside', 'CA', 34.0025, -117.4858, 105053, 2),
  ('Menifee', 'Riverside', 'CA', 33.6971, -117.1850, 102527, 2),
  ('Hemet', 'Riverside', 'CA', 33.7475, -116.9719, 89833, 2),
  ('Lake Elsinore', 'Riverside', 'CA', 33.6681, -117.3273, 70265, 2),
  ('Indio', 'Riverside', 'CA', 33.7206, -116.2156, 89137, 2),
  ('Perris', 'Riverside', 'CA', 33.7825, -117.2286, 77879, 2),
  ('Cathedral City', 'Riverside', 'CA', 33.7797, -116.4653, 51493, 2),
  ('Palm Desert', 'Riverside', 'CA', 33.7222, -116.3744, 51163, 2),
  ('Palm Springs', 'Riverside', 'CA', 33.8303, -116.5453, 44575, 2),
  ('San Jacinto', 'Riverside', 'CA', 33.7839, -116.9597, 49215, 2),
  ('Beaumont', 'Riverside', 'CA', 33.9294, -116.9770, 51063, 2),
  ('La Quinta', 'Riverside', 'CA', 33.6633, -116.3100, 37558, 2),
  ('Coachella', 'Riverside', 'CA', 33.6803, -116.1739, 41941, 2),
  ('Banning', 'Riverside', 'CA', 33.9253, -116.8761, 29505, 2),
  ('Desert Hot Springs', 'Riverside', 'CA', 33.9611, -116.5017, 32512, 2),
  ('Norco', 'Riverside', 'CA', 33.9311, -117.5487, 26386, 2),
  ('Wildomar', 'Riverside', 'CA', 33.5989, -117.2800, 36875, 2),
  ('Rancho Mirage', 'Riverside', 'CA', 33.7397, -116.4128, 17218, 2),
  ('Canyon Lake', 'Riverside', 'CA', 33.6847, -117.2728, 10647, 2),
  ('Calimesa', 'Riverside', 'CA', 33.9972, -117.0617, 9329, 2),
  ('Indian Wells', 'Riverside', 'CA', 33.7175, -116.3417, 4757, 2),
  ('Eastvale', 'Riverside', 'CA', 33.9525, -117.5644, 69757, 2),
  ('Blythe', 'Riverside', 'CA', 33.6178, -114.5882, 19255, 2),
  ('San Jacinto', 'Riverside', 'CA', 33.7839, -116.9597, 49215, 2),
  ('Desert Hot Springs', 'Riverside', 'CA', 33.9611, -116.5017, 32512, 2),

  -- San Bernardino County (Inland Empire) (30 cities)
  ('San Bernardino', 'San Bernardino', 'CA', 34.1083, -117.2898, 222101, 5),
  ('Fontana', 'San Bernardino', 'CA', 34.0922, -117.4350, 208393, 4),
  ('Rancho Cucamonga', 'San Bernardino', 'CA', 34.1064, -117.5931, 177751, 3),
  ('Ontario', 'San Bernardino', 'CA', 34.0633, -117.6509, 175265, 3),
  ('Victorville', 'San Bernardino', 'CA', 34.5362, -117.2928, 134810, 2),
  ('Rialto', 'San Bernardino', 'CA', 34.1064, -117.3703, 103526, 2),
  ('Hesperia', 'San Bernardino', 'CA', 34.4264, -117.3009, 99818, 2),
  ('Chino', 'San Bernardino', 'CA', 34.0122, -117.6889, 91403, 2),
  ('Chino Hills', 'San Bernardino', 'CA', 33.9898, -117.7326, 83853, 2),
  ('Upland', 'San Bernardino', 'CA', 34.0975, -117.6484, 79040, 2),
  ('Apple Valley', 'San Bernardino', 'CA', 34.5008, -117.1858, 75791, 2),
  ('Redlands', 'San Bernardino', 'CA', 34.0556, -117.1825, 71513, 2),
  ('Colton', 'San Bernardino', 'CA', 34.0739, -117.3136, 54828, 2),
  ('Yucaipa', 'San Bernardino', 'CA', 34.0336, -117.0475, 54542, 2),
  ('Montclair', 'San Bernardino', 'CA', 34.0775, -117.6897, 39490, 2),
  ('Highland', 'San Bernardino', 'CA', 34.1283, -117.2086, 55417, 2),
  ('Adelanto', 'San Bernardino', 'CA', 34.5822, -117.4092, 38046, 2),
  ('Loma Linda', 'San Bernardino', 'CA', 34.0483, -117.2612, 24791, 2),
  ('Barstow', 'San Bernardino', 'CA', 34.8958, -117.0172, 24268, 2),
  ('Twentynine Palms', 'San Bernardino', 'CA', 34.1356, -116.0542, 28065, 2),
  ('Yucca Valley', 'San Bernardino', 'CA', 34.1142, -116.4322, 21777, 2),
  ('Grand Terrace', 'San Bernardino', 'CA', 34.0339, -117.3131, 12426, 2),
  ('Big Bear Lake', 'San Bernardino', 'CA', 34.2439, -116.9114, 5281, 2),
  ('Needles', 'San Bernardino', 'CA', 34.8483, -114.6142, 4956, 2),
  ('Rancho Cucamonga', 'San Bernardino', 'CA', 34.1064, -117.5931, 177751, 2),
  ('Ontario', 'San Bernardino', 'CA', 34.0633, -117.6509, 175265, 2),
  ('Victorville', 'San Bernardino', 'CA', 34.5362, -117.2928, 134810, 2),
  ('Rialto', 'San Bernardino', 'CA', 34.1064, -117.3703, 103526, 2),
  ('Hesperia', 'San Bernardino', 'CA', 34.4264, -117.3009, 99818, 2),
  ('Chino', 'San Bernardino', 'CA', 34.0122, -117.6889, 91403, 2);

-- Create 50 construction companies with unique trades
DO $$
DECLARE
  city_record RECORD;
  company_id uuid;
  company_name text;
  trade text;
  trades text[] := ARRAY[
    'General Contracting',
    'Electrical',
    'Plumbing',
    'HVAC',
    'Carpentry',
    'Masonry',
    'Roofing',
    'Landscaping',
    'Interior Design',
    'Painting',
    'Flooring',
    'Concrete',
    'Glass and Mirror',
    'Fencing',
    'Solar Installation',
    'Security Systems',
    'Home Automation',
    'Kitchen and Bath',
    'Custom Cabinetry',
    'Stone and Tile',
    'Foundation',
    'Demolition',
    'Excavation',
    'Drywall',
    'Insulation',
    'Windows and Doors',
    'Garage Doors',
    'Pool Construction',
    'Outdoor Living',
    'Fire Protection',
    'Waterproofing',
    'Structural Steel',
    'Metal Fabrication',
    'Architectural Design',
    'Engineering',
    'Project Management',
    'Green Building',
    'Historic Restoration',
    'Custom Homes',
    'Remodeling',
    'Additions',
    'Basement Finishing',
    'Deck Building',
    'Siding',
    'Gutters',
    'Paving',
    'Septic Systems',
    'Well Drilling',
    'Elevator Installation',
    'Sound Systems'
  ];
BEGIN
  -- Create one company for each unique trade
  FOR counter IN 1..50 LOOP
    -- Select random city weighted by population
    SELECT * INTO city_record
    FROM socal_cities
    WHERE random() < (weight::float / (SELECT SUM(weight) FROM socal_cities))
    ORDER BY random()
    LIMIT 1;

    -- Generate company name
    company_name := 
      CASE (random() * 4)::int
        WHEN 0 THEN city_record.county || ' '
        WHEN 1 THEN 'SoCal '
        WHEN 2 THEN 'Pacific '
        ELSE 'Golden State '
      END ||
      trades[counter] || ' ' ||
      CASE (random() * 4)::int
        WHEN 0 THEN 'Specialists'
        WHEN 1 THEN 'Pros'
        WHEN 2 THEN 'Experts'
        ELSE 'Masters'
      END;

    -- Insert company
    INSERT INTO companies (
      name,
      description,
      location,
      website,
      is_hiring
    )
    VALUES (
      company_name,
      'Leading ' || trades[counter] || ' company serving ' || city_record.city_name || 
      ' and surrounding areas in ' || city_record.county || ' County.',
      city_record.city_name || ', ' || city_record.state_code,
      'https://www.' || lower(regexp_replace(company_name, '[^a-zA-Z0-9]', '')) || '.example.com',
      random() < 0.4  -- 40% chance of hiring
    )
    RETURNING id INTO company_id;
  END LOOP;
END $$;

-- Create 500 users and distribute them across cities
DO $$
DECLARE
  city_record RECORD;
  user_id uuid;
  company_id uuid;
  base_email text := 'socal.pro';
  counter int := 1;
  total_weight int;
  random_threshold float;
BEGIN
  -- Calculate total weight for weighted distribution
  SELECT SUM(weight) INTO total_weight FROM socal_cities;

  -- Create users
  FOR counter IN 1..500 LOOP
    -- Select random city weighted by population
    random_threshold := random() * total_weight;
    
    SELECT * INTO city_record
    FROM socal_cities
    WHERE random_threshold <= (
      SELECT SUM(sc2.weight)
      FROM socal_cities sc2
      WHERE sc2.city_name <= socal_cities.city_name
    )
    ORDER BY city_name
    LIMIT 1;

    -- Create user
    INSERT INTO users (
      email,
      name,
      image_url,
      phone
    )
    VALUES (
      base_email || counter || '@example.com',
      'Professional ' || counter,
      'https://images.unsplash.com/photo-' || (
        CASE (counter % 5)
          WHEN 0 THEN '1500648767791-00dcc994a43e'
          WHEN 1 THEN '1494790108377-be9c29b29330'
          WHEN 2 THEN '1472099645785-5658abf4ff4e'
          WHEN 3 THEN '1534528741775-53994a69daeb'
          WHEN 4 THEN '1507003211169-0a1dd7228f2d'
        END
      ) || '?auto=format&fit=facearea&facepad=2&w=256&h=256',
      '(555) ' || LPAD((random() * 999)::int::text, 3, '0') || '-' || 
      LPAD((random() * 9999)::int::text, 4, '0')
    )
    RETURNING id INTO user_id;

    -- Randomly assign to company (2/3 probability)
    IF random() < 0.67 THEN
      SELECT id INTO company_id
      FROM companies
      ORDER BY random()
      LIMIT 1;
    END IF;

    -- Create professional profile
    INSERT INTO professionals (
      user_id,
      company_id,
      role,
      hourly_rate,
      bio,
      rating,
      verified,
      projects_completed,
      location
    )
    VALUES (
      user_id,
      company_id,
      CASE (random() * 9)::int
        WHEN 0 THEN 'General Contractor'
        WHEN 1 THEN 'Electrician'
        WHEN 2 THEN 'Plumber'
        WHEN 3 THEN 'Carpenter'
        WHEN 4 THEN 'Mason'
        WHEN 5 THEN 'HVAC Technician'
        WHEN 6 THEN 'Painter'
        WHEN 7 THEN 'Roofer'
        WHEN 8 THEN 'Landscaper'
        ELSE 'Interior Designer'
      END,
      75 + (random() * 150)::int,
      'Experienced professional serving ' || city_record.city_name || ' and surrounding areas.',
      4.0 + (random() * 1.0),
      random() < 0.8,  -- 80% chance of being verified
      25 + (random() * 200)::int,
      city_record.city_name || ', ' || city_record.state_code
    );
  END LOOP;
END $$;

-- Clean up
DROP TABLE socal_cities;