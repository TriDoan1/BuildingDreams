/*
  # Add hiring and company status fields

  1. Changes
    - Add isHiring boolean field to professionals table
    - Add isCompany boolean field to professionals table
    - Set random values for approximately 1/3 of professionals

  2. Notes
    - Default values set to false
    - Maintains existing RLS policies
*/

-- Add new columns with default values
ALTER TABLE professionals
ADD COLUMN IF NOT EXISTS is_hiring boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS is_company boolean DEFAULT false;

-- Update approximately 1/3 of professionals to be companies and/or hiring
DO $$
BEGIN
  -- Update is_company for ~1/3 of professionals
  UPDATE professionals
  SET is_company = true
  WHERE id IN (
    SELECT id
    FROM professionals
    WHERE random() < 0.33
  );

  -- Update is_hiring for ~1/3 of professionals
  -- Note: Some overlap with is_company is intentional to represent
  -- both individual professionals and companies that are hiring
  UPDATE professionals
  SET is_hiring = true
  WHERE id IN (
    SELECT id
    FROM professionals
    WHERE random() < 0.33
  );

  -- Ensure all companies have valid hiring status
  UPDATE professionals
  SET is_hiring = CASE 
    WHEN random() < 0.8 THEN true  -- 80% of companies are hiring
    ELSE false
  END
  WHERE is_company = true;
END $$;