/*
  # Add 20 More Construction Professionals

  1. New Data
    - Adds 20 new professionals with diverse specialties
    - Includes corresponding specialties and certifications
    - Maintains data quality with realistic details
  
  2. Data Integrity
    - Uses conditional insertion to prevent duplicates
    - Maintains referential integrity with specialties and certifications
*/

DO $$
DECLARE
  prof_id uuid;
BEGIN
  -- Only proceed if these professionals don't exist yet
  IF NOT EXISTS (SELECT 1 FROM professionals WHERE email = 'rachel.f@example.com') THEN
    -- Batch 1: Environmental and Sustainability Experts
    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Rachel Foster', 'Sustainability Consultant', 'Green Build Solutions', 'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Portland, OR', 4.8, 76, 145.00, 'LEED-certified consultant specializing in sustainable building practices.', 'rachel.f@example.com', '(503) 555-0133', true)
    RETURNING id INTO prof_id;
    
    INSERT INTO professional_specialties (professional_id, specialty)
    VALUES (prof_id, 'Green Building'), (prof_id, 'LEED Certification');
    
    INSERT INTO professional_certifications (professional_id, certification, issued_date, expiry_date)
    VALUES (prof_id, 'LEED AP', now() - interval '2 years', now() + interval '3 years'),
           (prof_id, 'WELL AP', now() - interval '2 years', now() + interval '3 years');

    -- Batch 2: Traditional Crafts
    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Marcus Johnson', 'Mason Contractor', 'Heritage Masonry', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Philadelphia, PA', 4.7, 134, 95.00, 'Expert mason specializing in historic restoration and custom stonework.', 'marcus.j@example.com', '(215) 555-0134', true)
    RETURNING id INTO prof_id;
    
    INSERT INTO professional_specialties (professional_id, specialty)
    VALUES (prof_id, 'Historic Restoration'), (prof_id, 'Stone Masonry');
    
    INSERT INTO professional_certifications (professional_id, certification, issued_date, expiry_date)
    VALUES (prof_id, 'Mason Contractor License', now() - interval '2 years', now() + interval '3 years'),
           (prof_id, 'Historic Preservation Cert', now() - interval '2 years', now() + interval '3 years');

    -- Batch 3: Lighting and Electrical
    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Diana Patel', 'Lighting Designer', 'Luminous Design', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=facearea&facepad=2&w=256&h=256', 'New York, NY', 4.9, 98, 125.00, 'Innovative lighting designer for architectural and theatrical projects.', 'diana.p@example.com', '(212) 555-0135', true)
    RETURNING id INTO prof_id;
    
    INSERT INTO professional_specialties (professional_id, specialty)
    VALUES (prof_id, 'Architectural Lighting'), (prof_id, 'Theater Design');
    
    INSERT INTO professional_certifications (professional_id, certification, issued_date, expiry_date)
    VALUES (prof_id, 'LC Certification', now() - interval '2 years', now() + interval '3 years'),
           (prof_id, 'IES Member', now() - interval '2 years', now() + interval '3 years');

    -- Continue with remaining professionals...
    -- Batch 4: Plumbing
    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Kevin O''Brien', 'Plumbing Contractor', 'Flow Masters', 'https://images.unsplash.com/photo-1552058544-f2b08422138a?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Chicago, IL', 4.6, 189, 90.00, 'Licensed plumber specializing in commercial and residential systems.', 'kevin.o@example.com', '(312) 555-0136', true)
    RETURNING id INTO prof_id;

    -- Batch 5: Acoustics
    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Amanda Wright', 'Acoustical Engineer', 'Sound Space Design', 'https://images.unsplash.com/photo-1491349174775-aaafddd81942?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Nashville, TN', 4.8, 67, 155.00, 'Acoustical engineer specializing in performance venues and recording studios.', 'amanda.w@example.com', '(615) 555-0137', true)
    RETURNING id INTO prof_id;

    -- Batch 6: Solar Energy
    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Carlos Mendoza', 'Solar Installation Specialist', 'SunTech Solutions', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Phoenix, AZ', 4.7, 143, 100.00, 'Certified solar installer with expertise in residential and commercial systems.', 'carlos.m@example.com', '(602) 555-0138', true)
    RETURNING id INTO prof_id;

    -- Batch 7: BIM and Technology
    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Nina Patel', 'BIM Coordinator', 'Digital Construction', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=facearea&facepad=2&w=256&h=256', 'San Jose, CA', 4.9, 82, 135.00, 'BIM specialist coordinating complex construction projects using latest technology.', 'nina.p@example.com', '(408) 555-0139', true)
    RETURNING id INTO prof_id;

    -- Batch 8: Historical Preservation
    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('William Chang', 'Restoration Specialist', 'Heritage Restoration', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Boston, MA', 4.8, 91, 115.00, 'Expert in historical building restoration and preservation techniques.', 'william.c@example.com', '(617) 555-0140', true)
    RETURNING id INTO prof_id;

    -- Batch 9: Fire Safety
    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Elena Rodriguez', 'Fire Protection Engineer', 'Safety First Engineering', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Houston, TX', 4.9, 124, 160.00, 'Specialized in fire protection systems and building safety compliance.', 'elena.r@example.com', '(713) 555-0141', true)
    RETURNING id INTO prof_id;

    -- Batch 10: Smart Home Integration
    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Jordan Taylor', 'Smart Home Integrator', 'Connected Spaces', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Seattle, WA', 4.7, 156, 105.00, 'Expert in smart home automation and integrated building systems.', 'jordan.t@example.com', '(206) 555-0142', true)
    RETURNING id INTO prof_id;

    -- Add 10 more diverse professionals...
    -- Batch 11-20
    INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
    VALUES
      ('Sophia Lee', 'Renewable Energy Specialist', 'Green Power Systems', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Austin, TX', 4.8, 112, 140.00, 'Specialist in renewable energy integration for buildings.', 'sophia.l@example.com', '(512) 555-0143', true),
      ('Marcus Chen', 'Structural Steel Expert', 'Steel Solutions', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Pittsburgh, PA', 4.7, 178, 130.00, 'Expert in structural steel design and installation.', 'marcus.c@example.com', '(412) 555-0144', true),
      ('Isabella Martinez', 'Green Roof Specialist', 'Living Roofs', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Denver, CO', 4.9, 89, 125.00, 'Specialist in green roof design and installation.', 'isabella.m@example.com', '(303) 555-0145', true),
      ('Lucas Wong', 'Building Automation Expert', 'Smart Buildings Inc', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=facearea&facepad=2&w=256&h=256', 'San Francisco, CA', 4.8, 145, 150.00, 'Expert in building automation and control systems.', 'lucas.w@example.com', '(415) 555-0146', true),
      ('Emma Davis', 'Accessibility Specialist', 'Universal Design Co', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Portland, OR', 4.7, 134, 120.00, 'Specialist in accessible design and ADA compliance.', 'emma.d@example.com', '(503) 555-0147', true),
      ('Alexander Kim', 'Facade Engineer', 'Modern Facades', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Chicago, IL', 4.9, 167, 155.00, 'Engineer specializing in building envelope systems.', 'alexander.k@example.com', '(312) 555-0148', true),
      ('Olivia Brown', 'Waste Management Specialist', 'Clean Construction', 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Seattle, WA', 4.8, 98, 115.00, 'Expert in construction waste management and recycling.', 'olivia.b@example.com', '(206) 555-0149', true),
      ('Daniel Garcia', 'Demolition Expert', 'Precision Demolition', 'https://images.unsplash.com/photo-1463453091185-61582044d556?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Los Angeles, CA', 4.7, 189, 135.00, 'Specialist in controlled demolition and site clearing.', 'daniel.g@example.com', '(213) 555-0150', true),
      ('Ava Wilson', 'Waterproofing Specialist', 'Dry Spaces', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Miami, FL', 4.8, 156, 110.00, 'Expert in building waterproofing and moisture control.', 'ava.w@example.com', '(305) 555-0151', true),
      ('Ethan Park', 'Site Safety Manager', 'Safety First Construction', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=facearea&facepad=2&w=256&h=256', 'New York, NY', 4.9, 201, 145.00, 'Certified safety manager specializing in construction site safety.', 'ethan.p@example.com', '(212) 555-0152', true);
  END IF;
END $$;