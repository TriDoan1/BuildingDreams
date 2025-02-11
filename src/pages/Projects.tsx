import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useSearchParams } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { ProjectCard } from '../components/projects/ProjectCard';
import { ProjectFilters } from '../components/projects/ProjectFilters';
import { LocationMap } from '../components/map/LocationMap';
import { AlertCircle, List, Map as MapIcon } from 'lucide-react';
import { SearchSuggestions } from '../components/search/SearchSuggestions';
import type { SearchFilters as SearchFiltersType, Project } from '../types';
import { getProjectMarkerIcon, getProjectCoordinates } from '../config/mapMarkers';

const ITEMS_PER_PAGE = 24;

export function Projects() {
  const [searchParams, setSearchParams] = useSearchParams();
  const searchQuery = searchParams.get('q') || '';
  const [searchTerm, setSearchTerm] = useState(searchQuery);
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'list' | 'map'>('list');
  const [page, setPage] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [filters, setFilters] = useState<SearchFiltersType>({
    minBudget: 0,
    maxBudget: 1000000,
    zipcode: '',
    radius: 0
  });

  useEffect(() => {
    if (searchQuery) {
      setSearchTerm(searchQuery);
    }
  }, [searchQuery]);

  useEffect(() => {
    async function fetchProjects() {
      setLoading(true);
      try {
        // First get total count
        const countQuery = supabase
          .from('projects')
          .select('id', { count: 'exact' });

        if (searchQuery) {
          countQuery.or('title.ilike.%' + searchQuery + '%,description.ilike.%' + searchQuery + '%');
        }

        countQuery
          .gte('budget', filters.minBudget)
          .lte('budget', filters.maxBudget);

        const { count, error: countError } = await countQuery;
        
        if (countError) throw countError;
        
        setTotalCount(count || 0);

        // Then fetch paginated data
        let query = supabase
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
              )
            )
          `);

        if (searchQuery) {
          query = query.or('title.ilike.%' + searchQuery + '%,description.ilike.%' + searchQuery + '%');
        }

        // Apply budget filter
        query = query
          .gte('budget', filters.minBudget)
          .lte('budget', filters.maxBudget)
          .order('created_at', { ascending: false });

        // Only apply range for list view to maintain map view performance
        if (viewMode === 'list') {
          query = query.range((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE - 1);
        }

        const { data, error: queryError } = await query;

        if (queryError) throw queryError;

        if (!data) {
          setProjects([]);
          return;
        }

        const formattedProjects = data.map(project => ({
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
        }));

        setProjects(formattedProjects);
        setError(null);
      } catch (error: any) {
        console.error('Error fetching projects:', error);
        setError(error.message || 'An error occurred while searching. Please try again.');
      } finally {
        setLoading(false);
      }
    }

    fetchProjects();
  }, [searchQuery, filters, page, viewMode]);

  const handleSearch = (term: string) => {
    setSearchParams({ q: term });
    setPage(1);
  };

  const handleFilterChange = (newFilters: SearchFiltersType) => {
    setFilters(newFilters);
    setPage(1);
  };

  const renderProjectInfoWindow = (project: Project) => (
    <ProjectCard project={project} />
  );

  const totalPages = Math.ceil(totalCount / ITEMS_PER_PAGE);

  return (
    <div className="min-h-screen bg-gray-50 pt-24">
      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <SearchSuggestions
            searchTerm={searchTerm}
            onSearch={handleSearch}
            onTermChange={setSearchTerm}
            placeholder="Search projects by title or description..."
            className="max-w-2xl mx-auto"
          />
        </div>

        <div className="flex flex-col md:flex-row gap-8">
          <div className="md:w-80">
            <ProjectFilters
              filters={filters}
              onFilterChange={handleFilterChange}
            />
          </div>
          
          <div className="flex-1">
            <div className="mb-6">
              <div className="flex items-center justify-between">
                <div>
                  <h1 className="text-3xl font-bold text-gray-900">Projects</h1>
                  {searchQuery && (
                    <p className="mt-2 text-gray-600">
                      Showing results for "{searchQuery}"
                    </p>
                  )}
                </div>
                <div className="flex items-center gap-4">
                  {totalCount > 0 && (
                    <p className="text-sm text-gray-500">
                      {totalCount} project{totalCount !== 1 ? 's' : ''} found
                    </p>
                  )}
                  <div className="flex rounded-lg shadow-sm">
                    <button
                      onClick={() => setViewMode('list')}
                      className={`px-3 py-2 text-sm font-medium rounded-l-lg ${
                        viewMode === 'list'
                          ? 'bg-coral-500 text-white'
                          : 'bg-white text-gray-700 hover:bg-gray-50'
                      }`}
                    >
                      <List className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => setViewMode('map')}
                      className={`px-3 py-2 text-sm font-medium rounded-r-lg ${
                        viewMode === 'map'
                          ? 'bg-coral-500 text-white'
                          : 'bg-white text-gray-700 hover:bg-gray-50'
                      }`}
                    >
                      <MapIcon className="h-4 w-4" />
                    </button>
                  </div>
                </div>
              </div>
            </div>

            {error ? (
              <div className="rounded-lg bg-red-50 p-4">
                <div className="flex">
                  <AlertCircle className="h-5 w-5 text-red-400" />
                  <p className="ml-3 text-sm text-red-700">{error}</p>
                </div>
              </div>
            ) : loading ? (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {[...Array(6)].map((_, i) => (
                  <div key={i} className="bg-white rounded-lg shadow-sm p-4 animate-pulse">
                    <div className="h-48 bg-gray-200 rounded-lg mb-4"></div>
                    <div className="space-y-3">
                      <div className="h-6 bg-gray-200 rounded w-3/4"></div>
                      <div className="h-4 bg-gray-200 rounded w-full"></div>
                      <div className="h-4 bg-gray-200 rounded w-5/6"></div>
                    </div>
                  </div>
                ))}
              </div>
            ) : projects.length > 0 ? (
              <>
                {viewMode === 'list' ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {projects.map((project) => (
                      <ProjectCard key={project.id} project={project} />
                    ))}
                  </div>
                ) : (
                  <LocationMap
                    items={projects}
                    getCoordinates={getProjectCoordinates}
                    renderInfoWindow={renderProjectInfoWindow}
                    getMarkerIcon={getProjectMarkerIcon}
                  />
                )}

                {/* Pagination - only show in list view */}
                {viewMode === 'list' && totalPages > 1 && (
                  <div className="mt-8 flex justify-center">
                    <nav className="flex items-center space-x-2">
                      <button
                        onClick={() => setPage(p => Math.max(1, p - 1))}
                        disabled={page === 1}
                        className="p-2 rounded-lg bg-white shadow-sm text-gray-600 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                        </svg>
                      </button>
                      
                      <div className="flex items-center space-x-1">
                        {[...Array(totalPages)].map((_, i) => (
                          <button
                            key={i}
                            onClick={() => setPage(i + 1)}
                            className={`px-4 py-2 rounded-lg ${
                              page === i + 1
                                ? 'bg-coral-500 text-white'
                                : 'bg-white text-gray-600 hover:bg-gray-50'
                            }`}
                          >
                            {i + 1}
                          </button>
                        ))}
                      </div>

                      <button
                        onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                        disabled={page === totalPages}
                        className="p-2 rounded-lg bg-white shadow-sm text-gray-600 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                        </svg>
                      </button>
                    </nav>
                  </div>
                )}
              </>
            ) : (
              <div className="text-center py-12 bg-white rounded-lg shadow-sm">
                <h3 className="mt-4 text-lg font-medium text-gray-900">No projects found</h3>
                <p className="mt-2 text-gray-500">
                  No projects match your search criteria.
                </p>
                <p className="text-gray-400 mt-1">
                  Try adjusting your filters or using different search terms
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}