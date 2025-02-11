-- Update project images with verified Unsplash photos
DO $$
DECLARE
  project_record RECORD;
  counter INTEGER := 0;
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
    'photo-1600573472592-401b489a3cdc'   -- Office design
  ];
BEGIN
  -- Update each project with a verified image
  FOR project_record IN SELECT * FROM projects LOOP
    counter := counter + 1;
    
    UPDATE projects 
    SET image_url = 'https://images.unsplash.com/' || 
      project_images[1 + (counter % array_length(project_images, 1))] ||
      '?auto=format&fit=crop&q=80&w=1200'
    WHERE id = project_record.id;
  END LOOP;
END $$;