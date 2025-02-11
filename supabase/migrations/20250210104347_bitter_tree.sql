-- Update approximately 25% of professionals to be featured
UPDATE professionals
SET is_featured = false;

-- First, mark architects and designers as featured
UPDATE professionals
SET is_featured = true
WHERE role IN ('Architect', 'Interior Designer')
AND random() < 0.25; -- Make 25% of architects and designers featured

-- Then ensure we have enough featured professionals by marking additional ones if needed
WITH featured_count AS (
  SELECT COUNT(*) as count FROM professionals WHERE is_featured = true
),
total_count AS (
  SELECT COUNT(*) as count FROM professionals
)
UPDATE professionals
SET is_featured = true
WHERE id IN (
  SELECT id 
  FROM professionals 
  WHERE is_featured = false
  AND random() < (
    SELECT GREATEST(0, (total_count.count * 0.25 - featured_count.count) / 
      (SELECT COUNT(*) FROM professionals WHERE is_featured = false))
    FROM featured_count, total_count
  )
);