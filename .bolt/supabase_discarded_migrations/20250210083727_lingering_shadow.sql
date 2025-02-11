/*
  # SoCal Data Population

  1. Data Structure
    - Creates temporary table for city data
    - Includes population weights for realistic distribution
    - Stores coordinates for accurate geolocation

  2. Companies
    - Creates 100 construction companies
    - Distributes across SoCal cities based on population
    - Each specializes in a unique trade
    - ~40% marked as hiring

  3. Users & Professionals
    - Creates 500 professional users
    - Links professionals to companies
    - Adds specialties and certifications
    - Includes realistic contact info and ratings
*/

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
  ('Los Angeles', 'Los Angeles', 'CA', 34.0522, -118.2437, 3898747),
  ('San Diego', 'San Diego', 'CA', 32.7157, -117.1611, 1386932),
  ('Irvine', 'Orange', 'CA', 33.6846, -117.8265, 307670),
  ('Santa Ana', 'Orange', 'CA', 33.7455, -117.8677, 310227),
  ('Anaheim', 'Orange', 'CA', 33.8366, -117.9143, 346824),
  ('Riverside', 'Riverside', 'CA', 33.9533, -117.3961, 314998),
  ('San Bernardino', 'San Bernardino', 'CA', 34.1083, -117.2898, 222101),
  ('Long Beach', 'Los Angeles', 'CA', 33.7701, -118.1937, 466742);

-- Calculate cumulative weights for distribution
UPDATE socal_cities sc1
SET cumulative_weight = (
  SELECT SUM(sc2.population)
  FROM socal_cities sc2
  WHERE sc2.city_name <= sc1.city_name
);

-- Create 100 construction companies
DO $$
DECLARE
  city_record RECORD;
  company_id uuid;
  trades text[] := ARRAY[
    'General Contracting', 'Electrical', 'Plumbing', 'HVAC', 'Carpentry',
    'Masonry', 'Roofing', 'Landscaping', 'Interior Design', 'Painting',
    'Flooring', 'Concrete', 'Glass and Mirror', 'Fencing', 'Solar Installation',
    'Security Systems', 'Home Automation', 'Kitchen and Bath', 'Custom Cabinetry',
    'Stone and Tile'
  ];
  company_prefixes text[] := ARRAY[
    'Pacific', 'SoCal', 'Golden State', 'Coastal', 'Metro',
    'California', 'West Coast', 'Orange County', 'San Diego', 'LA'
  ];
  company_suffixes text[] := ARRAY[
    'Construction', 'Builders', 'Contractors', 'Services', 'Solutions'
  ];
  total_weight integer;
  random_threshold integer;
BEGIN
  -- Get total population weight
  SELECT SUM(population) INTO total_weight FROM socal_cities;

  -- Create companies
  FOR counter IN 1..100 LOOP
    -- Select random city weighted by population
    random_threshold := (random() * total_weight)::integer;
    
    SELECT * INTO city_record
    FROM socal_cities
    WHERE cumulative_weight > random_threshold
    ORDER BY cumulative_weight
    LIMIT 1;

    -- Insert company with generated name
    INSERT INTO companies (
      name,
      description,
      location,
      website,
      is_hiring,
      latitude,
      longitude
    )
    VALUES (
      (SELECT company_prefixes[1 + (random() * 9)::integer] || ' ' || 
              trades[1 + (counter % 20)] || ' ' ||
              company_suffixes[1 + (random() * 4)::integer]),
      'Leading provider of construction and renovation services in ' || city_record.city_name,
      city_record.city_name || ', ' || city_record.state_code,
      'https://example.com/company/' || counter,
      random() < 0.4,
      city_record.latitude + (random() - 0.5) * 0.02,
      city_record.longitude + (random() - 0.5) * 0.02
    )
    RETURNING id INTO company_id;
  END LOOP;
END $$;

-- Create 500 users and professionals
DO $$
DECLARE
  city_record RECORD;
  company_record RECORD;
  user_id uuid;
  total_weight integer;
  random_threshold integer;
  base_email text := 'socal.pro';
  counter integer := 1;
BEGIN
  -- Get total population weight
  SELECT SUM(population) INTO total_weight FROM socal_cities;

  -- Create users and professionals
  FOR counter IN 1..500 LOOP
    -- Select random city weighted by population
    random_threshold := (random() * total_weight)::integer;
    
    SELECT * INTO city_record
    FROM socal_cities
    WHERE cumulative_weight > random_threshold
    ORDER BY cumulative_weight
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
      CASE (random() * 9)::integer
        WHEN 0 THEN 'John Smith'
        WHEN 1 THEN 'Maria Garcia'
        WHEN 2 THEN 'David Chen'
        WHEN 3 THEN 'Sarah Johnson'
        WHEN 4 THEN 'Michael Kim'
        WHEN 5 THEN 'Lisa Patel'
        WHEN 6 THEN 'James Wilson'
        WHEN 7 THEN 'Emma Davis'
        WHEN 8 THEN 'Robert Lee'
        ELSE 'Sofia Rodriguez'
      END || ' ' || counter,
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

    -- Randomly select company (2/3 probability)
    IF random() < 0.67 THEN
      SELECT id INTO company_record
      FROM companies
      WHERE random() < 0.1
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
      location,
      latitude,
      longitude
    )
    VALUES (
      user_id,
      company_record.id,
      CASE (random() * 9)::integer
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
      75 + (random() * 150)::integer,
      'Experienced professional serving ' || city_record.city_name || ' and surrounding areas.',
      4.0 + (random() * 1.0),
      random() < 0.8,
      25 + (random() * 200)::integer,
      city_record.city_name || ', ' || city_record.state_code,
      city_record.latitude + (random() - 0.5) * 0.02,
      city_record.longitude + (random() - 0.5) * 0.02
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
    WHERE random() < 0.3;

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
    WHERE random() < 0.3;
  END LOOP;
END $$;

-- Clean up
DROP TABLE socal_cities;