-- Add isFeatured column to professionals table
ALTER TABLE professionals 
ADD COLUMN is_featured boolean DEFAULT false;

-- Randomly set some architects and designers as featured
UPDATE professionals
SET is_featured = true
WHERE role IN ('Architect', 'Interior Designer')
AND random() < 0.2; -- Make 20% of architects and designers featured