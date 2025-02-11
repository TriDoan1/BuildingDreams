-- Create temporary table for Orange County cities
CREATE TEMPORARY TABLE orange_county_cities (
  city_name text PRIMARY KEY,
  latitude double precision,
  longitude double precision
);

-- Insert Orange County cities
INSERT INTO orange_county_cities (city_name, latitude, longitude) VALUES
  ('Aliso Viejo', 33.5767, -117.7256),
  ('Anaheim', 33.8366, -117.9143),
  ('Brea', 33.9167, -117.9000),
  ('Buena Park', 33.8675, -117.9981),
  ('Costa Mesa', 33.6411, -117.9187),
  ('Cypress', 33.8169, -118.0375),
  ('Dana Point', 33.4669, -117.6981),
  ('Fountain Valley', 33.7092, -117.9536),
  ('Fullerton', 33.8704, -117.9242),
  ('Garden Grove', 33.7739, -117.9414),
  ('Huntington Beach', 33.6595, -117.9988),
  ('Irvine', 33.6846, -117.8265),
  ('La Habra', 33.9319, -117.9461),
  ('La Palma', 33.8464, -118.0467),
  ('Laguna Beach', 33.5422, -117.7831),
  ('Laguna Hills', 33.5963, -117.7178),
  ('Laguna Niguel', 33.5225, -117.7075),
  ('Laguna Woods', 33.6103, -117.7289),
  ('Lake Forest', 33.6469, -117.6891),
  ('Los Alamitos', 33.8028, -118.0728),
  ('Mission Viejo', 33.6000, -117.6719),
  ('Newport Beach', 33.6189, -117.9289),
  ('Orange', 33.7879, -117.8531),
  ('Placentia', 33.8722, -117.8703),
  ('Rancho Santa Margarita', 33.6406, -117.6031),
  ('San Clemente', 33.4269, -117.6119),
  ('San Juan Capistrano', 33.5017, -117.6625),
  ('Santa Ana', 33.7455, -117.8677),
  ('Seal Beach', 33.7414, -118.1048),
  ('Stanton', 33.8025, -117.9931),
  ('Tustin', 33.7458, -117.8261),
  ('Villa Park', 33.8147, -117.8131),
  ('Westminster', 33.7514, -117.9939),
  ('Yorba Linda', 33.8886, -117.8131),
  -- Additional nearby cities to reach 50
  ('Corona Del Mar', 33.6000, -117.8731),
  ('Ladera Ranch', 33.5517, -117.6281),
  ('Coto de Caza', 33.5953, -117.5850),
  ('Foothill Ranch', 33.6847, -117.6639),
  ('Portola Hills', 33.6789, -117.6256),
  ('Turtle Rock', 33.6428, -117.8019),
  ('University Park', 33.6508, -117.8359),
  ('Woodbridge', 33.6889, -117.7989),
  ('Northwood', 33.7219, -117.7939),
  ('Orchard Hills', 33.7347, -117.7689),
  ('Crystal Cove', 33.5728, -117.8397),
  ('Balboa Island', 33.6053, -117.8931),
  ('Corona del Mar', 33.6000, -117.8731),
  ('Emerald Bay', 33.5567, -117.8097),
  ('Three Arch Bay', 33.4817, -117.7197),
  ('Monarch Beach', 33.4817, -117.7197);

-- Create 50 unique projects
DO $$
DECLARE
  prof_record RECORD;
  city_record RECORD;
  project_titles text[] := ARRAY[
    'Modern Coastal Home Renovation',
    'Luxury Kitchen Remodel',
    'Custom Pool & Landscape Design',
    'Master Suite Addition',
    'Smart Home Integration',
    'Outdoor Living Space',
    'Contemporary Bathroom Remodel',
    'Home Theater Installation',
    'Energy-Efficient Upgrade',
    'Custom Wine Cellar'
  ];
  project_descriptions text[] := ARRAY[
    'Complete renovation featuring open floor plan, high-end finishes, and ocean views. Includes custom millwork and smart home integration.',
    'Gourmet kitchen renovation with professional appliances, custom cabinetry, and luxury finishes. Features large island and butler''s pantry.',
    'Resort-style pool area with infinity edge, custom landscaping, and outdoor kitchen. Includes lighting and entertainment systems.',
    'Luxurious master suite addition with spa-like bathroom, walk-in closet, and private balcony. Features premium materials and finishes.',
    'Comprehensive smart home system with automated lighting, climate control, security, and entertainment. Includes voice control integration.',
    'Custom outdoor living space with covered patio, fireplace, and kitchen. Perfect for year-round entertaining.',
    'Spa-inspired bathroom renovation with freestanding tub, walk-in shower, and heated floors. Features custom vanity and lighting.',
    'Professional home theater with premium audio/video equipment, custom seating, and acoustic treatments.',
    'Energy efficiency upgrade featuring solar panels, new HVAC, and smart energy management system.',
    'Temperature-controlled wine cellar with custom racking, tasting area, and specialty lighting.'
  ];
  image_urls text[] := ARRAY[
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1600607687644-aac4c3eac7f4?auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&q=80'
  ];
BEGIN
  -- For each city
  FOR city_record IN SELECT * FROM orange_county_cities LOOP
    -- Get a random professional
    SELECT user_id INTO prof_record
    FROM professionals
    WHERE location LIKE '%CA'
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
      (random() * 200)::int,
      (random() * 500000 + 50000)::int,
      city_record.city_name || ', CA',
      city_record.latitude + (random() - 0.5) * 0.01,
      city_record.longitude + (random() - 0.5) * 0.01
    );
  END LOOP;
END $$;

-- Clean up
DROP TABLE orange_county_cities;