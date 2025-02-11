import { supabase } from '../lib/supabase';

export async function viewProfessionals() {
  const { data: professionals, error: profError } = await supabase
    .from('professionals')
    .select(`
      *,
      professional_specialties (specialty),
      professional_certifications (
        certification,
        issued_date,
        expiry_date
      )
    `);

  if (profError) {
    console.error('Error fetching professionals:', profError);
    return;
  }

  console.log('Professionals:', professionals);
  return professionals;
}

export async function viewProjects() {
  const { data: projects, error: projError } = await supabase
    .from('projects')
    .select(`
      *,
      professional:professionals (
        name,
        role,
        location,
        rating,
        image_url,
        verified
      )
    `);

  if (projError) {
    console.error('Error fetching projects:', projError);
    return;
  }

  console.log('Projects:', projects);
  return projects;
}