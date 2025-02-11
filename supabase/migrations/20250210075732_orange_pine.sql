/*
  # Add hiring and company status fields

  1. Changes
    - Add isHiring boolean field to professionals table
    - Add isCompany boolean field to professionals table
    - Mark approximately 1/3 of professionals as companies
    - Randomly set isHiring status for companies only

  2. Notes
    - Default values set to false
    - Only companies can have isHiring set to true
    - Maintains existing RLS policies
*/

-- Add new columns with default values
ALTER TABLE professionals
ADD COLUMN IF NOT EXISTS is_hiring boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS is_company boolean DEFAULT false;

-- Update professionals to mark ~1/3 as companies and set hiring status
DO $$
BEGIN
  -- First mark approximately 1/3 of professionals as companies
  UPDATE professionals
  SET is_company = true
  WHERE id IN (
    SELECT id
    FROM professionals
    WHERE random() < 0.33
  );

  -- Then randomly set hiring status only for companies
  -- This will mark about 60% of companies as hiring
  UPDATE professionals
  SET is_hiring = true
  WHERE is_company = true
  AND random() < 0.6;
END $$;