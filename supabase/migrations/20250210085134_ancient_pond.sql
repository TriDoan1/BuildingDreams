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

-- Create 50 projects
DO $$
DECLARE
  prof_record RECORD;
  city_record RECORD;
  total_weight integer;
  random_threshold integer;
  project_title text;
  project_description text;
  project_image text;
  project_budget integer;
BEGIN
  -- Get total population weight
  SELECT SUM(population) INTO total_weight FROM socal_cities;

  -- Create 50 projects
  FOR counter IN 1..50 LOOP
    -- Get a random interior designer or general contractor
    SELECT user_id INTO prof_record
    FROM professionals
    WHERE role IN ('Interior Design', 'General Contracting')
    ORDER BY random()
    LIMIT 1;

    -- Select random city weighted by population
    random_threshold := (random() * total_weight)::integer;
    
    SELECT * INTO city_record
    FROM socal_cities
    WHERE cumulative_weight > random_threshold
    ORDER BY cumulative_weight
    LIMIT 1;

    -- Generate project details
    project_title := CASE (random() * 9)::int
      WHEN 0 THEN 'Modern Coastal Villa Renovation'
      WHEN 1 THEN 'Luxury Kitchen & Bath Remodel'
      WHEN 2 THEN 'Custom Home Theater Design'
      WHEN 3 THEN 'Master Suite Addition'
      WHEN 4 THEN 'Smart Home Integration Project'
      WHEN 5 THEN 'Outdoor Living Space Design'
      WHEN 6 THEN 'Contemporary Home Office'
      WHEN 7 THEN 'Wine Cellar & Tasting Room'
      WHEN 8 THEN 'Spa-Inspired Bathroom Retreat'
      ELSE 'Gourmet Kitchen Transformation'
    END;

    project_description := CASE (random() * 9)::int
      WHEN 0 THEN 'Complete renovation featuring panoramic ocean views, custom millwork, and high-end finishes throughout.'
      WHEN 1 THEN 'Comprehensive kitchen and bath remodel with premium appliances and luxury fixtures.'
      WHEN 2 THEN 'Professional home theater with state-of-the-art audio/video equipment and custom seating.'
      WHEN 3 THEN 'Luxurious master suite addition with walk-in closet, private balcony, and spa bathroom.'
      WHEN 4 THEN 'Full smart home integration with automated lighting, climate control, and security systems.'
      WHEN 5 THEN 'Custom outdoor living space with covered patio, outdoor kitchen, and fire features.'
      WHEN 6 THEN 'Modern home office with built-in storage, ergonomic workspace, and video conferencing setup.'
      WHEN 7 THEN 'Custom wine cellar with temperature control, display lighting, and tasting area.'
      WHEN 8 THEN 'Luxury bathroom renovation with steam shower, freestanding tub, and heated floors.'
      ELSE 'Complete kitchen transformation with professional-grade appliances and custom features.'
    END;

    project_image := 'https://images.unsplash.com/photo-' || (
      CASE (counter % 5)
        WHEN 0 THEN '1600585154526-990dced4db0d'
        WHEN 1 THEN '1600607687939-ce8a6c25118c'
        WHEN 2 THEN '1600607687644-aac4c3eac7f4'
        WHEN 3 THEN '1600566753376-12c8ab7fb75b'
        ELSE '1600585154340-be6161a56a0c'
      END
    ) || '?auto=format&fit=crop&q=80';

    project_budget := 5000 + (random() * 495000)::int;

    -- Create project
    INSERT INTO projects (
      title,
      description,
      image_url,
      professional_id,
      likes,
      budget,
      location,
      latitude,
      longitude
    )
    VALUES (
      project_title || ' in ' || city_record.city_name,
      project_description,
      project_image,
      prof_record.user_id,
      (random() * 200)::int,
      project_budget,
      city_record.city_name || ', ' || city_record.state_code,
      city_record.latitude + (random() - 0.5) * 0.01,
      city_record.longitude + (random() - 0.5) * 0.01
    );
  END LOOP;
END $$;

-- Clean up
DROP TABLE socal_cities;