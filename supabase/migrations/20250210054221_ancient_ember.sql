/*
  # Update projects with unique data and locations

  1. Schema Changes
    - Add budget column (numeric)
    - Add location columns (text, lat, lng)
    
  2. Data Updates
    - Assign unique titles and descriptions
    - Set budgets between $10,000 and $50,000
    - Assign Orange County locations
    - Link to architects/designers
*/

-- First add the new columns
ALTER TABLE projects
ADD COLUMN IF NOT EXISTS budget numeric(10,2),
ADD COLUMN IF NOT EXISTS location text,
ADD COLUMN IF NOT EXISTS latitude double precision,
ADD COLUMN IF NOT EXISTS longitude double precision;

-- Then update the data
DO $$
DECLARE
  prof_id uuid;
  project_record RECORD;
BEGIN
  -- Create temporary table for Orange County cities
  CREATE TEMPORARY TABLE orange_county_cities (
    city_name text,
    latitude double precision,
    longitude double precision
  );

  -- Insert Orange County cities
  INSERT INTO orange_county_cities (city_name, latitude, longitude) VALUES
    ('Irvine', 33.6846, -117.8265),
    ('Newport Beach', 33.6189, -117.9289),
    ('Laguna Beach', 33.5422, -117.7831),
    ('Costa Mesa', 33.6411, -117.9187),
    ('Huntington Beach', 33.6595, -117.9988),
    ('Dana Point', 33.4669, -117.6981),
    ('San Clemente', 33.4269, -117.6119),
    ('Laguna Niguel', 33.5225, -117.7075),
    ('Mission Viejo', 33.6000, -117.6719),
    ('Aliso Viejo', 33.5767, -117.7256);

  -- Update existing projects with unique data
  FOR project_record IN SELECT * FROM projects LOOP
    -- Get a random architect or designer
    SELECT id INTO prof_id
    FROM professionals
    WHERE 
      (role LIKE '%Architect%' OR role LIKE '%Designer%')
      AND location LIKE '%, CA'
    ORDER BY random()
    LIMIT 1;

    -- Select a random Orange County city
    WITH random_city AS (
      SELECT 
        city_name,
        latitude + (random() - 0.5) * 0.01 as rand_lat,
        longitude + (random() - 0.5) * 0.01 as rand_lng
      FROM orange_county_cities
      ORDER BY random()
      LIMIT 1
    )
    UPDATE projects
    SET
      title = CASE (random() * 19)::int
        WHEN 0 THEN 'Modern Coastal Villa Renovation'
        WHEN 1 THEN 'Sustainable Smart Home Design'
        WHEN 2 THEN 'Mediterranean Estate Remodel'
        WHEN 3 THEN 'Contemporary Beach House Transformation'
        WHEN 4 THEN 'Luxury Kitchen & Bath Upgrade'
        WHEN 5 THEN 'Open Concept Living Space Design'
        WHEN 6 THEN 'Indoor-Outdoor Entertainment Area'
        WHEN 7 THEN 'Master Suite Addition & Renovation'
        WHEN 8 THEN 'Custom Home Office & Library'
        WHEN 9 THEN 'Minimalist Modern Home Design'
        WHEN 10 THEN 'California Room & Patio Extension'
        WHEN 11 THEN 'Eco-Friendly Home Modernization'
        WHEN 12 THEN 'Resort-Style Pool & Landscape'
        WHEN 13 THEN 'Gourmet Kitchen Transformation'
        WHEN 14 THEN 'Luxury Bathroom Spa Retreat'
        WHEN 15 THEN 'Smart Home Integration Project'
        WHEN 16 THEN 'Custom Wine Cellar & Tasting Room'
        WHEN 17 THEN 'Home Theater & Media Room'
        WHEN 18 THEN 'Artist Studio & Gallery Space'
        ELSE 'Zen Garden & Meditation Space'
      END,
      description = CASE (random() * 19)::int
        WHEN 0 THEN 'Complete renovation of a coastal villa featuring panoramic ocean views, custom millwork, and high-end finishes throughout. Project includes a gourmet kitchen, spa-like bathrooms, and an infinity pool.'
        WHEN 1 THEN 'Modern smart home design incorporating solar power, energy management systems, and sustainable materials. Features include automated lighting, climate control, and water conservation systems.'
        WHEN 2 THEN 'Extensive remodel of a Mediterranean estate with authentic architectural details, hand-painted tiles, and wrought iron accents. Includes courtyard renovation and outdoor kitchen.'
        WHEN 3 THEN 'Contemporary transformation of a beachfront property with floor-to-ceiling windows, custom built-ins, and a rooftop deck. Emphasis on durability and ocean views.'
        WHEN 4 THEN 'Luxury kitchen and bath renovation featuring marble countertops, custom cabinetry, and professional-grade appliances. Includes steam shower and freestanding soaking tub.'
        WHEN 5 THEN 'Creation of an open concept living space by removing walls and adding structural support. Includes new flooring, lighting, and built-in entertainment center.'
        WHEN 6 THEN 'Design and construction of a seamless indoor-outdoor living space with folding glass walls, outdoor fireplace, and custom lighting. Perfect for entertaining.'
        WHEN 7 THEN 'Addition of a luxury master suite with walk-in closet, private balcony, and spa-like bathroom. Includes custom millwork and premium finishes.'
        WHEN 8 THEN 'Custom home office and library design featuring built-in bookshelves, coffered ceiling, and sound-dampening materials. Includes custom lighting and furniture.'
        WHEN 9 THEN 'Minimalist modern home design emphasizing clean lines, natural light, and open spaces. Includes custom storage solutions and high-end materials.'
        WHEN 10 THEN 'Addition of a California room with retractable glass walls, outdoor kitchen, and custom lighting. Perfect for year-round indoor-outdoor living.'
        WHEN 11 THEN 'Eco-friendly home modernization featuring solar panels, energy-efficient systems, and sustainable materials. Includes smart home technology integration.'
        WHEN 12 THEN 'Creation of a resort-style pool area with infinity edge, custom landscaping, and outdoor living spaces. Includes lighting and sound system.'
        WHEN 13 THEN 'Complete kitchen transformation with professional-grade appliances, custom cabinetry, and luxury finishes. Includes butler''s pantry and wine storage.'
        WHEN 14 THEN 'Luxury bathroom renovation featuring steam shower, freestanding tub, and heated floors. Includes custom vanity and lighting design.'
        WHEN 15 THEN 'Comprehensive smart home integration project including automated lighting, climate control, security, and entertainment systems.'
        WHEN 16 THEN 'Custom wine cellar and tasting room design featuring temperature control, custom racking, and tasting area. Includes specialty lighting.'
        WHEN 17 THEN 'Professional home theater and media room with acoustic treatments, premium audio/video equipment, and custom seating.'
        WHEN 18 THEN 'Custom artist studio and gallery space with optimal lighting, storage solutions, and display areas. Includes climate control for artwork.'
        ELSE 'Tranquil zen garden and meditation space featuring water features, custom landscaping, and peaceful sitting areas. Includes lighting and sound system.'
      END,
      professional_id = prof_id,
      budget = 10000 + (random() * 40000)::int * 100,
      location = (SELECT city_name FROM random_city),
      latitude = (SELECT rand_lat FROM random_city),
      longitude = (SELECT rand_lng FROM random_city),
      updated_at = now()
    WHERE id = project_record.id;
  END LOOP;

  -- Clean up
  DROP TABLE orange_county_cities;
END $$;