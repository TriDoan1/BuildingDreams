/*
  # Add Geocoding Support

  1. Schema Changes
    - Add lat/lng columns to professionals table
    - Add GiST index for spatial queries
  
  2. Data Updates
    - Add coordinates for existing locations
    
  3. Notes
    - Using double precision for accurate coordinate storage
    - Adding index to optimize location-based queries
*/

-- Add coordinates columns
ALTER TABLE professionals
ADD COLUMN IF NOT EXISTS latitude double precision,
ADD COLUMN IF NOT EXISTS longitude double precision;

-- Create index for spatial queries
CREATE INDEX IF NOT EXISTS idx_professionals_coordinates 
ON professionals (latitude, longitude) 
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- Update existing records with coordinates
DO $$
DECLARE
  location_coords RECORD;
BEGIN
  -- Define coordinates for each city
  FOR location_coords IN (
    SELECT 
      location,
      CASE location
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
      END as lat,
      CASE location
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
      END as lng
    FROM (SELECT DISTINCT location FROM professionals) locations
  ) LOOP
    -- Add small random offset to prevent exact overlaps
    UPDATE professionals 
    SET 
      latitude = location_coords.lat + (random() - 0.5) * 0.05,
      longitude = location_coords.lng + (random() - 0.5) * 0.05
    WHERE location = location_coords.location
    AND (latitude IS NULL OR longitude IS NULL);
  END LOOP;
END $$;