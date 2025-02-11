/*
  # Add Southern California Professionals

  1. New Data
    - Adds 500 professionals across Southern California cities
    - Includes diverse roles and specialties
    - Maintains realistic data distribution

  2. Cities Coverage
    - Los Angeles
    - San Diego
    - Orange County cities
    - Inland Empire
    - Santa Barbara
    - Ventura County
*/

DO $$
DECLARE
  prof_id uuid;
  selected_city record;
  selected_name record;
  selected_role record;
  selected_company record;
  company_suffix text;
  base_email text := 'socal.professional';
  counter int := 1;
BEGIN
  -- Create temporary tables for data
  CREATE TEMPORARY TABLE IF NOT EXISTS temp_names (
    first_name text,
    last_name text
  );

  CREATE TEMPORARY TABLE IF NOT EXISTS temp_roles (
    role_name text
  );

  CREATE TEMPORARY TABLE IF NOT EXISTS temp_companies (
    company_prefix text
  );

  CREATE TEMPORARY TABLE IF NOT EXISTS temp_cities (
    city text,
    state text,
    weight int
  );

  -- Insert data into temporary tables
  INSERT INTO temp_names (first_name, last_name) VALUES
    ('James', 'Smith'), ('Maria', 'Johnson'), ('David', 'Williams'),
    ('Lisa', 'Brown'), ('Michael', 'Jones'), ('Jennifer', 'Garcia'),
    ('Robert', 'Miller'), ('Linda', 'Davis'), ('William', 'Rodriguez'),
    ('Elizabeth', 'Martinez'), ('Richard', 'Hernandez'), ('Barbara', 'Lopez'),
    ('Joseph', 'Gonzalez'), ('Susan', 'Wilson'), ('Thomas', 'Anderson'),
    ('Jessica', 'Thomas'), ('Charles', 'Taylor'), ('Sarah', 'Moore'),
    ('Christopher', 'Jackson'), ('Karen', 'Martin'), ('Daniel', 'Lee'),
    ('Nancy', 'Perez'), ('Matthew', 'Thompson'), ('Margaret', 'White'),
    ('Anthony', 'Harris'), ('Sandra', 'Sanchez'), ('Mark', 'Clark'),
    ('Ashley', 'Ramirez'), ('Donald', 'Lewis'), ('Kimberly', 'Robinson'),
    ('Steven', 'Walker'), ('Emily', 'Young'), ('Paul', 'Allen'),
    ('Donna', 'King'), ('Andrew', 'Wright'), ('Michelle', 'Scott'),
    ('Joshua', 'Torres'), ('Carol', 'Nguyen'), ('Kenneth', 'Hill'),
    ('Amanda', 'Flores'), ('Kevin', 'Green'), ('Dorothy', 'Adams'),
    ('Brian', 'Nelson'), ('Melissa', 'Baker'), ('George', 'Hall'),
    ('Deborah', 'Rivera'), ('Edward', 'Campbell'), ('Stephanie', 'Mitchell'),
    ('Ronald', 'Carter'), ('Rebecca', 'Roberts');

  INSERT INTO temp_roles (role_name) VALUES
    ('General Contractor'), ('Electrician'), ('Plumber'), ('Carpenter'),
    ('Mason'), ('HVAC Technician'), ('Painter'), ('Roofer'), ('Landscaper'),
    ('Interior Designer'), ('Architect'), ('Project Manager'),
    ('Construction Supervisor'), ('Tile Installer'), ('Flooring Specialist'),
    ('Kitchen Remodeler'), ('Bathroom Remodeler'), ('Foundation Specialist'),
    ('Pool Contractor'), ('Solar Installer'), ('Security System Installer'),
    ('Home Inspector'), ('Structural Engineer'), ('Cabinet Maker'),
    ('Custom Furniture Maker'), ('Concrete Specialist'), ('Drywall Contractor'),
    ('Fence Installer'), ('Glass and Mirror Installer'), ('Home Automation Specialist');

  INSERT INTO temp_companies (company_prefix) VALUES
    ('Pacific'), ('Golden State'), ('Coastal'), ('SoCal'), ('Sunset'),
    ('California'), ('West Coast'), ('Orange County'), ('San Diego'),
    ('LA Metro'), ('Imperial'), ('Mission'), ('Harbor'), ('Beach Cities'),
    ('Valley'), ('Desert'), ('Mountain'), ('Southern'), ('Inland'), ('Metro');

  INSERT INTO temp_cities (city, state, weight) VALUES
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

  -- Generate 500 professionals
  FOR counter IN 1..500 LOOP
    -- Select random data from temporary tables
    SELECT city, state INTO selected_city 
    FROM temp_cities 
    WHERE random() < (weight::float / 100)
    LIMIT 1;

    -- Fallback to Los Angeles if no city selected
    IF selected_city.city IS NULL THEN
      selected_city.city := 'Los Angeles';
      selected_city.state := 'CA';
    END IF;

    -- Select random name components
    SELECT first_name, last_name INTO selected_name
    FROM temp_names
    OFFSET floor(random() * (SELECT COUNT(*) FROM temp_names))
    LIMIT 1;

    -- Select random role
    SELECT role_name INTO selected_role
    FROM temp_roles
    OFFSET floor(random() * (SELECT COUNT(*) FROM temp_roles))
    LIMIT 1;

    -- Select random company prefix
    SELECT company_prefix INTO selected_company
    FROM temp_companies
    OFFSET floor(random() * (SELECT COUNT(*) FROM temp_companies))
    LIMIT 1;

    -- Generate company suffix
    company_suffix := CASE (floor(random() * 5))::int
      WHEN 0 THEN 'Construction'
      WHEN 1 THEN 'Contractors'
      WHEN 2 THEN 'Services'
      WHEN 3 THEN 'Solutions'
      ELSE 'Builders'
    END;

    -- Insert professional
    INSERT INTO professionals (
      name,
      role,
      company,
      image_url,
      location,
      rating,
      projects_completed,
      hourly_rate,
      bio,
      email,
      phone,
      verified
    )
    VALUES (
      selected_name.first_name || ' ' || selected_name.last_name,
      selected_role.role_name,
      selected_company.company_prefix || ' ' || company_suffix,
      'https://images.unsplash.com/photo-' || (
        CASE (counter % 5)
          WHEN 0 THEN '1500648767791-00dcc994a43e'
          WHEN 1 THEN '1494790108377-be9c29b29330'
          WHEN 2 THEN '1472099645785-5658abf4ff4e'
          WHEN 3 THEN '1534528741775-53994a69daeb'
          WHEN 4 THEN '1507003211169-0a1dd7228f2d'
        END
      ) || '?auto=format&fit=facearea&facepad=2&w=256&h=256',
      selected_city.city || ', ' || selected_city.state,
      4.0 + (random() * 1.0),
      25 + (random() * 200)::int,
      75 + (random() * 150)::int,
      'Experienced ' || selected_role.role_name || ' serving ' || selected_city.city || ' and surrounding areas. Specializing in residential and commercial projects.',
      base_email || counter || '@example.com',
      '(555) ' || LPAD((random() * 999)::int::text, 3, '0') || '-' || LPAD((random() * 9999)::int::text, 4, '0'),
      random() < 0.8
    )
    RETURNING id INTO prof_id;

    -- Add specialties
    INSERT INTO professional_specialties (professional_id, specialty)
    SELECT prof_id, specialty
    FROM (
      SELECT unnest(ARRAY[
        CASE selected_role.role_name
          WHEN 'General Contractor' THEN 'Residential Construction'
          WHEN 'Electrician' THEN 'Electrical Systems'
          WHEN 'Plumber' THEN 'Plumbing Systems'
          WHEN 'Carpenter' THEN 'Custom Woodwork'
          WHEN 'Mason' THEN 'Masonry'
          ELSE 'General Construction'
        END,
        CASE selected_role.role_name
          WHEN 'General Contractor' THEN 'Project Management'
          WHEN 'Electrician' THEN 'Smart Home Integration'
          WHEN 'Plumber' THEN 'Water Systems'
          WHEN 'Carpenter' THEN 'Finish Carpentry'
          WHEN 'Mason' THEN 'Stone Work'
          ELSE 'Renovation'
        END
      ]) as specialty
    ) s;

    -- Add certifications
    INSERT INTO professional_certifications (
      professional_id,
      certification,
      issued_date,
      expiry_date
    )
    SELECT
      prof_id,
      cert,
      now() - (random() * interval '5 years'),
      now() + (random() * interval '5 years')
    FROM (
      SELECT unnest(ARRAY[
        CASE selected_role.role_name
          WHEN 'General Contractor' THEN 'Licensed Contractor'
          WHEN 'Electrician' THEN 'Master Electrician'
          WHEN 'Plumber' THEN 'Master Plumber'
          WHEN 'HVAC Technician' THEN 'HVAC Certified'
          ELSE 'Trade Professional'
        END,
        'OSHA Safety Certified'
      ]) as cert
    ) c;

  END LOOP;

  -- Clean up temporary tables
  DROP TABLE temp_names;
  DROP TABLE temp_roles;
  DROP TABLE temp_companies;
  DROP TABLE temp_cities;
END $$;