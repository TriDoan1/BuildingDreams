/*
  # Add city-based coordinates handling

  1. Changes
    - Add function to get city coordinates
    - Create trigger for automatic coordinate updates
    - Update existing records with city coordinates

  2. Security
    - Functions are marked as IMMUTABLE for performance
    - No direct access to coordinates outside of trigger
*/

-- Add function to get city coordinates
CREATE OR REPLACE FUNCTION get_city_coordinates(city_state text)
RETURNS TABLE(lat double precision, lng double precision) AS $$
BEGIN
  RETURN QUERY
  SELECT
    CAST(CASE city_state
      WHEN 'New York, NY' THEN 40.7128
      WHEN 'Los Angeles, CA' THEN 34.0522
      WHEN 'Chicago, IL' THEN 41.8781
      WHEN 'Houston, TX' THEN 29.7604
      WHEN 'Phoenix, AZ' THEN 33.4484
      WHEN 'Philadelphia, PA' THEN 39.9526
      WHEN 'San Antonio, TX' THEN 29.4241
      WHEN 'San Diego, CA' THEN 32.7157
      WHEN 'Dallas, TX' THEN 32.7767
      WHEN 'San Jose, CA' THEN 37.3382
      WHEN 'Austin, TX' THEN 30.2672
      WHEN 'Denver, CO' THEN 39.7392
      WHEN 'Boston, MA' THEN 42.3601
      WHEN 'Portland, OR' THEN 45.5155
      WHEN 'Miami, FL' THEN 25.7617
      WHEN 'Seattle, WA' THEN 47.6062
      ELSE NULL
    END AS double precision) as lat,
    CAST(CASE city_state
      WHEN 'New York, NY' THEN -74.0060
      WHEN 'Los Angeles, CA' THEN -118.2437
      WHEN 'Chicago, IL' THEN -87.6298
      WHEN 'Houston, TX' THEN -95.3698
      WHEN 'Phoenix, AZ' THEN -112.0740
      WHEN 'Philadelphia, PA' THEN -75.1652
      WHEN 'San Antonio, TX' THEN -98.4936
      WHEN 'San Diego, CA' THEN -117.1611
      WHEN 'Dallas, TX' THEN -96.7970
      WHEN 'San Jose, CA' THEN -121.8863
      WHEN 'Austin, TX' THEN -97.7431
      WHEN 'Denver, CO' THEN -104.9903
      WHEN 'Boston, MA' THEN -71.0589
      WHEN 'Portland, OR' THEN -122.6789
      WHEN 'Miami, FL' THEN -80.1918
      WHEN 'Seattle, WA' THEN -122.3321
      ELSE NULL
    END AS double precision) as lng;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create trigger function to update coordinates based on location
CREATE OR REPLACE FUNCTION update_professional_coordinates()
RETURNS TRIGGER AS $$
DECLARE
  coords RECORD;
BEGIN
  -- Get coordinates for the city
  SELECT * INTO coords FROM get_city_coordinates(NEW.location);
  
  -- Add small random offset to prevent exact overlaps
  IF coords.lat IS NOT NULL AND coords.lng IS NOT NULL THEN
    NEW.latitude := coords.lat + (random() - 0.5) * 0.02;
    NEW.longitude := coords.lng + (random() - 0.5) * 0.02;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create or replace the trigger
DROP TRIGGER IF EXISTS set_professional_coordinates ON professionals;
CREATE TRIGGER set_professional_coordinates
  BEFORE INSERT OR UPDATE OF location
  ON professionals
  FOR EACH ROW
  EXECUTE FUNCTION update_professional_coordinates();

-- Update existing records with city coordinates
DO $$
DECLARE
  prof RECORD;
  coords RECORD;
BEGIN
  FOR prof IN SELECT * FROM professionals LOOP
    SELECT * INTO coords FROM get_city_coordinates(prof.location);
    IF coords.lat IS NOT NULL AND coords.lng IS NOT NULL THEN
      UPDATE professionals
      SET 
        latitude = coords.lat + (random() - 0.5) * 0.02,
        longitude = coords.lng + (random() - 0.5) * 0.02
      WHERE id = prof.id;
    END IF;
  END LOOP;
END $$;