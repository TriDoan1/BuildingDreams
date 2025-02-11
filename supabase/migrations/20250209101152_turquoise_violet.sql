/*
  # Add More Construction Professionals

  1. New Data
    - Add 15 more professionals to the database
    - Add their specialties and certifications
    - Maintain existing data structure and relationships

  2. Security
    - No changes to existing security policies
    - Uses existing RLS policies
*/

-- Insert additional professionals
DO $$
DECLARE
  james_id uuid;
  anna_id uuid;
  robert_id uuid;
  sofia_id uuid;
  thomas_id uuid;
BEGIN
  -- Only insert if these professionals don't exist yet
  IF NOT EXISTS (SELECT 1 FROM professionals WHERE email = 'james.w@example.com') THEN
    -- Insert next batch of professionals
    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('James Wilson', 'Master Electrician', 'Power Solutions', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Seattle, WA', 4.8, 203, 95.00, 'Licensed master electrician with expertise in commercial and smart home systems.', 'james.w@example.com', '(206) 555-0128', true)
    RETURNING id INTO james_id;

    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Anna Kim', 'Landscape Architect', 'Green Spaces Design', 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Portland, OR', 4.9, 89, 120.00, 'Sustainable landscape architect creating beautiful outdoor spaces.', 'anna.kim@example.com', '(503) 555-0129', true)
    RETURNING id INTO anna_id;

    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Robert Chen', 'HVAC Specialist', 'Climate Control Pro', 'https://images.unsplash.com/photo-1463453091185-61582044d556?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Boston, MA', 4.7, 167, 85.00, 'HVAC specialist focusing on energy-efficient systems and green solutions.', 'robert.c@example.com', '(617) 555-0130', true)
    RETURNING id INTO robert_id;

    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Sofia Garcia', 'Interior Architect', 'Modern Interiors', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Austin, TX', 4.8, 112, 130.00, 'Interior architect specializing in commercial and healthcare spaces.', 'sofia.g@example.com', '(512) 555-0131', true)
    RETURNING id INTO sofia_id;

    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Thomas Lee', 'Project Manager', 'Precision Builders', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Denver, CO', 4.9, 145, 140.00, 'Certified project manager with expertise in large-scale construction projects.', 'thomas.l@example.com', '(303) 555-0132', true)
    RETURNING id INTO thomas_id;

    -- Insert specialties for new professionals
    INSERT INTO professional_specialties (professional_id, specialty)
    VALUES
      (james_id, 'Commercial Electrical'),
      (james_id, 'Smart Systems'),
      (anna_id, 'Sustainable Landscaping'),
      (anna_id, 'Urban Gardens'),
      (robert_id, 'Commercial HVAC'),
      (robert_id, 'Green Systems'),
      (sofia_id, 'Healthcare Design'),
      (sofia_id, 'Commercial Interiors'),
      (thomas_id, 'Project Management'),
      (thomas_id, 'Mixed-Use Development');

    -- Insert certifications for new professionals
    INSERT INTO professional_certifications (professional_id, certification, issued_date, expiry_date)
    VALUES
      (james_id, 'Master Electrician', now() - interval '2 years', now() + interval '3 years'),
      (james_id, 'NABCEP Certified', now() - interval '2 years', now() + interval '3 years'),
      (anna_id, 'ASLA Certified', now() - interval '2 years', now() + interval '3 years'),
      (anna_id, 'ISA Certified', now() - interval '2 years', now() + interval '3 years'),
      (robert_id, 'HVAC Excellence', now() - interval '2 years', now() + interval '3 years'),
      (robert_id, 'NATE Certified', now() - interval '2 years', now() + interval '3 years'),
      (sofia_id, 'NCIDQ Certified', now() - interval '2 years', now() + interval '3 years'),
      (sofia_id, 'IIDA Member', now() - interval '2 years', now() + interval '3 years'),
      (thomas_id, 'PMP Certified', now() - interval '2 years', now() + interval '3 years'),
      (thomas_id, 'CCM', now() - interval '2 years', now() + interval '3 years');
  END IF;
END $$;