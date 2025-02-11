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
  -- Orange County (10 major cities)
  ('Irvine', 'Orange', 'CA', 33.6846, -117.8265, 307670),
  ('Newport Beach', 'Orange', 'CA', 33.6189, -117.9289, 85239),
  ('Laguna Beach', 'Orange', 'CA', 33.5422, -117.7831, 22343),
  ('Costa Mesa', 'Orange', 'CA', 33.6411, -117.9187, 111918),
  ('Huntington Beach', 'Orange', 'CA', 33.6595, -117.9988, 198711),
  ('Dana Point', 'Orange', 'CA', 33.4669, -117.6981, 33107),
  ('San Clemente', 'Orange', 'CA', 33.4269, -117.6119, 64581),
  ('Laguna Niguel', 'Orange', 'CA', 33.5225, -117.7075, 65316),
  ('Mission Viejo', 'Orange', 'CA', 33.6000, -117.6719, 94267),
  ('Aliso Viejo', 'Orange', 'CA', 33.5767, -117.7256, 50044);

-- Calculate cumulative weights for distribution
UPDATE socal_cities sc1
SET cumulative_weight = (
  SELECT SUM(sc2.population)
  FROM socal_cities sc2
  WHERE sc2.city_name <= sc1.city_name
);

-- Create projects with verified Unsplash photos
DO $$
DECLARE
  project_images text[] := ARRAY[
    'photo-1600596542815-ffad4c1539a9',  -- Modern luxury home
    'photo-1600210492493-0946911123ea',  -- Kitchen renovation
    'photo-1600607687939-ce8a6c25118c',  -- Bathroom design
    'photo-1600585154340-be6161a56a0c',  -- Living room
    'photo-1600047509807-ba8f99d2cdde',  -- Home exterior
    'photo-1600566753190-17f0baa2a6c3',  -- Pool and landscape
    'photo-1600607687644-aac4c3eac7f4',  -- Master bedroom
    'photo-1600573472592-401b489a3cdc',  -- Office space
    'photo-1600585154526-990dced4db0d',  -- Modern architecture
    'photo-1600596542815-ffad4c1539a9'   -- Luxury interior
  ];
  city_record RECORD;
  prof_record RECORD;
  counter INTEGER;
BEGIN
  -- Create 50 projects
  FOR counter IN 1..50 LOOP
    -- Get a random architect, designer, or contractor
    SELECT p.id, p.role INTO prof_record
    FROM professionals p
    WHERE p.role IN ('Architect', 'Interior Designer', 'General Contractor')
    ORDER BY random()
    LIMIT 1;

    -- Get a random city
    SELECT * INTO city_record
    FROM socal_cities
    ORDER BY random()
    LIMIT 1;

    -- Create project
    INSERT INTO projects (
      title,
      description,
      image_url,
      professional_id,
      likes,
      budget,
      location
    )
    VALUES (
      CASE (random() * 9)::int
        WHEN 0 THEN 'Modern Home Renovation'
        WHEN 1 THEN 'Custom Kitchen Remodel'
        WHEN 2 THEN 'Luxury Bathroom Upgrade'
        WHEN 3 THEN 'Smart Home Integration'
        WHEN 4 THEN 'Outdoor Living Space'
        WHEN 5 THEN 'Master Suite Addition'
        WHEN 6 THEN 'Home Theater Design'
        WHEN 7 THEN 'Pool & Landscape Project'
        WHEN 8 THEN 'Office Space Conversion'
        ELSE 'Energy Efficiency Upgrade'
      END || ' in ' || city_record.city_name,
      'Professional ' || prof_record.role || ' project in ' || city_record.city_name || ' featuring custom design and premium materials.',
      'https://images.unsplash.com/' || project_images[1 + (counter % array_length(project_images, 1))] || '?auto=format&fit=crop&q=80&w=1200',
      prof_record.id,
      (random() * 200)::int,
      50000 + (random() * 450000)::int,
      city_record.city_name || ', ' || city_record.state_code
    );
  END LOOP;
END $$;

-- Clean up
DROP TABLE socal_cities;