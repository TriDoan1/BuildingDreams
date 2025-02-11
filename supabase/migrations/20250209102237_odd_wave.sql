/*
  # Add projects table and sample data

  1. New Tables
    - `projects`
      - `id` (uuid, primary key)
      - `title` (text)
      - `description` (text)
      - `image_url` (text)
      - `professional_id` (uuid, references professionals)
      - `likes` (integer)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `projects` table
    - Add policy for public read access
*/

-- Create projects table
CREATE TABLE IF NOT EXISTS projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  image_url text NOT NULL,
  professional_id uuid REFERENCES professionals(id) ON DELETE CASCADE,
  likes integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE tablename = 'projects' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- Create policies
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'projects' 
    AND policyname = 'Anyone can view projects'
  ) THEN
    CREATE POLICY "Anyone can view projects"
      ON projects FOR SELECT
      TO public
      USING (true);
  END IF;
END $$;

-- Insert sample projects
DO $$
DECLARE
  prof_id uuid;
BEGIN
  -- Only insert if the table is empty
  IF NOT EXISTS (SELECT 1 FROM projects LIMIT 1) THEN
    -- Get some professional IDs to reference
    FOR prof_id IN (SELECT id FROM professionals LIMIT 20) LOOP
      INSERT INTO projects (title, description, image_url, professional_id, likes)
      VALUES
        (
          CASE (random() * 4)::int
            WHEN 0 THEN 'Modern Office Renovation'
            WHEN 1 THEN 'Sustainable Home Build'
            WHEN 2 THEN 'Historic Building Restoration'
            WHEN 3 THEN 'Commercial Space Redesign'
            ELSE 'Industrial Complex Upgrade'
          END,
          CASE (random() * 4)::int
            WHEN 0 THEN 'Complete interior renovation of a 5000 sq ft office space with focus on sustainability'
            WHEN 1 THEN 'Net-zero energy custom home with solar integration and smart systems'
            WHEN 2 THEN 'Careful restoration of a 19th century landmark building preserving historical elements'
            WHEN 3 THEN 'Modern redesign of a retail space emphasizing customer flow and experience'
            ELSE 'Comprehensive upgrade of manufacturing facility improving efficiency'
          END,
          CASE (random() * 4)::int
            WHEN 0 THEN 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=800'
            WHEN 1 THEN 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?auto=format&fit=crop&w=800'
            WHEN 2 THEN 'https://images.unsplash.com/photo-1582653291997-079a1c04e5a1?auto=format&fit=crop&w=800'
            WHEN 3 THEN 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=800'
            ELSE 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?auto=format&fit=crop&w=800'
          END,
          prof_id,
          floor(random() * 200 + 50)
        );
    END LOOP;
  END IF;
END $$;