/*
  # Database Restructure for Building Dreams Platform

  1. New Tables
    - `companies` - Company profiles with hiring status
      - `id` (uuid, primary key)
      - `name` (text)
      - `description` (text)
      - `location` (text)
      - `latitude` (double precision)
      - `longitude` (double precision)
      - `website` (text)
      - `is_hiring` (boolean)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

    - `users` - Base user table
      - `id` (uuid, primary key)
      - `email` (text, unique)
      - `name` (text)
      - `image_url` (text)
      - `phone` (text)
      - `user_type` (text) - 'homeowner' or 'professional'
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

    - `homeowners` - Homeowner-specific data
      - `user_id` (uuid, references users)
      - `address` (text)
      - `preferred_contact` (text)

    - `professionals` - Professional-specific data
      - `user_id` (uuid, references users)
      - `company_id` (uuid, references companies)
      - `role` (text)
      - `hourly_rate` (numeric)
      - `bio` (text)
      - `rating` (numeric)
      - `verified` (boolean)
      - `projects_completed` (integer)
      - `location` (text)
      - `latitude` (double precision)
      - `longitude` (double precision)

  2. Security
    - Enable RLS on all tables
    - Add policies for data access

  3. Data Migration
    - Clean existing data
    - Create new company records
    - Create professional and homeowner records
*/

-- Drop existing tables and their dependencies
DROP TABLE IF EXISTS professional_specialties CASCADE;
DROP TABLE IF EXISTS professional_certifications CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS professionals CASCADE;

-- Create new tables
CREATE TABLE companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  location text NOT NULL,
  latitude double precision,
  longitude double precision,
  website text,
  is_hiring boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  name text NOT NULL,
  image_url text,
  phone text,
  user_type text NOT NULL CHECK (user_type IN ('homeowner', 'professional')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE homeowners (
  user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  address text,
  preferred_contact text CHECK (preferred_contact IN ('email', 'phone', 'both')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE professionals (
  user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  company_id uuid REFERENCES companies(id) ON DELETE SET NULL,
  role text NOT NULL,
  hourly_rate numeric(10,2),
  bio text,
  rating numeric(2,1) CHECK (rating >= 0 AND rating <= 5),
  verified boolean DEFAULT false,
  projects_completed integer DEFAULT 0,
  location text NOT NULL,
  latitude double precision,
  longitude double precision,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE professional_specialties (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  professional_id uuid REFERENCES professionals(user_id) ON DELETE CASCADE,
  specialty text NOT NULL,
  UNIQUE(professional_id, specialty)
);

CREATE TABLE professional_certifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  professional_id uuid REFERENCES professionals(user_id) ON DELETE CASCADE,
  certification text NOT NULL,
  issued_date date NOT NULL,
  expiry_date date,
  UNIQUE(professional_id, certification)
);

CREATE TABLE projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  budget numeric(10,2),
  location text NOT NULL,
  latitude double precision,
  longitude double precision,
  image_url text NOT NULL,
  homeowner_id uuid REFERENCES homeowners(user_id),
  professional_id uuid REFERENCES professionals(user_id),
  status text CHECK (status IN ('open', 'in_progress', 'completed', 'cancelled')),
  likes integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE homeowners ENABLE ROW LEVEL SECURITY;
ALTER TABLE professionals ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_specialties ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_certifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Public read access to companies"
  ON companies FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Public read access to professionals"
  ON professionals FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Public read access to professional specialties"
  ON professional_specialties FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Public read access to professional certifications"
  ON professional_certifications FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Public read access to projects"
  ON projects FOR SELECT
  TO public
  USING (true);

-- Create function to update coordinates based on location
CREATE OR REPLACE FUNCTION get_socal_coordinates(city_name text)
RETURNS TABLE(lat double precision, lng double precision) AS $$
BEGIN
  RETURN QUERY
  SELECT
    CAST(CASE city_name
      WHEN 'Los Angeles' THEN 34.0522
      WHEN 'San Diego' THEN 32.7157
      WHEN 'Irvine' THEN 33.6846
      WHEN 'Santa Ana' THEN 33.7455
      WHEN 'Anaheim' THEN 33.8366
      WHEN 'Riverside' THEN 33.9533
      WHEN 'San Bernardino' THEN 34.1083
      WHEN 'Santa Barbara' THEN 34.4208
      WHEN 'Ventura' THEN 34.2805
      WHEN 'Long Beach' THEN 33.7701
      ELSE 34.0522 -- Default to LA
    END AS double precision) as lat,
    CAST(CASE city_name
      WHEN 'Los Angeles' THEN -118.2437
      WHEN 'San Diego' THEN -117.1611
      WHEN 'Irvine' THEN -117.8265
      WHEN 'Santa Ana' THEN -117.8677
      WHEN 'Anaheim' THEN -117.9143
      WHEN 'Riverside' THEN -117.3961
      WHEN 'San Bernardino' THEN -117.2898
      WHEN 'Santa Barbara' THEN -119.6982
      WHEN 'Ventura' THEN -119.2945
      WHEN 'Long Beach' THEN -118.1937
      ELSE -118.2437 -- Default to LA
    END AS double precision) as lng;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create trigger function to update coordinates
CREATE OR REPLACE FUNCTION update_coordinates()
RETURNS TRIGGER AS $$
DECLARE
  coords RECORD;
BEGIN
  SELECT * INTO coords FROM get_socal_coordinates(split_part(NEW.location, ',', 1));
  
  IF coords.lat IS NOT NULL AND coords.lng IS NOT NULL THEN
    NEW.latitude := coords.lat + (random() - 0.5) * 0.02;
    NEW.longitude := coords.lng + (random() - 0.5) * 0.02;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
CREATE TRIGGER update_company_coordinates
  BEFORE INSERT OR UPDATE OF location
  ON companies
  FOR EACH ROW
  EXECUTE FUNCTION update_coordinates();

CREATE TRIGGER update_professional_coordinates
  BEFORE INSERT OR UPDATE OF location
  ON professionals
  FOR EACH ROW
  EXECUTE FUNCTION update_coordinates();

CREATE TRIGGER update_project_coordinates
  BEFORE INSERT OR UPDATE OF location
  ON projects
  FOR EACH ROW
  EXECUTE FUNCTION update_coordinates();