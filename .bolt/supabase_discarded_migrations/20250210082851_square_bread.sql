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

-- Insert top 30 cities across counties
INSERT INTO socal_cities (city_name, county, state_code, latitude, longitude, population, weight) VALUES
  -- Los Angeles County (10 cities)
  ('Los Angeles', 'Los Angeles', 'CA', 34.0522, -118.2437, 3898747, 25),
  ('Long Beach', 'Los Angeles', 'CA', 33.7701, -118.1937, 466742, 8),
  ('Santa Clarita', 'Los Angeles', 'CA', 34.3917, -118.5426, 228673, 5),
  ('Glendale', 'Los Angeles', 'CA', 34.1425, -118.2551, 196543, 4),
  ('Pomona', 'Los Angeles', 'CA', 34.0551, -117.7500, 151348, 3),
  ('Torrance', 'Los Angeles', 'CA', 33.8358, -118.3406, 147067, 3),
  ('Pasadena', 'Los Angeles', 'CA', 34.1478, -118.1445, 141371, 3),
  ('Downey', 'Los Angeles', 'CA', 33.9401, -118.1331, 111772, 2),
  ('West Covina', 'Los Angeles', 'CA', 34.0686, -117.9394, 106098, 2),
  ('Burbank', 'Los Angeles', 'CA', 34.1808, -118.3090, 103695, 2),

  -- Orange County (8 cities)
  ('Anaheim', 'Orange', 'CA', 33.8366, -117.9143, 346824, 7),
  ('Santa Ana', 'Orange', 'CA', 33.7455, -117.8677, 310227, 6),
  ('Irvine', 'Orange', 'CA', 33.6846, -117.8265, 307670, 6),
  ('Huntington Beach', 'Orange', 'CA', 33.6595, -117.9988, 198711, 4),
  ('Garden Grove', 'Orange', 'CA', 33.7739, -117.9414, 171949, 3),
  ('Fullerton', 'Orange', 'CA', 33.8704, -117.9242, 143617, 3),
  ('Costa Mesa', 'Orange', 'CA', 33.6411, -117.9187, 111918, 2),
  ('Mission Viejo', 'Orange', 'CA', 33.6000, -117.6719, 94267, 2),

  -- Riverside County (6 cities)
  ('Riverside', 'Riverside', 'CA', 33.9533, -117.3961, 314998, 6),
  ('Moreno Valley', 'Riverside', 'CA', 33.9425, -117.2297, 208634, 4),
  ('Corona', 'Riverside', 'CA', 33.8753, -117.5664, 169868, 3),
  ('Temecula', 'Riverside', 'CA', 33.4936, -117.1484, 110003, 2),
  ('Murrieta', 'Riverside', 'CA', 33.5539, -117.2139, 118125, 2),
  ('Hemet', 'Riverside', 'CA', 33.7475, -116.9719, 89833, 2),

  -- San Bernardino County (Inland) (6 cities)
  ('San Bernardino', 'San Bernardino', 'CA', 34.1083, -117.2898, 222101, 5),
  ('Fontana', 'San Bernardino', 'CA', 34.0922, -117.4350, 208393, 4),
  ('Rancho Cucamonga', 'San Bernardino', 'CA', 34.1064, -117.5931, 177751, 3),
  ('Ontario', 'San Bernardino', 'CA', 34.0633, -117.6509, 175265, 3),
  ('Victorville', 'San Bernardino', 'CA', 34.5362, -117.2928, 134810, 2),
  ('Rialto', 'San Bernardino', 'CA', 34.1064, -117.3703, 103526, 2);

-- Create 50 companies
DO $$
DECLARE
  city_record RECORD;
  company_id uuid;
  total_weight integer;
  random_threshold float;
  company_name text;
  company_description text;
BEGIN
  -- Calculate total weight for weighted random selection
  SELECT SUM(weight) INTO total_weight FROM socal_cities;

  -- Create companies
  FOR counter IN 1..50 LOOP
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

    -- Generate company name
    company_name := 
      CASE (random() * 4)::int
        WHEN 0 THEN city_record.county || ' '
        WHEN 1 THEN 'SoCal '
        WHEN 2 THEN 'Pacific '
        ELSE 'Golden State '
      END ||
      CASE (random() * 4)::int
        WHEN 0 THEN 'Construction'
        WHEN 1 THEN 'Builders'
        WHEN 2 THEN 'Development'
        ELSE 'Contractors'
      END || ' ' ||
      counter::text;

    company_description := 'Professional ' || company_name || ' serving ' || 
      city_record.city_name || ' and surrounding areas in ' || city_record.county || ' County.';

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
      company_description,
      city_record.city_name || ', ' || city_record.state_code,
      'https://www.' || lower(regexp_replace(company_name, '[^a-zA-Z0-9]', '')) || '.example.com',
      random() < 0.4  -- 40% chance of hiring
    )
    RETURNING id INTO company_id;
  END LOOP;
END $$;

-- Create 500 users and assign 2/3 to companies
DO $$
DECLARE
  city_record RECORD;
  user_id uuid;
  total_weight integer;
  random_threshold float;
  base_email text := 'socal.user';
  counter integer := 1;
  first_names text[] := ARRAY[
    'James', 'John', 'Robert', 'Michael', 'William',
    'David', 'Richard', 'Joseph', 'Thomas', 'Charles',
    'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth',
    'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen',
    'Christopher', 'Daniel', 'Paul', 'Mark', 'Donald',
    'George', 'Kenneth', 'Steven', 'Edward', 'Brian',
    'Michelle', 'Lisa', 'Sandra', 'Helen', 'Ashley',
    'Donna', 'Kimberly', 'Carol', 'Michelle', 'Emily'
  ];
  last_names text[] := ARRAY[
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones',
    'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
    'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
    'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
    'Lee', 'Perez', 'Thompson', 'White', 'Harris',
    'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson',
    'Walker', 'Young', 'Allen', 'King', 'Wright',
    'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores'
  ];
BEGIN
  -- Calculate total weight for weighted random selection
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
      first_names[1 + (random() * (array_length(first_names, 1) - 1))::integer] || ' ' ||
      last_names[1 + (random() * (array_length(last_names, 1) - 1))::integer],
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
      CASE 
        -- Assign 2/3 of users to companies
        WHEN random() < 0.67 THEN (SELECT id FROM companies ORDER BY random() LIMIT 1)
        ELSE NULL
      END,
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

    -- Add specialties
    INSERT INTO professional_specialties (professional_id, specialty)
    SELECT user_id, specialty
    FROM (
      SELECT unnest(ARRAY[
        'Residential',
        'Commercial',
        'Industrial',
        'Renovation',
        'New Construction'
      ]) as specialty
    ) s
    WHERE random() < 0.3;  -- 30% chance of having each specialty

    -- Add certifications
    INSERT INTO professional_certifications (
      professional_id,
      certification,
      issued_date,
      expiry_date
    )
    SELECT
      user_id,
      cert,
      now() - (random() * interval '5 years'),
      now() + (random() * interval '5 years')
    FROM (
      SELECT unnest(ARRAY[
        'OSHA Certified',
        'Licensed Contractor',
        'Master Tradesman',
        'Energy Efficiency',
        'Safety Specialist'
      ]) as cert
    ) c
    WHERE random() < 0.3;  -- 30% chance of having each certification
  END LOOP;
END $$;

-- Clean up
DROP TABLE socal_cities;