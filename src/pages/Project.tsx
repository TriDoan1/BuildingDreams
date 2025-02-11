import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { MapPin, Star, CheckCircle, MessageSquare, DollarSign, Building2 } from 'lucide-react';
import type { Project } from '../types';

export function Project() {
  const { id } = useParams();
  const [project, setProject] = useState<Project | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchProject() {
      try {
        const { data, error: queryError } = await supabase
          .from('projects')
          .select(`
            *,
            professional:professionals!professional_id (
              id,
              user_id,
              role,
              location,
              rating,
              verified,
              users (
                name,
                image_url
              ),
              projects (
                id,
                title,
                image_url,
                description,
                likes,
                budget,
                location
              )
            )
          `)
          .eq('id', id)
          .single();

        if (queryError) throw queryError;

        if (!data) {
          setError('Project not found');
          return;
        }

        setProject({
          id: data.id,
          title: data.title,
          description: data.description,
          image_url: data.image_url,
          likes: data.likes,
          budget: data.budget,
          location: data.location,
          professional: {
            id: data.professional.user_id,
            name: data.professional.users.name,
            role: data.professional.role,
            location: data.professional.location,
            rating: data.professional.rating,
            image_url: data.professional.users.image_url,
            verified: data.professional.verified,
            projects: data.professional.projects
          }
        });
      } catch (error) {
        console.error('Error fetching project:', error);
        setError('Failed to load project details');
      } finally {
        setLoading(false);
      }
    }

    if (id) {
      fetchProject();
    }
  }, [id]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 pt-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="animate-pulse">
            <div className="bg-white rounded-lg shadow-sm overflow-hidden">
              <div className="h-96 bg-gray-200"></div>
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

  if (error || !project) {
    return (
      <div className="min-h-screen bg-gray-50 pt-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-2">Error</h2>
            <p className="text-gray-600">{error || 'Project not found'}</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pt-24">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Project Details */}
        <div className="bg-white rounded-lg shadow-sm overflow-hidden">
          <div className="relative h-96">
            <img
              src={project.image_url}
              alt={project.title}
              className="w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent"></div>
            <div className="absolute bottom-0 left-0 right-0 p-8 text-white">
              <h1 className="text-4xl font-bold mb-2">{project.title}</h1>
              <div className="flex items-center space-x-4">
                <div className="flex items-center">
                  <MapPin className="h-5 w-5 mr-1" />
                  {project.location}
                </div>
                <div className="flex items-center">
                  <DollarSign className="h-5 w-5 mr-1" />
                  ${project.budget?.toLocaleString()}
                </div>
              </div>
            </div>
          </div>

          <div className="p-8">
            {/* Professional Info */}
            <div className="flex items-center justify-between mb-8 p-6 bg-gray-50 rounded-lg">
              <div className="flex items-center space-x-4">
                <Link to={`/profile/${project.professional.id}`}>
                  <img
                    src={project.professional.image_url}
                    alt={project.professional.name}
                    className="h-16 w-16 rounded-full object-cover border-2 border-white shadow-sm"
                  />
                </Link>
                <div>
                  <Link 
                    to={`/profile/${project.professional.id}`}
                    className="text-xl font-semibold text-gray-900 hover:text-coral-500 flex items-center"
                  >
                    {project.professional.name}
                    {project.professional.verified && (
                      <CheckCircle className="h-5 w-5 text-coral-500 ml-2" />
                    )}
                  </Link>
                  <p className="text-gray-600">{project.professional.role}</p>
                  <div className="flex items-center mt-1">
                    <Star className="h-4 w-4 text-yellow-400 mr-1" />
                    <span className="font-medium">{project.professional.rating}</span>
                  </div>
                </div>
              </div>
              <button className="inline-flex items-center px-4 py-2 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-coral-500 hover:bg-coral-600">
                <MessageSquare className="h-4 w-4 mr-2" />
                Contact Professional
              </button>
            </div>

            {/* Project Description */}
            <div className="prose max-w-none">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">About This Project</h2>
              <p className="text-gray-600 whitespace-pre-line">{project.description}</p>
            </div>

            {/* Other Projects by Professional */}
            {project.professional.projects && project.professional.projects.length > 1 && (
              <div className="mt-12">
                <h2 className="text-2xl font-semibold text-gray-900 mb-6">
                  More Projects by {project.professional.name}
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {project.professional.projects
                    .filter(p => p.id !== project.id)
                    .map(p => (
                      <Link
                        key={p.id}
                        to={`/project/${p.id}`}
                        className="group block bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-shadow"
                      >
                        <div className="relative h-48">
                          <img
                            src={p.image_url}
                            alt={p.title}
                            className="w-full h-full object-cover"
                          />
                          <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors"></div>
                        </div>
                        <div className="p-4">
                          <h3 className="font-semibold text-gray-900 group-hover:text-coral-500 transition-colors">
                            {p.title}
                          </h3>
                          <p className="text-sm text-gray-600 mt-1">{p.location}</p>
                          {p.budget && (
                            <p className="text-sm text-gray-600 mt-1">
                              Budget: ${p.budget.toLocaleString()}
                            </p>
                          )}
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