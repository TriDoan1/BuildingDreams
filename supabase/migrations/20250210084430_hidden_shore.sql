-- Create temporary table for cities
CREATE TEMPORARY TABLE socal_cities (
  city_name text,
  county text,
  state_code text,
  latitude double precision,
  longitude double precision,
  population integer,
  cumulative_weight integer DEFAULT 0
);

-- Insert city data with population weights
INSERT INTO socal_cities (city_name, county, state_code, latitude, longitude, population) VALUES
  -- Los Angeles County (25 most populous)
  ('Los Angeles', 'Los Angeles', 'CA', 34.0522, -118.2437, 3898747),
  ('Long Beach', 'Los Angeles', 'CA', 33.7701, -118.1937, 466742),
  ('Santa Clarita', 'Los Angeles', 'CA', 34.3917, -118.5426, 228673),
  ('Glendale', 'Los Angeles', 'CA', 34.1425, -118.2551, 196543),
  ('Pomona', 'Los Angeles', 'CA', 34.0551, -117.7500, 151348),
  ('Torrance', 'Los Angeles', 'CA', 33.8358, -118.3406, 147067),
  ('Pasadena', 'Los Angeles', 'CA', 34.1478, -118.1445, 141371),
  ('Downey', 'Los Angeles', 'CA', 33.9401, -118.1331, 111772),
  ('West Covina', 'Los Angeles', 'CA', 34.0686, -117.9394, 106098),
  ('Norwalk', 'Los Angeles', 'CA', 33.9022, -118.0817, 103949),
  ('Burbank', 'Los Angeles', 'CA', 34.1808, -118.3090, 103695),
  ('South Gate', 'Los Angeles', 'CA', 33.9547, -118.2020, 94396),
  ('Compton', 'Los Angeles', 'CA', 33.8958, -118.2201, 95605),
  ('Carson', 'Los Angeles', 'CA', 33.8317, -118.2820, 91394),
  ('Santa Monica', 'Los Angeles', 'CA', 34.0195, -118.4912, 91577),
  ('Hawthorne', 'Los Angeles', 'CA', 33.9164, -118.3525, 86199),
  ('Whittier', 'Los Angeles', 'CA', 33.9792, -118.0327, 85331),
  ('Alhambra', 'Los Angeles', 'CA', 34.0953, -118.1270, 83089),
  ('Lakewood', 'Los Angeles', 'CA', 33.8536, -118.1339, 80048),
  ('Bellflower', 'Los Angeles', 'CA', 33.8817, -118.1170, 76878),
  ('Baldwin Park', 'Los Angeles', 'CA', 34.0854, -117.9606, 75390),
  ('Lynwood', 'Los Angeles', 'CA', 33.9307, -118.2114, 69772),
  ('Redondo Beach', 'Los Angeles', 'CA', 33.8492, -118.3884, 66748),
  ('Pico Rivera', 'Los Angeles', 'CA', 33.9830, -118.0967, 62088),
  ('Montebello', 'Los Angeles', 'CA', 34.0167, -118.1131, 62640),

  -- Orange County (25 most populous)
  ('Anaheim', 'Orange', 'CA', 33.8366, -117.9143, 346824),
  ('Santa Ana', 'Orange', 'CA', 33.7455, -117.8677, 310227),
  ('Irvine', 'Orange', 'CA', 33.6846, -117.8265, 307670),
  ('Huntington Beach', 'Orange', 'CA', 33.6595, -117.9988, 198711),
  ('Garden Grove', 'Orange', 'CA', 33.7739, -117.9414, 171949),
  ('Fullerton', 'Orange', 'CA', 33.8704, -117.9242, 143617),
  ('Orange', 'Orange', 'CA', 33.7879, -117.8531, 139911),
  ('Costa Mesa', 'Orange', 'CA', 33.6411, -117.9187, 111918),
  ('Mission Viejo', 'Orange', 'CA', 33.6000, -117.6719, 94267),
  ('Westminster', 'Orange', 'CA', 33.7514, -117.9939, 91137),
  ('Newport Beach', 'Orange', 'CA', 33.6189, -117.9289, 85239),
  ('Buena Park', 'Orange', 'CA', 33.8675, -117.9981, 81788),
  ('Lake Forest', 'Orange', 'CA', 33.6469, -117.6891, 84931),
  ('Tustin', 'Orange', 'CA', 33.7458, -117.8261, 80276),
  ('Yorba Linda', 'Orange', 'CA', 33.8886, -117.8131, 68336),
  ('San Clemente', 'Orange', 'CA', 33.4269, -117.6119, 64581),
  ('Laguna Niguel', 'Orange', 'CA', 33.5225, -117.7075, 65316),
  ('La Habra', 'Orange', 'CA', 33.9319, -117.9461, 61653),
  ('Fountain Valley', 'Orange', 'CA', 33.7092, -117.9536, 55313),
  ('Aliso Viejo', 'Orange', 'CA', 33.5767, -117.7256, 50044),
  ('Rancho Santa Margarita', 'Orange', 'CA', 33.6406, -117.6031, 47853),
  ('Cypress', 'Orange', 'CA', 33.8169, -118.0375, 49087),
  ('Brea', 'Orange', 'CA', 33.9167, -117.9000, 47325),
  ('Stanton', 'Orange', 'CA', 33.8025, -117.9931, 38305),
  ('Dana Point', 'Orange', 'CA', 33.4669, -117.6981, 33107),

  -- Riverside County (25 most populous)
  ('Riverside', 'Riverside', 'CA', 33.9533, -117.3961, 314998),
  ('Moreno Valley', 'Riverside', 'CA', 33.9425, -117.2297, 208634),
  ('Corona', 'Riverside', 'CA', 33.8753, -117.5664, 169868),
  ('Murrieta', 'Riverside', 'CA', 33.5539, -117.2139, 118125),
  ('Temecula', 'Riverside', 'CA', 33.4936, -117.1484, 110003),
  ('Jurupa Valley', 'Riverside', 'CA', 34.0025, -117.4858, 105053),
  ('Menifee', 'Riverside', 'CA', 33.6971, -117.1850, 102527),
  ('Hemet', 'Riverside', 'CA', 33.7475, -116.9719, 89833),
  ('Lake Elsinore', 'Riverside', 'CA', 33.6681, -117.3273, 70265),
  ('Indio', 'Riverside', 'CA', 33.7206, -116.2156, 89137),
  ('Perris', 'Riverside', 'CA', 33.7825, -117.2286, 77879),
  ('Cathedral City', 'Riverside', 'CA', 33.7797, -116.4653, 51493),
  ('Palm Desert', 'Riverside', 'CA', 33.7222, -116.3744, 51163),
  ('Palm Springs', 'Riverside', 'CA', 33.8303, -116.5453, 44575),
  ('San Jacinto', 'Riverside', 'CA', 33.7839, -116.9597, 49215),
  ('Beaumont', 'Riverside', 'CA', 33.9294, -116.9770, 51063),
  ('La Quinta', 'Riverside', 'CA', 33.6633, -116.3100, 37558),
  ('Coachella', 'Riverside', 'CA', 33.6803, -116.1739, 41941),
  ('Banning', 'Riverside', 'CA', 33.9253, -116.8761, 29505),
  ('Desert Hot Springs', 'Riverside', 'CA', 33.9611, -116.5017, 32512),
  ('Norco', 'Riverside', 'CA', 33.9311, -117.5487, 26386),
  ('Wildomar', 'Riverside', 'CA', 33.5989, -117.2800, 36875),
  ('Rancho Mirage', 'Riverside', 'CA', 33.7397, -116.4128, 17218),
  ('Canyon Lake', 'Riverside', 'CA', 33.6847, -117.2728, 10647),
  ('Calimesa', 'Riverside', 'CA', 33.9972, -117.0617, 9329),

  -- San Bernardino County (25 most populous)
  ('San Bernardino', 'San Bernardino', 'CA', 34.1083, -117.2898, 222101),
  ('Fontana', 'San Bernardino', 'CA', 34.0922, -117.4350, 208393),
  ('Rancho Cucamonga', 'San Bernardino', 'CA', 34.1064, -117.5931, 177751),
  ('Ontario', 'San Bernardino', 'CA', 34.0633, -117.6509, 175265),
  ('Victorville', 'San Bernardino', 'CA', 34.5362, -117.2928, 134810),
  ('Rialto', 'San Bernardino', 'CA', 34.1064, -117.3703, 103526),
  ('Hesperia', 'San Bernardino', 'CA', 34.4264, -117.3009, 99818),
  ('Chino', 'San Bernardino', 'CA', 34.0122, -117.6889, 91403),
  ('Chino Hills', 'San Bernardino', 'CA', 33.9898, -117.7326, 83853),
  ('Upland', 'San Bernardino', 'CA', 34.0975, -117.6484, 79040),
  ('Apple Valley', 'San Bernardino', 'CA', 34.5008, -117.1858, 75791),
  ('Redlands', 'San Bernardino', 'CA', 34.0556, -117.1825, 71513),
  ('Colton', 'San Bernardino', 'CA', 34.0739, -117.3136, 54828),
  ('Yucaipa', 'San Bernardino', 'CA', 34.0336, -117.0475, 54542),
  ('Montclair', 'San Bernardino', 'CA', 34.0775, -117.6897, 39490),
  ('Highland', 'San Bernardino', 'CA', 34.1283, -117.2086, 55417),
  ('Adelanto', 'San Bernardino', 'CA', 34.5822, -117.4092, 38046),
  ('Loma Linda', 'San Bernardino', 'CA', 34.0483, -117.2612, 24791),
  ('Barstow', 'San Bernardino', 'CA', 34.8958, -117.0172, 24268),
  ('Twentynine Palms', 'San Bernardino', 'CA', 34.1356, -116.0542, 28065),
  ('Yucca Valley', 'San Bernardino', 'CA', 34.1142, -116.4322, 21777),
  ('Grand Terrace', 'San Bernardino', 'CA', 34.0339, -117.3131, 12426),
  ('Big Bear Lake', 'San Bernardino', 'CA', 34.2439, -116.9114, 5281),
  ('Needles', 'San Bernardino', 'CA', 34.8483, -114.6142, 4956),
  ('San Bernardino Mountains', 'San Bernardino', 'CA', 34.2241, -117.0642, 12000);

