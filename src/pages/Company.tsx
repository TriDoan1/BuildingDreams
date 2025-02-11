import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { Building2, MapPin, Star, Users, Globe, Briefcase, CheckCircle } from 'lucide-react';
import type { User, Project } from '../types';
import { ProjectCard } from '../components/projects/ProjectCard';

interface CompanyProfile {
  id: string;
  name: string;
  description: string;
  location: string;
  website: string;
  is_hiring: boolean;
  latitude?: number;
  longitude?: number;
}

export function Company() {
  const { id } = useParams();
  const [company, setCompany] = useState<CompanyProfile | null>(null);
  const [employees, setEmployees] = useState<User[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [avgRating, setAvgRating] = useState<number>(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchData() {
      try {
        // First check if we can connect to Supabase
        const { error: healthCheckError } = await supabase.from('companies').select('count').limit(1);
        
        if (healthCheckError) {
          if (healthCheckError.message.includes('Failed to fetch')) {
            throw new Error('Please connect to Supabase using the "Connect to Supabase" button in the top right corner.');
          }
          throw healthCheckError;
        }

        // Fetch company details
        const { data: companyData, error: companyError } = await supabase
          .from('companies')
          .select('*')
          .eq('id', id)
          .single();

        if (companyError) throw companyError;

        if (!companyData) {
          setError('Company not found');
          return;
        }

        setCompany(companyData);

        // Fetch employees and their projects
        const { data: employeesData, error: employeesError } = await supabase
          .from('professionals')
          .select(`
            id,
            user_id,
            role,
            rating,
            verified,
            projects_completed,
            users (
              name,
              image_url
            ),
            projects (
              id,
              title,
              description,
              image_url,
              likes,
              budget,
              location
            )
          `)
          .eq('company_id', id);

        if (employeesError) throw employeesError;

        const formattedEmployees = employeesData.map(emp => ({
          id: emp.user_id,
          name: emp.users.name,
          avatar: emp.users.image_url,
          trade: emp.role,
          rating: emp.rating,
          verified: emp.verified,
          completedProjects: emp.projects_completed
        }));

        setEmployees(formattedEmployees);

        // Format and collect all projects
        const allProjects = employeesData.reduce((acc: Project[], emp) => {
          const employeeProjects = emp.projects?.map(project => ({
            ...project,
            professional: {
              id: emp.user_id,
              name: emp.users.name,
              role: emp.role,
              location: '',
              rating: emp.rating,
              image_url: emp.users.image_url,
              verified: emp.verified
            }
          })) || [];
          return [...acc, ...employeeProjects];
        }, []);

        // Sort projects by likes
        allProjects.sort((a, b) => (b.likes || 0) - (a.likes || 0));
        setProjects(allProjects);

        // Calculate average rating
        if (formattedEmployees.length > 0) {
          const avgRating = formattedEmployees.reduce((sum, emp) => sum + (emp.rating || 0), 0) / formattedEmployees.length;
          setAvgRating(Number(avgRating.toFixed(1)));
        }

      } catch (error: any) {
        console.error('Error fetching data:', error);
        setError(error.message || 'Failed to load company details');
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

  if (error || !company) {
    return (
      <div className="min-h-screen bg-gray-50 pt-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-2">Error</h2>
            <p className="text-gray-600">{error || 'Company not found'}</p>
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
            <div className="absolute bottom-8 left-8">
              <div className="flex items-center">
                <div className="h-16 w-16 bg-white rounded-lg flex items-center justify-center shadow-lg">
                  <Building2 className="h-10 w-10 text-navy-600" />
                </div>
                <div className="ml-6">
                  <h1 className="text-3xl font-bold text-white">{company.name}</h1>
                  <div className="flex items-center mt-2 text-white/80">
                    <MapPin className="h-5 w-5 mr-1" />
                    {company.location}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="p-8">
            {/* Company Stats */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
              <div className="bg-gray-50 rounded-lg p-4">
                <div className="flex items-center text-gray-600 mb-1">
                  <Users className="h-5 w-5 mr-2" />
                  Team Size
                </div>
                <p className="text-2xl font-bold text-gray-900">{employees.length} Professionals</p>
              </div>
              
              <div className="bg-gray-50 rounded-lg p-4">
                <div className="flex items-center text-gray-600 mb-1">
                  <Star className="h-5 w-5 mr-2" />
                  Average Rating
                </div>
                <p className="text-2xl font-bold text-gray-900">{avgRating}</p>
              </div>
              
              <div className="bg-gray-50 rounded-lg p-4">
                <div className="flex items-center text-gray-600 mb-1">
                  <Globe className="h-5 w-5 mr-2" />
                  Website
                </div>
                <a
                  href={company.website}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-navy-600 hover:text-navy-700"
                >
                  Visit Website
                </a>
              </div>
            </div>

            {/* Company Description */}
            <div className="mb-12">
              <h2 className="text-xl font-semibold text-gray-900 mb-4">About {company.name}</h2>
              <p className="text-gray-600">{company.description}</p>
              
              {company.is_hiring && (
                <div className="mt-6">
                  <a
                    href={company.website}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center px-6 py-3 border border-transparent rounded-lg shadow-sm text-base font-medium text-white bg-green-600 hover:bg-green-700"
                  >
                    <Briefcase className="h-5 w-5 mr-2" />
                    View Job Openings
                  </a>
                </div>
              )}
            </div>

            {/* Team Members */}
            <div className="mb-12">
              <h2 className="text-xl font-semibold text-gray-900 mb-6">Our Team</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {employees.map(employee => (
                  <Link
                    key={employee.id}
                    to={`/profile/${employee.id}`}
                    className="block bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-shadow"
                  >
                    <div className="p-6">
                      <div className="flex items-center">
                        <img
                          src={employee.avatar}
                          alt={employee.name}
                          className="h-12 w-12 rounded-full object-cover"
                        />
                        <div className="ml-4">
                          <h3 className="text-lg font-medium text-gray-900 flex items-center">
                            {employee.name}
                            {employee.verified && (
                              <CheckCircle className="h-4 w-4 text-coral-500 ml-1" />
                            )}
                          </h3>
                          <p className="text-sm text-gray-500">{employee.trade}</p>
                        </div>
                      </div>
                      <div className="mt-4 flex items-center justify-between text-sm">
                        <div className="flex items-center">
                          <Star className="h-4 w-4 text-yellow-400 mr-1" />
                          <span>{employee.rating}</span>
                        </div>
                        <span className="text-gray-500">
                          {employee.completedProjects}+ projects
                        </span>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            </div>

            {/* Projects */}
            {projects.length > 0 && (
              <div>
                <h2 className="text-xl font-semibold text-gray-900 mb-6">Featured Projects</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {projects.map(project => (
                    <ProjectCard key={project.id} project={project} />
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