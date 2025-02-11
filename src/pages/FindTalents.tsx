import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { ProfessionalCard } from '../components/directory/ProfessionalCard';
import { SearchFilters } from '../components/directory/SearchFilters';
import { LocationMap } from '../components/map/LocationMap';
import { AlertCircle, List, Map as MapIcon } from 'lucide-react';
import { SearchSuggestions } from '../components/search/SearchSuggestions';
import type { SearchFilters as SearchFiltersType, User } from '../types';
import { getProfessionalMarkerIcon, getProfessionalCoordinates } from '../config/mapMarkers';

const ITEMS_PER_PAGE = 24;

export function FindTalents() {
  const [searchParams, setSearchParams] = useSearchParams();
  const searchQuery = searchParams.get('q') || '';
  const [searchTerm, setSearchTerm] = useState(searchQuery);
  const [professionals, setProfessionals] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'list' | 'map'>('list');
  const [page, setPage] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [filters, setFilters] = useState<SearchFiltersType>({
    rating: 0,
    certifications: [],
    specialties: [],
    radius: 0,
    zipcode: ''
  });

  useEffect(() => {
    if (searchQuery) {
      setSearchTerm(searchQuery);
    }
  }, [searchQuery]);

  useEffect(() => {
    async function searchProfessionals() {
      setLoading(true);
      try {
        let query = supabase
          .from('professionals')
          .select(`
            id,
            user_id,
            users (
              name,
              image_url,
              phone,
              email
            ),
            role,
            location,
            rating,
            verified,
            hourly_rate,
            projects_completed,
            bio,
            latitude,
            longitude,
            professional_specialties (
              specialty
            ),
            professional_certifications (
              certification,
              issued_date,
              expiry_date
            )
          `);

        // Apply search query if present
        if (searchQuery) {
          query = query.or(`role.ilike.%${searchQuery}%,name.ilike.%${searchQuery}%`);
        }

        // Apply rating filter if set
        if (filters.rating > 0) {
          query = query.gte('rating', filters.rating);
        }

        const { data, error: queryError } = await query;

        if (queryError) throw queryError;

        if (!data) {
          setProfessionals([]);
          return;
        }

        let filteredProfessionals = data.map(prof => ({
          id: prof.user_id,
          name: prof.users.name,
          avatar: prof.users.image_url,
          trade: prof.role,
          location: prof.location,
          rating: prof.rating,
          verified: prof.verified,
          hourlyRate: prof.hourly_rate,
          specialties: prof.professional_specialties?.map((s: any) => s.specialty) || [],
          certifications: prof.professional_certifications?.map((c: any) => c.certification) || [],
          completedProjects: prof.projects_completed,
          bio: prof.bio,
          coordinates: prof.latitude && prof.longitude ? {
            lat: prof.latitude,
            lng: prof.longitude
          } : null
        }));

        // Filter by certifications
        if (filters.certifications.length > 0) {
          filteredProfessionals = filteredProfessionals.filter(prof => 
            filters.certifications.every(cert => 
              prof.certifications?.includes(cert)
            )
          );
        }

        // Filter by specialties
        if (filters.specialties.length > 0) {
          filteredProfessionals = filteredProfessionals.filter(prof => 
            filters.specialties.every(specialty => 
              prof.specialties?.includes(specialty)
            )
          );
        }

        setProfessionals(filteredProfessionals);
        setTotalCount(filteredProfessionals.length);
        setError(null);
      } catch (error: any) {
        console.error('Error searching professionals:', error);
        setError(error.message || 'An error occurred while searching. Please try again.');
      } finally {
        setLoading(false);
      }
    }

    searchProfessionals();
  }, [searchQuery, filters]);

  const handleSearch = (term: string) => {
    setSearchParams({ q: term });
    setPage(1);
  };

  const handleFilterChange = (newFilters: SearchFiltersType) => {
    setFilters(newFilters);
    setPage(1);
  };

  const renderProfessionalInfoWindow = (professional: User) => (
    <ProfessionalCard
      professional={professional}
      compact={true}
    />
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
            placeholder="Search professionals by name or trade..."
            className="max-w-2xl mx-auto"
          />
        </div>

        <div className="flex flex-col md:flex-row gap-8">
          <div className="md:w-80">
            <SearchFilters
              filters={filters}
              onFilterChange={handleFilterChange}
            />
          </div>
          
          <div className="flex-1">
            <div className="mb-6">
              <div className="flex items-center justify-between">
                <div>
                  <h1 className="text-3xl font-bold text-gray-900">Find Professionals</h1>
                  {searchQuery && (
                    <p className="mt-2 text-gray-600">
                      Showing results for "{searchQuery}"
                    </p>
                  )}
                </div>
                <div className="flex items-center gap-4">
                  {professionals.length > 0 && (
                    <p className="text-sm text-gray-500">
                      {professionals.length} professional{professionals.length !== 1 ? 's' : ''} found
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
                <div className="flex items-start">
                  <AlertCircle className="h-5 w-5 text-red-400 mt-0.5" />
                  <div className="ml-3">
                    <h3 className="text-sm font-medium text-red-800">Error</h3>
                    <p className="mt-2 text-sm text-red-700">{error}</p>
                  </div>
                </div>
              </div>
            ) : loading ? (
              viewMode === 'list' ? (
                <div className="space-y-4">
                  {[...Array(4)].map((_, i) => (
                    <div key={i} className="bg-white rounded-lg shadow-sm p-6 animate-pulse">
                      <div className="flex items-center space-x-4">
                        <div className="h-12 w-12 bg-gray-200 rounded-full"></div>
                        <div className="flex-1">
                          <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
                          <div className="h-3 bg-gray-200 rounded w-1/2"></div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="bg-white rounded-lg shadow-sm p-4 animate-pulse">
                  <div className="h-[600px] bg-gray-200 rounded-lg"></div>
                </div>
              )
            ) : professionals.length > 0 ? (
              viewMode === 'list' ? (
                <div className="space-y-4">
                  {professionals
                    .slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE)
                    .map((professional) => (
                      <ProfessionalCard
                        key={professional.id}
                        professional={professional}
                        listView={true}
                      />
                    ))}
                  
                  {/* Pagination */}
                  {totalPages > 1 && (
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
                </div>
              ) : (
                <LocationMap
                  items={professionals}
                  getCoordinates={getProfessionalCoordinates}
                  renderInfoWindow={renderProfessionalInfoWindow}
                  getMarkerIcon={getProfessionalMarkerIcon}
                />
              )
            ) : (
              <div className="text-center py-12 bg-white rounded-lg shadow-sm">
                <h3 className="mt-4 text-lg font-medium text-gray-900">No results found</h3>
                <p className="mt-2 text-gray-500">
                  No professionals found matching your search criteria.
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