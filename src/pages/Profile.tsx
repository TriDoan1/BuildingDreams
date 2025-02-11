import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { Star, MapPin, CheckCircle, MessageSquare, Award, Briefcase, Phone, Mail, DollarSign, Building2 } from 'lucide-react';
import type { User, Project } from '../types';

interface Company {
  id: string;
  name: string;
  description: string;
  website: string;
  is_hiring: boolean;
}

export function Profile() {
  const { id } = useParams();
  const [professional, setProfessional] = useState<User | null>(null);
  const [company, setCompany] = useState<Company | null>(null);
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchData() {
      try {
        // First check if we can connect to Supabase
        const { error: healthCheckError } = await supabase.from('professionals').select('count').limit(1);
        
        if (healthCheckError) {
          if (healthCheckError.message.includes('Failed to fetch')) {
            throw new Error('Please connect to Supabase using the "Connect to Supabase" button in the top right corner.');
          }
          throw healthCheckError;
        }

        // Fetch professional details
        const { data: profData, error: profError } = await supabase
          .from('professionals')
          .select(`
            *,
            users (
              name,
              image_url,
              phone,
              email
            ),
            companies (
              id,
              name,
              description,
              website,
              is_hiring
            ),
            professional_specialties (specialty),
            professional_certifications (certification)
          `)
          .eq('user_id', id)
          .single();

        if (profError) throw profError;

        if (!profData) {
          setError('Professional not found');
          return;
        }

        // Fetch professional's projects
        const { data: projectsData, error: projectsError } = await supabase
          .from('projects')
          .select('*')
          .eq('professional_id', profData.id)
          .order('created_at', { ascending: false });

        if (projectsError) throw projectsError;

        setProfessional({
          id: profData.user_id,
          name: profData.users.name,
          avatar: profData.users.image_url,
          trade: profData.role,
          location: profData.location,
          rating: profData.rating,
          verified: profData.verified,
          hourlyRate: profData.hourly_rate,
          completedProjects: profData.projects_completed,
          bio: profData.bio,
          email: profData.users.email,
          phone: profData.users.phone,
          specialties: profData.professional_specialties?.map((s: any) => s.specialty) || [],
          certifications: profData.professional_certifications?.map((c: any) => c.certification) || [],
          coordinates: profData.latitude && profData.longitude ? {
            lat: profData.latitude,
            lng: profData.longitude
          } : null
        });

        if (profData.companies) {
          setCompany(profData.companies);
        }

        setProjects(projectsData || []);
        setError(null);
      } catch (error: any) {
        console.error('Error fetching data:', error);
        setError(error.message || 'Failed to load professional details');
      } finally {
        setLoading(false);
      }
    }

    if (id) {
      fetchData();
    }
  }, [id]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 pt-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="animate-pulse">
            <div className="bg-white rounded-lg shadow-sm overflow-hidden">
              <div className="h-48 bg-gray-200"></div>
              <div className="p-6">
                <div className="h-8 bg-gray-200 rounded w-1/3 mb-4"></div>
                <div className="h-4 bg-gray-200 rounded w-full mb-4"></div>
                <div className="h-4 bg-gray-200 rounded w-2/3"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (error || !professional) {
    return (
      <div className="min-h-screen bg-gray-50 pt-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-2">Error</h2>
            <p className="text-gray-600">{error || 'Professional not found'}</p>
            {error?.includes('Connect to Supabase') && (
              <p className="mt-4 text-sm text-gray-500">
                Click the "Connect to Supabase" button in the top right corner to establish a database connection.
              </p>
            )}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pt-24">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="bg-white rounded-lg shadow-sm overflow-hidden">
          {/* Header Section */}
          <div className="relative h-48 bg-gradient-to-r from-navy-700 to-navy-900">
            <div className="absolute inset-0 opacity-10">
              <div className="w-full h-full bg-[radial-gradient(circle_at_top_right,_var(--tw-gradient-stops))] from-coral-500 to-transparent"></div>
            </div>
            <img
              src={professional.avatar}
              alt={professional.name}
              className="absolute bottom-0 left-8 transform translate-y-1/2 w-32 h-32 rounded-full border-4 border-white object-cover shadow-lg"
            />
          </div>

          <div className="pt-20 p-8">
            {/* Basic Info */}
            <div className="flex items-start justify-between">
              <div>
                <h1 className="text-3xl font-bold text-gray-900 flex items-center">
                  {professional.name}
                  {professional.verified && (
                    <CheckCircle className="h-6 w-6 text-coral-500 ml-2" />
                  )}
                </h1>
                <p className="text-xl text-gray-600 mt-1">{professional.trade}</p>
                <div className="flex items-center mt-2 text-gray-600">
                  <MapPin className="h-5 w-5 mr-1" />
                  {professional.location}
                </div>
                {company && (
                  <div className="mt-2">
                    <Link 
                      to={`/company/${company.id}`}
                      className="inline-flex items-center text-navy-600 hover:text-navy-700"
                    >
                      <Building2 className="h-5 w-5 mr-1" />
                      <span className="font-medium">{company.name}</span>
                      {company.is_hiring && (
                        <span className="ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                          Hiring
                        </span>
                      )}
                    </Link>
                  </div>
                )}
              </div>
              <div className="text-right">
                <div className="flex items-center justify-end mb-2">
                  <Star className="h-6 w-6 text-yellow-400 mr-1" />
                  <span className="text-2xl font-bold">{professional.rating}</span>
                </div>
                <p className="text-gray-600">
                  {professional.completedProjects}+ projects completed
                </p>
              </div>
            </div>

            {/* Contact Button */}
            <div className="mt-6">
              <button className="inline-flex items-center px-6 py-3 border border-transparent rounded-lg shadow-sm text-base font-medium text-white bg-coral-500 hover:bg-coral-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-coral-500">
                <MessageSquare className="h-5 w-5 mr-2" />
                Contact Professional
              </button>
            </div>

            {/* Rate and Contact Info */}
            <div className="mt-8 grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="bg-gray-50 rounded-lg p-4">
                <div className="flex items-center text-gray-600 mb-1">
                  <Briefcase className="h-5 w-5 mr-2" />
                  Hourly Rate
                </div>
                <p className="text-2xl font-bold text-gray-900">${professional.hourlyRate}/hr</p>
              </div>
              
              <div className="bg-gray-50 rounded-lg p-4">
                <div className="flex items-center text-gray-600 mb-1">
                  <Phone className="h-5 w-5 mr-2" />
                  Phone
                </div>
                <p className="text-lg text-gray-900">{professional.phone}</p>
              </div>
              
              <div className="bg-gray-50 rounded-lg p-4">
                <div className="flex items-center text-gray-600 mb-1">
                  <Mail className="h-5 w-5 mr-2" />
                  Email
                </div>
                <p className="text-lg text-gray-900">{professional.email}</p>
              </div>
            </div>

            {/* Bio */}
            <div className="mt-8">
              <h2 className="text-xl font-semibold text-gray-900 mb-4">About</h2>
              <p className="text-gray-600 whitespace-pre-line">{professional.bio}</p>
            </div>

            {/* Specialties and Certifications */}
            <div className="mt-8 grid grid-cols-1 md:grid-cols-2 gap-8">
              <div>
                <h2 className="text-xl font-semibold text-gray-900 mb-4">Specialties</h2>
                <div className="flex flex-wrap gap-2">
                  {professional.specialties?.map((specialty) => (
                    <span
                      key={specialty}
                      className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800"
                    >
                      {specialty}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h2 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
                  <Award className="h-5 w-5 mr-2 text-coral-500" />
                  Certifications
                </h2>
                <div className="flex flex-wrap gap-2">
                  {professional.certifications?.map((certification) => (
                    <span
                      key={certification}
                      className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800"
                    >
                      {certification}
                    </span>
                  ))}
                </div>
              </div>
            </div>

            {/* Company Section - if part of a company */}
            {company && (
              <div className="mt-8 bg-gray-50 rounded-lg p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
                  <Building2 className="h-5 w-5 mr-2 text-coral-500" />
                  Company Information
                </h2>
                <p className="text-gray-600 mb-4">{company.description}</p>
                <div className="flex items-center justify-between">
                  <Link
                    to={`/company/${company.id}`}
                    className="text-navy-600 hover:text-navy-700 font-medium"
                  >
                    View Company Profile
                  </Link>
                  {company.is_hiring && (
                    <a
                      href={company.website}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700"
                    >
                      View Job Openings
                    </a>
                  )}
                </div>
              </div>
            )}

            {/* Projects */}
            {projects.length > 0 && (
              <div className="mt-12">
                <h2 className="text-2xl font-semibold text-gray-900 mb-6">
                  Projects by {professional.name}
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {projects.map(project => (
                    <Link
                      key={project.id}
                      to={`/project/${project.id}`}
                      className="group block bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-shadow"
                    >
                      <div className="relative h-48">
                        <img
                          src={project.image_url}
                          alt={project.title}
                          className="w-full h-full object-cover"
                        />
                        <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors"></div>
                      </div>
                      <div className="p-4">
                        <h3 className="font-semibold text-gray-900 group-hover:text-coral-500 transition-colors">
                          {project.title}
                        </h3>
                        <p className="text-sm text-gray-600 mt-1 line-clamp-2">
                          {project.description}
                        </p>
                        <div className="mt-4 flex items-center justify-between text-sm">
                          <div className="flex items-center text-gray-600">
                            <MapPin className="h-4 w-4 mr-1" />
                            {project.location}
                          </div>
                          {project.budget && (
                            <div className="flex items-center font-medium">
                              <DollarSign className="h-4 w-4 text-gray-400 mr-1" />
                              {project.budget.toLocaleString()}
                            </div>
                          )}
                        </div>
                      </div>
                    </Link>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}