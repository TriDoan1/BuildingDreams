/*
  # Initial schema for construction professionals platform

  1. New Tables
    - professionals: Main table for professional profiles
    - professional_specialties: Junction table for professional specialties
    - professional_certifications: Junction table for professional certifications

  2. Security
    - Enable RLS on all tables
    - Add policies for public read access
    - Add policy for authenticated users to update their own profiles

  3. Sample Data
    - Insert initial set of professionals
    - Add specialties and certifications
*/

-- Create professionals table
CREATE TABLE IF NOT EXISTS professionals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  role text NOT NULL,
  company text,
  image_url text,
  location text NOT NULL,
  rating numeric(2,1) CHECK (rating >= 0 AND rating <= 5),
  projects_completed integer DEFAULT 0,
  hourly_rate numeric(10,2),
  bio text,
  email text UNIQUE NOT NULL,
  phone text,
  verified boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create professional_specialties table
CREATE TABLE IF NOT EXISTS professional_specialties (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  professional_id uuid REFERENCES professionals(id) ON DELETE CASCADE,
  specialty text NOT NULL,
  UNIQUE(professional_id, specialty)
);

-- Create professional_certifications table
CREATE TABLE IF NOT EXISTS professional_certifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  professional_id uuid REFERENCES professionals(id) ON DELETE CASCADE,
  certification text NOT NULL,
  issued_date date NOT NULL,
  expiry_date date,
  UNIQUE(professional_id, certification)
);

-- Enable RLS
ALTER TABLE professionals ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_specialties ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_certifications ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Anyone can view professionals"
  ON professionals FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Professionals can update own profile"
  ON professionals FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = id::text);

CREATE POLICY "Anyone can view specialties"
  ON professional_specialties FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can view certifications"
  ON professional_certifications FOR SELECT
  TO public
  USING (true);

-- Insert sample data
DO $$
DECLARE
  sarah_id uuid;
  michael_id uuid;
  emily_id uuid;
  david_id uuid;
  lisa_id uuid;
BEGIN
  -- Insert first batch of professionals
  INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
  VALUES
    ('Sarah Chen', 'Lead Architect', 'Modern Design Studio', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=facearea&facepad=2&w=256&h=256', 'San Francisco, CA', 4.9, 127, 150.00, 'Award-winning architect specializing in sustainable urban design with 15+ years of experience.', 'sarah.chen@example.com', '(415) 555-0123', true)
  RETURNING id INTO sarah_id;

  INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
  VALUES
    ('Michael Rodriguez', 'Master Builder', 'Elite Construction', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Chicago, IL', 4.8, 215, 125.00, 'Master builder with expertise in commercial and industrial construction projects.', 'michael.r@example.com', '(312) 555-0124', true)
  RETURNING id INTO michael_id;

  INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
  VALUES
    ('Emily Thompson', 'Interior Designer', 'Aesthetic Spaces', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=facearea&facepad=2&w=256&h=256', 'New York, NY', 4.9, 94, 135.00, 'Luxury interior designer specializing in high-end residential and hospitality projects.', 'emily.t@example.com', '(212) 555-0125', true)
  RETURNING id INTO emily_id;

  INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
  VALUES
    ('David Park', 'General Contractor', 'Park Construction', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Los Angeles, CA', 4.7, 178, 110.00, 'Experienced general contractor focused on residential renovations and new construction.', 'david.park@example.com', '(213) 555-0126', true)
  RETURNING id INTO david_id;

  INSERT INTO professionals (name, role, company, image_url, location, rating, projects_completed, hourly_rate, bio, email, phone, verified)
  VALUES
    ('Lisa Martinez', 'Structural Engineer', 'Solid Engineering', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=facearea&facepad=2&w=256&h=256', 'Miami, FL', 4.9, 156, 165.00, 'Structural engineer specializing in seismic design and high-rise buildings.', 'lisa.m@example.com', '(305) 555-0127', true)
  RETURNING id INTO lisa_id;

  -- Insert specialties for each professional
  INSERT INTO professional_specialties (professional_id, specialty)
  VALUES
    (sarah_id, 'Sustainable Design'),
    (sarah_id, 'Urban Planning'),
    (michael_id, 'Commercial Construction'),
    (michael_id, 'Industrial Projects'),
    (emily_id, 'Luxury Residential'),
    (emily_id, 'Hospitality Design'),
    (david_id, 'Residential Construction'),
    (david_id, 'Renovation'),
    (lisa_id, 'Seismic Design'),
    (lisa_id, 'High-rise Construction');

  -- Insert certifications for each professional
  INSERT INTO professional_certifications (professional_id, certification, issued_date, expiry_date)
  VALUES
    (sarah_id, 'LEED AP', now() - interval '2 years', now() + interval '3 years'),
    (sarah_id, 'AIA Licensed', now() - interval '2 years', now() + interval '3 years'),
    (michael_id, 'PMP Certified', now() - interval '2 years', now() + interval '3 years'),
    (michael_id, 'OSHA 30', now() - interval '2 years', now() + interval '3 years'),
    (emily_id, 'NCIDQ Certified', now() - interval '2 years', now() + interval '3 years'),
    (emily_id, 'ASID Member', now() - interval '2 years', now() + interval '3 years'),
    (david_id, 'Licensed Contractor', now() - interval '2 years', now() + interval '3 years'),
    (david_id, 'OSHA Certified', now() - interval '2 years', now() + interval '3 years'),
    (lisa_id, 'PE License', now() - interval '2 years', now() + interval '3 years'),
    (lisa_id, 'Structural Engineer License', now() - interval '2 years', now() + interval '3 years');
END $$;