-- Calculate cumulative weights for distribution
UPDATE socal_cities sc1
SET cumulative_weight = (
  SELECT SUM(sc2.population)
  FROM socal_cities sc2
  WHERE sc2.city_name <= sc1.city_name
);

-- Create array of construction trades
DO $$
DECLARE
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
    'Stone and Tile'
  ];
  city_record RECORD;
  company_id uuid;
  user_id uuid;
  total_weight integer;
  random_threshold integer;
  first_names text[] := ARRAY[
    'James', 'Mary', 'John', 'Patricia', 'Robert',
    'Jennifer', 'Michael', 'Linda', 'William', 'Elizabeth',
    'David', 'Barbara', 'Richard', 'Susan', 'Joseph',
    'Jessica', 'Thomas', 'Sarah', 'Charles', 'Karen',
    'Christopher', 'Nancy', 'Daniel', 'Lisa', 'Matthew'
  ];
  last_names text[] := ARRAY[
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones',
    'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
    'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
    'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
    'Lee', 'Perez', 'Thompson', 'White', 'Harris'
  ];
  selected_specialty text;
  selected_certification text;
BEGIN
  -- Get total population weight
  SELECT SUM(population) INTO total_weight FROM socal_cities;

  -- Create 100 companies
  FOR counter IN 1..100 LOOP
    -- Select random city weighted by population
    random_threshold := (random() * total_weight)::integer;
    
    SELECT * INTO city_record
    FROM socal_cities
    WHERE cumulative_weight > random_threshold
    ORDER BY cumulative_weight
    LIMIT 1;

    -- Insert company
    INSERT INTO companies (
      name,
      description,
      location,
      website,
      is_hiring
    )
    VALUES (
      city_record.county || ' ' || trades[1 + (counter % array_length(trades, 1))] || ' Specialists',
      'Leading provider of construction services in ' || city_record.city_name || ' and surrounding areas.',
      city_record.city_name || ', ' || city_record.state_code,
      'https://example.com/company/' || counter,
      random() < 0.4
    )
    RETURNING id INTO company_id;
  END LOOP;

  -- Create 500 users and professionals
  FOR counter IN 1..500 LOOP
    -- Select random city weighted by population
    random_threshold := (random() * total_weight)::integer;
    
    SELECT * INTO city_record
    FROM socal_cities
    WHERE cumulative_weight > random_threshold
    ORDER BY cumulative_weight
    LIMIT 1;

    -- Create user with random name combination
    INSERT INTO users (
      email,
      name,
      image_url,
      phone
    )
    VALUES (
      'user' || counter || '@example.com',
      first_names[1 + (random() * 24)::integer] || ' ' ||
      last_names[1 + (random() * 24)::integer],
      'https://images.unsplash.com/photo-' || (
        CASE (counter % 5)
          WHEN 0 THEN '1500648767791-00dcc994a43e'
          WHEN 1 THEN '1494790108377-be9c29b29330'
          WHEN 2 THEN '1472099645785-5658abf4ff4e'
          WHEN 3 THEN '1534528741775-53994a69daeb'
          WHEN 4 THEN '1507003211169-0a1dd7228f2d'
        END
      ) || '?auto=format&fit=facearea&facepad=2&w=256&h=256',
      '(555) ' || LPAD((random() * 999)::integer::text, 3, '0') || '-' ||
      LPAD((random() * 9999)::integer::text, 4, '0')
    )
    RETURNING id INTO user_id;

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
      CASE WHEN random() < 0.67 THEN  -- 67% chance of being assigned to a company
        (SELECT id FROM companies ORDER BY random() LIMIT 1)
      ELSE
        NULL
      END,
      trades[1 + (random() * (array_length(trades, 1) - 1))::integer],
      75 + (random() * 150)::integer,
      'Experienced professional serving ' || city_record.city_name || ' and surrounding areas.',
      4.0 + (random() * 1.0),
      random() < 0.8,  -- 80% chance of being verified
      25 + (random() * 200)::integer,
      city_record.city_name || ', ' || city_record.state_code
    );

    -- Add 1-3 unique specialties
    FOR i IN 1..3 LOOP
      IF random() < 0.3 THEN  -- 30% chance for each specialty
        selected_specialty := trades[1 + (random() * (array_length(trades, 1) - 1))::integer];
        
        -- Only insert if this specialty doesn't exist for this professional
        IF NOT EXISTS (
          SELECT 1 FROM professional_specialties
          WHERE professional_id = user_id AND specialty = selected_specialty
        ) THEN
          INSERT INTO professional_specialties (professional_id, specialty)
          VALUES (user_id, selected_specialty);
        END IF;
      END IF;
    END LOOP;

    -- Add 1-3 unique certifications
    FOR i IN 1..3 LOOP
      IF random() < 0.3 THEN  -- 30% chance for each certification
        selected_certification := 'Certified ' || trades[1 + (random() * (array_length(trades, 1) - 1))::integer] || ' Professional';
        
        -- Only insert if this certification doesn't exist for this professional
        IF NOT EXISTS (
          SELECT 1 FROM professional_certifications
          WHERE professional_id = user_id AND certification = selected_certification
        ) THEN
          INSERT INTO professional_certifications (
            professional_id,
            certification,
            issued_date,
            expiry_date
          )
          VALUES (
            user_id,
            selected_certification,
            now() - (random() * interval '5 years'),
            now() + (random() * interval '5 years')
          );
        END IF;
      END IF;
    END LOOP;
  END LOOP;
END $$;

-- Clean up
DROP TABLE socal_cities;