/*
  # Update Project Descriptions

  1. Changes
    - Updates existing project descriptions with unique, detailed content
    - Each description now includes:
      - Scope of work
      - Key features
      - Timeline or completion status
      - Specific technical details
      - Sustainability or innovation aspects where applicable

  2. Notes
    - Uses safe update operations
    - Maintains existing project relationships
    - Preserves all other project data
*/

DO $$
BEGIN
  -- Update project descriptions with unique content
  UPDATE projects
  SET description = CASE
    WHEN title LIKE '%Modern Office%' THEN 
      'Complete transformation of a 5,000 sq ft open-plan office space featuring sustainable materials, smart lighting systems, and modular workstations. Implemented biophilic design elements including living walls and natural light optimization. Achieved LEED Gold certification through energy-efficient HVAC upgrades and water conservation measures.'
    
    WHEN title LIKE '%Sustainable Home%' THEN 
      'Zero-energy custom residence incorporating cutting-edge sustainable technologies. Features include a 12.5kW solar array, geothermal heating/cooling, rainwater harvesting system, and smart home automation. Built with locally sourced materials and achieved a HERS Index of 0, making it one of the most energy-efficient homes in the region.'
    
    WHEN title LIKE '%Historic Building%' THEN 
      'Meticulous restoration of a 19th-century landmark building, preserving original architectural elements while modernizing infrastructure. Work included hand-restoration of ornate plasterwork, reconstruction of period-accurate windows, and integration of modern systems without compromising historical integrity. Project received preservation excellence award.'
    
    WHEN title LIKE '%Commercial Space%' THEN 
      'Strategic redesign of a 10,000 sq ft retail space optimizing customer flow and experience. Implemented innovative lighting design, interactive digital displays, and flexible layout solutions. Features include a state-of-the-art inventory management system, energy-efficient climate control, and ADA-compliant access improvements.'
    
    WHEN title LIKE '%Industrial Complex%' THEN 
      'Comprehensive modernization of a manufacturing facility focusing on efficiency and sustainability. Upgrades included automated production line integration, advanced ventilation systems, and smart energy management. Resulted in 40% reduction in energy consumption and 25% increase in production capacity.'
    
    ELSE 
      CASE (random() * 4)::int
        WHEN 0 THEN 'Custom-designed wellness center featuring meditation spaces, yoga studios, and therapeutic gardens. Incorporates natural materials, sound dampening technology, and circadian lighting systems. Achieved WELL Building certification for optimal occupant health and comfort.'
        WHEN 1 THEN 'Mixed-use development combining residential units with ground-floor retail spaces. Features include green roof installations, community gathering areas, and smart parking solutions. Designed for maximum space efficiency while maintaining aesthetic appeal.'
        WHEN 2 THEN 'State-of-the-art data center facility with redundant power systems, advanced cooling solutions, and cutting-edge security measures. Implemented modular design for future expansion and achieved Tier IV certification for reliability.'
        WHEN 3 THEN 'Innovative educational facility designed for hybrid learning environments. Includes flexible classroom spaces, advanced audiovisual systems, and outdoor learning areas. Incorporates sustainable features and smart building technology throughout.'
        ELSE 'Luxury hospitality renovation featuring custom millwork, high-end finishes, and integrated technology solutions. Includes spa facilities, rooftop entertainment spaces, and gourmet kitchen installations. Completed while maintaining partial occupancy.'
      END
  END
  WHERE description LIKE '%Complete interior renovation%'
     OR description LIKE '%Net-zero energy%'
     OR description LIKE '%Careful restoration%'
     OR description LIKE '%Modern redesign%'
     OR description LIKE '%Comprehensive upgrade%';
END $$;