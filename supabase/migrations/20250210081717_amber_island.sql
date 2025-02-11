/*
  # Populate Database with Sample Data

  1. Companies
    - Create 100 companies
    - Set 1/3 as hiring
    - Distribute across SoCal cities

  2. Users & Professionals
    - Create 500 professional users
    - Link to companies
    - Add specialties and certifications
*/

DO $$
DECLARE
  company_id uuid;
  user_id uuid;
  city_record RECORD;
  company_name text;
  company_suffix text;
  base_email text := 'user';
  counter int := 1;
  total_weight int;
  random_threshold float;
BEGIN
  -- Create temporary table for SoCal cities
  CREATE TEMPORARY TABLE socal_cities (
    city_name text,
    state_code text,
    weight int,
    cumulative_weight int DEFAULT 0
  );

  -- Insert major SoCal cities with weights
  INSERT INTO socal_cities (city_name, state_code, weight) VALUES
    ('Los Angeles', 'CA', 25),
    ('San Diego', 'CA', 20),
    ('Irvine', 'CA', 10),
    ('Santa Ana', 'CA', 8),
    ('Anaheim', 'CA', 8),
    ('Riverside', 'CA', 7),
    ('San Bernardino', 'CA', 5),
    ('Santa Barbara', 'CA', 5),
    ('Ventura', 'CA', 4),
    ('Long Beach', 'CA', 8);

  -- Calculate cumulative weights
  SELECT SUM(weight) INTO total_weight FROM socal_cities;
  
  UPDATE socal_cities sc1
  SET cumulative_weight = (
    SELECT SUM(sc2.weight)
    FROM socal_cities sc2
    WHERE sc2.city_name <= sc1.city_name
  );

  -- Create 100 companies
  FOR counter IN 1..100 LOOP
    -- Select random city using cumulative weights
    random_threshold := random() * total_weight;
    
    SELECT city_name, state_code INTO STRICT city_record
    FROM socal_cities
    WHERE cumulative_weight > random_threshold
    ORDER BY cumulative_weight
    LIMIT 1;

    -- Generate company name
    SELECT 
      CASE (random() * 4)::int
        WHEN 0 THEN 'Pacific'
        WHEN 1 THEN 'SoCal'
        WHEN 2 THEN 'Golden State'
        ELSE 'Coastal'
      END || ' ' ||
      CASE (random() * 4)::int
        WHEN 0 THEN 'Construction'
        WHEN 1 THEN 'Builders'
        WHEN 2 THEN 'Development'
        ELSE 'Contractors'
      END || ' ' ||
      counter::text
    INTO company_name;

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
      'Professional ' || company_name || ' serving ' || city_record.city_name || ' and surrounding areas.',
      city_record.city_name || ', ' || city_record.state_code,
      'https://www.' || lower(regexp_replace(company_name, ' ', '')) || '.example.com',
      random() < 0.33  -- Make 1/3 of companies hiring
    )
    RETURNING id INTO company_id;
  END LOOP;

  -- Create 500 professional users
  FOR counter IN 1..500 LOOP
    -- Select random city using cumulative weights
    random_threshold := random() * total_weight;
    
    SELECT city_name, state_code INTO STRICT city_record
    FROM socal_cities
    WHERE cumulative_weight > random_threshold
    ORDER BY cumulative_weight
    LIMIT 1;

    -- Create user
    INSERT INTO users (
      email,
      name,
      image_url,
      phone,
      user_type
    )
    VALUES (
      base_email || counter || '@example.com',
      CASE (random() * 9)::int
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
      '(555) ' || LPAD((random() * 999)::int::text, 3, '0') || '-' || LPAD((random() * 9999)::int::text, 4, '0'),
      'professional'
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
      (SELECT id FROM companies ORDER BY random() LIMIT 1),
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

  -- Clean up
  DROP TABLE socal_cities;
END $$;