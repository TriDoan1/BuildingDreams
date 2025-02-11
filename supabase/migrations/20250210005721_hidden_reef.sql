/*
  # Add 50 More Construction Professionals

  1. New Data
    - Adds 50 new unique professional records
    - Includes diverse specialties and roles
    - Maintains data consistency with existing schema
    - Ensures unique email addresses

  2. Categories
    - Sustainable Construction
    - Historic Restoration
    - Smart Home Integration
    - Specialty Trades
    - Project Management
    - Design and Architecture
    - Engineering Specialties
    - Safety and Compliance
    - Renewable Energy
    - Custom Fabrication

  3. Data Quality
    - Realistic contact information
    - Varied experience levels
    - Geographic distribution
    - Diverse specializations
*/

DO $$
DECLARE
  prof_id uuid;
  base_email text := 'professional';
  counter int := 1;
BEGIN
  -- Generate unique email for each professional
  WHILE counter <= 50 LOOP
    -- Only proceed if this specific email doesn't exist
    IF NOT EXISTS (
      SELECT 1 FROM professionals 
      WHERE email = base_email || counter || '@example.com'
    ) THEN
      -- Insert professional with unique email
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
      SELECT
        -- Use CASE statements to generate varied data
        CASE (counter % 10)
          WHEN 0 THEN 'John Smith'
          WHEN 1 THEN 'Maria Garcia'
          WHEN 2 THEN 'David Chen'
          WHEN 3 THEN 'Sarah Johnson'
          WHEN 4 THEN 'Michael Kim'
          WHEN 5 THEN 'Lisa Patel'
          WHEN 6 THEN 'James Wilson'
          WHEN 7 THEN 'Emma Davis'
          WHEN 8 THEN 'Robert Lee'
          WHEN 9 THEN 'Sofia Rodriguez'
        END || ' ' || counter as name,
        
        CASE (counter % 10)
          WHEN 0 THEN 'Sustainable Building Expert'
          WHEN 1 THEN 'Historic Restoration Specialist'
          WHEN 2 THEN 'Smart Home Integrator'
          WHEN 3 THEN 'Custom Fabrication Expert'
          WHEN 4 THEN 'Project Manager'
          WHEN 5 THEN 'Interior Architect'
          WHEN 6 THEN 'Structural Engineer'
          WHEN 7 THEN 'Safety Compliance Officer'
          WHEN 8 THEN 'Renewable Energy Specialist'
          WHEN 9 THEN 'Custom Design Consultant'
        END as role,
        
        CASE (counter % 10)
          WHEN 0 THEN 'EcoBuilders Pro'
          WHEN 1 THEN 'Heritage Restoration Co'
          WHEN 2 THEN 'Smart Living Solutions'
          WHEN 3 THEN 'Custom Craft Works'
          WHEN 4 THEN 'Project Excellence'
          WHEN 5 THEN 'Interior Innovations'
          WHEN 6 THEN 'Structural Solutions'
          WHEN 7 THEN 'Safety First Consulting'
          WHEN 8 THEN 'Renewable Systems Inc'
          WHEN 9 THEN 'Design Masters LLC'
        END as company,
        
        -- Rotate through a set of professional headshot images
        'https://images.unsplash.com/photo-' || 
        CASE (counter % 5)
          WHEN 0 THEN '1500648767791-00dcc994a43e'
          WHEN 1 THEN '1494790108377-be9c29b29330'
          WHEN 2 THEN '1472099645785-5658abf4ff4e'
          WHEN 3 THEN '1534528741775-53994a69daeb'
          WHEN 4 THEN '1507003211169-0a1dd7228f2d'
        END || '?auto=format&fit=facearea&facepad=2&w=256&h=256' as image_url,
        
        -- Distribute across major US cities
        CASE (counter % 8)
          WHEN 0 THEN 'New York, NY'
          WHEN 1 THEN 'Los Angeles, CA'
          WHEN 2 THEN 'Chicago, IL'
          WHEN 3 THEN 'Houston, TX'
          WHEN 4 THEN 'Phoenix, AZ'
          WHEN 5 THEN 'Philadelphia, PA'
          WHEN 6 THEN 'San Antonio, TX'
          WHEN 7 THEN 'San Diego, CA'
        END as location,
        
        -- Generate realistic ratings between 4.5 and 5.0
        4.5 + (random() * 0.5) as rating,
        
        -- Generate realistic project counts
        50 + (random() * 150)::int as projects_completed,
        
        -- Generate realistic hourly rates
        75 + (random() * 125)::int as hourly_rate,
        
        -- Generate detailed bios
        CASE (counter % 5)
          WHEN 0 THEN 'Experienced professional specializing in sustainable building practices with a focus on energy efficiency and green materials.'
          WHEN 1 THEN 'Expert craftsperson with extensive experience in historical restoration and preservation techniques.'
          WHEN 2 THEN 'Technology-focused builder integrating smart home systems and automated solutions.'
          WHEN 3 THEN 'Skilled project manager with a track record of delivering complex construction projects on time and within budget.'
          WHEN 4 THEN 'Innovative designer combining traditional techniques with modern sustainable practices.'
        END as bio,
        
        -- Generate unique email
        base_email || counter || '@example.com' as email,
        
        -- Generate formatted phone numbers
        '(555) ' || LPAD(counter::text, 3, '0') || '-' || LPAD((counter * 4)::text, 4, '0') as phone,
        
        -- Most professionals are verified
        random() < 0.8 as verified
      RETURNING id INTO prof_id;

      -- Add specialties for the professional
      INSERT INTO professional_specialties (professional_id, specialty)
      SELECT prof_id, specialty
      FROM (
        SELECT unnest(ARRAY[
          CASE (counter % 5)
            WHEN 0 THEN 'Sustainable Design'
            WHEN 1 THEN 'Historic Restoration'
            WHEN 2 THEN 'Smart Home Integration'
            WHEN 3 THEN 'Project Management'
            WHEN 4 THEN 'Custom Fabrication'
          END,
          CASE (counter % 5)
            WHEN 0 THEN 'Green Building'
            WHEN 1 THEN 'Preservation'
            WHEN 2 THEN 'Home Automation'
            WHEN 3 THEN 'Construction Management'
            WHEN 4 THEN 'Custom Design'
          END
        ]) as specialty
      ) s;

      -- Add certifications for the professional
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
          CASE (counter % 5)
            WHEN 0 THEN 'LEED AP'
            WHEN 1 THEN 'Historic Preservation'
            WHEN 2 THEN 'Smart Home Certified'
            WHEN 3 THEN 'PMP'
            WHEN 4 THEN 'Master Craftsman'
          END,
          CASE (counter % 5)
            WHEN 0 THEN 'Energy Auditor'
            WHEN 1 THEN 'Restoration Specialist'
            WHEN 2 THEN 'Home Technology Professional'
            WHEN 3 THEN 'Safety Certified'
            WHEN 4 THEN 'Design Professional'
          END
        ]) as cert
      ) c;
    END IF;
    
    counter := counter + 1;
  END LOOP;
END $$;