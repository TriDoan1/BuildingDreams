import React, { useEffect, useState } from 'react';
import type { Project } from '../types';
import { Heart, MapPin, DollarSign } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';

export function TrendingProjects() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isVisible, setIsVisible] = useState<boolean[]>([]);
  const navigate = useNavigate();

  useEffect(() => {
    async function fetchProjects() {
      try {
        const { data: projectsData, error: projError } = await supabase
          .from('projects')
          .select(`
            *,
            professional:professionals!professional_id (
              user_id,
              users (
                name,
                image_url
              ),
              role,
              location,
              rating,
              verified
            )
          `)
          .order('likes', { ascending: false })
          .limit(9);

        if (projError) throw projError;

        const formattedProjects = projectsData?.map(project => ({
          id: project.id,
          title: project.title,
          description: project.description,
          image_url: project.image_url,
          likes: project.likes,
          budget: project.budget,
          location: project.location,
          latitude: project.latitude,
          longitude: project.longitude,
          professional: {
            id: project.professional.user_id,
            name: project.professional.users.name,
            role: project.professional.role,
            location: project.professional.location,
            rating: project.professional.rating,
            image_url: project.professional.users.image_url,
            verified: project.professional.verified
          }
        })) || [];

        setProjects(formattedProjects);
        setError(null);
      } catch (error) {
        console.error('Error fetching projects:', error);
        setError('Please connect to Supabase using the "Connect to Supabase" button in the top right corner.');
      } finally {
        setLoading(false);
      }
    }

    fetchProjects();
  }, []);

  useEffect(() => {
    const timer = setTimeout(() => {
      const observers = projects.map((_, index) => {
        return new IntersectionObserver(
          (entries) => {
            entries.forEach((entry) => {
              if (entry.isIntersecting) {
                setIsVisible(prev => {
                  const newState = [...prev];
                  newState[index] = true;
                  return newState;
                });
              }
            });
          },
          {
            threshold: 0.1,
            rootMargin: '50px',
          }
        );
      });

      const elements = document.querySelectorAll('.project-card');
      elements.forEach((element, index) => {
        if (observers[index]) {
          observers[index].observe(element);
        }
      });

      return () => {
        observers.forEach(observer => observer.disconnect());
      };
    }, 500);

    return () => clearTimeout(timer);
  }, [projects]);

  const handleProjectClick = (projectId: string) => {
    navigate(`/project/${projectId}`);
  };

  const handleProfessionalClick = (e: React.MouseEvent, professionalId: string) => {
    e.stopPropagation();
    navigate(`/profile/${professionalId}`);
  };

  if (error) {
    return (
      <section className="py-24 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-navy-900 mb-4">
              Connection Required
            </h2>
            <p className="text-lg text-gray-600">
              {error}
            </p>
          </div>
        </div>
      </section>
    );
  }

  if (loading) {
    return (
      <section className="py-24 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-8"></div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {[...Array(9)].map((_, i) => (
                <div key={i} className="bg-white rounded-lg shadow-sm overflow-hidden">
                  <div className="h-48 bg-gray-200"></div>
                  <div className="p-6">
                    <div className="h-6 bg-gray-200 rounded w-3/4 mb-4"></div>
                    <div className="h-4 bg-gray-200 rounded w-full mb-4"></div>
                    <div className="flex items-center">
                      <div className="h-10 w-10 rounded-full bg-gray-200"></div>
                      <div className="ml-3">
                        <div className="h-4 bg-gray-200 rounded w-24"></div>
                        <div className="h-3 bg-gray-200 rounded w-16 mt-2"></div>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>
    );
  }

  return (
    <section className="py-24 bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 className="text-3xl font-bold text-navy-900 mb-8">
          Featured <span className="text-coral-500">Builds</span>
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {projects.map((project, index) => (
            <div
              key={project.id}
              onClick={() => handleProjectClick(project.id)}
              className={`project-card bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-all duration-[1050ms] ease-out transform cursor-pointer ${
                isVisible[index] ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
              }`}
            >
              <div className="relative h-48">
                <img
                  className="h-full w-full object-cover"
                  src={project.image_url}
                  alt={project.title}
                />
                <div className="absolute top-4 right-4 flex items-center bg-white/90 backdrop-blur-sm rounded-full px-3 py-1">
                  <Heart className="h-4 w-4 text-coral-500 mr-1" />
                  <span className="text-sm font-medium">{project.likes}</span>
                </div>
              </div>
              <div className="p-6">
                <h3 className="text-xl font-semibold text-navy-900 mb-2">{project.title}</h3>
                <p className="text-gray-600 mb-4 line-clamp-2">{project.description}</p>
                <div className="flex items-center justify-between">
                  <div 
                    className="flex items-center cursor-pointer group"
                    onClick={(e) => handleProfessionalClick(e, project.professional.id)}
                  >
                    <img
                      className="h-10 w-10 rounded-full object-cover"
                      src={project.professional.image_url}
                      alt={project.professional.name}
                    />
                    <div className="ml-3">
                      <p className="text-sm font-medium text-navy-900 group-hover:text-coral-500 transition-colors">
                        {project.professional.name}
                      </p>
                      <p className="text-sm text-gray-500">{project.professional.role}</p>
                    </div>
                  </div>
                  <div className="flex flex-col items-end">
                    {project.budget && (
                      <div className="flex items-center text-sm">
                        <DollarSign className="h-4 w-4 text-gray-400 mr-1" />
                        <span className="font-medium">{project.budget.toLocaleString()}</span>
                      </div>
                    )}
                    <div className="flex items-center text-sm text-gray-500 mt-1">
                      <MapPin className="h-3 w-3 mr-1" />
                      <span>{project.location}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}