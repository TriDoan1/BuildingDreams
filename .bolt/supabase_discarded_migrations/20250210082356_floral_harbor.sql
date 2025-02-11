-- Create temporary table for SoCal cities
CREATE TEMPORARY TABLE socal_cities (
  city_name text,
  county text,
  state_code text,
  latitude double precision,
  longitude double precision,
  population integer,
  target_users integer DEFAULT 500
);

-- Insert cities by county
INSERT INTO socal_cities (city_name, county, state_code, latitude, longitude, population) VALUES
  -- Los Angeles County
  ('Los Angeles', 'Los Angeles', 'CA', 34.0522, -118.2437, 3898747),
  ('Long Beach', 'Los Angeles', 'CA', 33.7701, -118.1937, 466742),
  ('Santa Clarita', 'Los Angeles', 'CA', 34.3917, -118.5426, 228673),
  ('Glendale', 'Los Angeles', 'CA', 34.1425, -118.2551, 196543),
  ('Lancaster', 'Los Angeles', 'CA', 34.6868, -118.1542, 173516),
  ('Palmdale', 'Los Angeles', 'CA', 34.5794, -118.1165, 169450),
  ('Pomona', 'Los Angeles', 'CA', 34.0551, -117.7500, 151348),
  ('Torrance', 'Los Angeles', 'CA', 33.8358, -118.3406, 147067),
  ('Pasadena', 'Los Angeles', 'CA', 34.1478, -118.1445, 141371),
  ('Downey', 'Los Angeles', 'CA', 33.9401, -118.1331, 111772),
  
  -- Orange County
  ('Anaheim', 'Orange', 'CA', 33.8366, -117.9143, 346824),
  ('Santa Ana', 'Orange', 'CA', 33.7455, -117.8677, 310227),
  ('Irvine', 'Orange', 'CA', 33.6846, -117.8265, 307670),
  ('Huntington Beach', 'Orange', 'CA', 33.6595, -117.9988, 198711),
  ('Garden Grove', 'Orange', 'CA', 33.7739, -117.9414, 171949),
  ('Fullerton', 'Orange', 'CA', 33.8704, -117.9242, 143617),
  ('Costa Mesa', 'Orange', 'CA', 33.6411, -117.9187, 111918),
  ('Mission Viejo', 'Orange', 'CA', 33.6000, -117.6719, 94267),
  ('Newport Beach', 'Orange', 'CA', 33.6189, -117.9289, 85239),
  ('Lake Forest', 'Orange', 'CA', 33.6469, -117.6891, 86346),
  
  -- San Bernardino County
  ('San Bernardino', 'San Bernardino', 'CA', 34.1083, -117.2898, 222101),
  ('Fontana', 'San Bernardino', 'CA', 34.0922, -117.4350, 208393),
  ('Rancho Cucamonga', 'San Bernardino', 'CA', 34.1064, -117.5931, 177751),
  ('Ontario', 'San Bernardino', 'CA', 34.0633, -117.6509, 175265),
  ('Victorville', 'San Bernardino', 'CA', 34.5362, -117.2928, 134810),
  ('Rialto', 'San Bernardino', 'CA', 34.1064, -117.3703, 103526),
  ('Hesperia', 'San Bernardino', 'CA', 34.4264, -117.3009, 99818),
  ('Chino', 'San Bernardino', 'CA', 34.0122, -117.6889, 91403),
  ('Upland', 'San Bernardino', 'CA', 34.0975, -117.6484, 79040),
  ('Redlands', 'San Bernardino', 'CA', 34.0556, -117.1825, 73168),
  
  -- Riverside County
  ('Riverside', 'Riverside', 'CA', 33.9533, -117.3961, 314998),
  ('Moreno Valley', 'Riverside', 'CA', 33.9425, -117.2297, 208634),
  ('Corona', 'Riverside', 'CA', 33.8753, -117.5664, 169868),
  ('Temecula', 'Riverside', 'CA', 33.4936, -117.1484, 110003),
  ('Murrieta', 'Riverside', 'CA', 33.5539, -117.2139, 118125),
  ('Hemet', 'Riverside', 'CA', 33.7475, -116.9719, 89833),
  ('Menifee', 'Riverside', 'CA', 33.6971, -117.1850, 102527),
  ('Indio', 'Riverside', 'CA', 33.7206, -116.2156, 89137),
  ('Perris', 'Riverside', 'CA', 33.7825, -117.2286, 77879),
  ('Palm Desert', 'Riverside', 'CA', 33.7222, -116.3744, 52124);

-- Create users for each city
DO $$
DECLARE
  city_record RECORD;
  counter INTEGER;
  user_id uuid;
  base_email text := 'socal.user';
  email_counter INTEGER := 1;
  roles text[] := ARRAY[
    'General Contractor', 'Electrician', 'Plumber', 'Carpenter', 'Mason',
    'HVAC Technician', 'Painter', 'Roofer', 'Landscaper', 'Interior Designer',
    'Architect', 'Project Manager', 'Construction Supervisor', 'Tile Installer',
    'Flooring Specialist', 'Kitchen Remodeler', 'Bathroom Remodeler',
    'Foundation Specialist', 'Pool Contractor', 'Solar Installer'
  ];
  first_names text[] := ARRAY[
    'James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph',
    'Thomas', 'Charles', 'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth',
    'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen', 'Miguel', 'Jose', 'Maria',
    'Juan', 'Carlos', 'Ana', 'Luis', 'Elena', 'Roberto', 'Rosa', 'Wei', 'Li',
    'Yong', 'Ming', 'Hui', 'Xiao', 'Jun', 'Ling', 'Hong', 'Yu'
  ];
  last_names text[] := ARRAY[
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
    'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
    'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson',
    'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Chen',
    'Yang', 'Wong', 'Liu', 'Wang', 'Kim', 'Park', 'Choi', 'Jung', 'Kang'
  ];
BEGIN
  -- For each city
  FOR city_record IN SELECT * FROM socal_cities LOOP
    -- Create 500 users per city
    FOR counter IN 1..500 LOOP
      -- Create user
      INSERT INTO users (
        email,
        name,
        image_url,
        phone
      )
      VALUES (
        base_email || email_counter || '@example.com',
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
        roles[1 + (random() * (array_length(roles, 1) - 1))::integer],
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

      email_counter := email_counter + 1;
    END LOOP;
  END LOOP;
END $$;

-- Clean up
DROP TABLE socal_cities;