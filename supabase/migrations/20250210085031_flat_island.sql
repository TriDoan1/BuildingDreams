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

-- Create 50 projects
DO $$
DECLARE
  prof_record RECORD;
  city_record RECORD;
  project_titles text[] := ARRAY[
    'Modern Coastal Villa Renovation',
    'Luxury Kitchen & Bath Remodel',
    'Custom Home Theater Design',
    'Master Suite Addition',
    'Smart Home Integration Project',
    'Outdoor Living Space Design',
    'Contemporary Home Office',
    'Wine Cellar & Tasting Room',
    'Spa-Inspired Bathroom Retreat',
    'Gourmet Kitchen Transformation'
  ];
  project_descriptions text[] := ARRAY[
    'Complete renovation of a coastal villa featuring panoramic ocean views, custom millwork, and high-end finishes throughout. Project includes a gourmet kitchen, spa-like bathrooms, and an infinity pool.',
    'Comprehensive kitchen and bath remodel featuring premium appliances, custom cabinetry, marble countertops, and luxury fixtures. Includes butler''s pantry and freestanding soaking tub.',
    'Professional home theater installation with state-of-the-art audio/video equipment, custom seating, and acoustic treatments. Includes smart lighting and sound isolation.',
    'Luxurious master suite addition with walk-in closet, private balcony, and spa bathroom. Features custom built-ins, premium finishes, and automated systems.',
    'Full smart home integration with automated lighting, climate control, security, and entertainment systems. Includes voice control and energy management.',
    'Custom outdoor living space with covered patio, outdoor kitchen, and fire features. Includes landscape lighting, audio system, and pool area.',
    'Modern home office design with built-in storage, ergonomic workspace, and video conferencing setup. Features sound dampening and natural light optimization.',
    'Custom wine cellar with temperature control, display lighting, and tasting area. Includes racking systems and climate monitoring.',
    'Luxury bathroom renovation featuring steam shower, freestanding tub, and heated floors. Includes custom vanity and specialty lighting.',
    'Complete kitchen transformation with professional-grade appliances, custom island, and high-end finishes. Features smart appliances and designer lighting.'
  ];
  image_urls text[] := ARRAY[
    'https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1600607687644-aac4c3eac7f4?auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&q=80'
  ];
BEGIN
  -- Create 50 projects
  FOR counter IN 1..50 LOOP
    -- Get a random interior designer or general contractor
    SELECT user_id INTO prof_record
    FROM professionals
    WHERE role IN ('Interior Design', 'General Contracting')
    AND location LIKE '%CA'
    ORDER BY random()
    LIMIT 1;

    -- Get a random city
    SELECT * INTO city_record
    FROM orange_county_cities
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
      location,
      latitude,
      longitude
    )
    VALUES (
      project_titles[1 + (random() * 9)::int] || ' in ' || city_record.city_name,
      project_descriptions[1 + (random() * 9)::int],
      image_urls[1 + (random() * 4)::int],
      prof_record.user_id,
      (random() * 200)::int,  -- Random number of likes
      5000 + (random() * 495000)::int,  -- Random budget between 5000 and 500000
      city_record.city_name || ', CA',
      city_record.latitude + (random() - 0.5) * 0.01,  -- Add small random offset
      city_record.longitude + (random() - 0.5) * 0.01  -- Add small random offset
    );
  END LOOP;
END $$;

-- Clean up
DROP TABLE orange_county_cities;