import React, { useState, useEffect } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { LocationMap } from '../components/map/LocationMap';
import { AlertCircle, List, Map as MapIcon, Building2, MapPin, Users, Globe, Filter } from 'lucide-react';
import { SearchSuggestions } from '../components/search/SearchSuggestions';

interface Company {
  id: string;
  name: string;
  description: string;
  location: string;
  website: string;
  latitude?: number;
  longitude?: number;
  employeeCount: number;
  is_hiring: boolean;
}

interface EmployerFilters {
  minEmployees: number;
  maxEmployees: number;
  zipcode: string;
  radius: number;
  specialties: string[];
}

// Function to calculate distance between two points using Haversine formula
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 3959; // Earth's radius in miles
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c; // Distance in miles
}

// Function to get coordinates from zipcode
async function getZipCodeCoordinates(zipcode: string): Promise<{lat: number, lng: number} | null> {
  // For this example, we'll focus on Orange County area zipcodes
  const zipCodeMap: {[key: string]: {lat: number, lng: number}} = {
    '92602': {lat: 33.7363, lng: -117.7947}, // Irvine
    '92603': {lat: 33.6411, lng: -117.7831}, // Irvine
    '92604': {lat: 33.6846, lng: -117.8265}, // Irvine
    '92612': {lat: 33.6513, lng: -117.8443}, // Irvine
    '92614': {lat: 33.6695, lng: -117.8309}, // Irvine
    '92617': {lat: 33.6405, lng: -117.8443}, // Irvine
    '92618': {lat: 33.6695, lng: -117.7468}, // Irvine
    '92620': {lat: 33.7219, lng: -117.7468}, // Irvine
    '92626': {lat: 33.6834, lng: -117.9167}, // Costa Mesa
    '92627': {lat: 33.6428, lng: -117.9167}, // Costa Mesa
    '92646': {lat: 33.6595, lng: -117.9988}, // Huntington Beach
    '92647': {lat: 33.7192, lng: -117.9988}, // Huntington Beach
    '92648': {lat: 33.6783, lng: -118.0038}, // Huntington Beach
    '92649': {lat: 33.7247, lng: -118.0488}, // Huntington Beach
    '92660': {lat: 33.6189, lng: -117.8814}, // Newport Beach
    '92661': {lat: 33.6068, lng: -117.8987}, // Newport Beach
    '92662': {lat: 33.6036, lng: -117.8987}, // Newport Beach
    '92663': {lat: 33.6189, lng: -117.9289}, // Newport Beach
    '92657': {lat: 33.5975, lng: -117.8417}, // Newport Coast
    '92625': {lat: 33.5975, lng: -117.8814}, // Corona del Mar
    '92651': {lat: 33.5422, lng: -117.7831}, // Laguna Beach
    '92677': {lat: 33.5225, lng: -117.7075}, // Laguna Niguel
    '92656': {lat: 33.5667, lng: -117.7075}, // Aliso Viejo
    '92675': {lat: 33.5017, lng: -117.6625}, // San Juan Capistrano
    '92624': {lat: 33.4669, lng: -117.6981}, // Dana Point
    '92673': {lat: 33.4269, lng: -117.6119}, // San Clemente
    '92691': {lat: 33.6100, lng: -117.6719}, // Mission Viejo
    '92692': {lat: 33.6000, lng: -117.6719}, // Mission Viejo
  };

  return zipCodeMap[zipcode] || null;
}

export function FindEmployers() {
  const [searchParams, setSearchParams] = useSearchParams();
  const searchQuery = searchParams.get('q') || '';
  const [searchTerm, setSearchTerm] = useState(searchQuery);
  const [companies, setCompanies] = useState<Company[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'list' | 'map'>('list');
  const [filters, setFilters] = useState<EmployerFilters>({
    minEmployees: 0,
    maxEmployees: 1000,
    zipcode: '',
    radius: 0,
    specialties: []
  });

  useEffect(() => {
    if (searchQuery) {
      setSearchTerm(searchQuery);
    }
  }, [searchQuery]);

  useEffect(() => {
    async function fetchCompanies() {
      setLoading(true);
      try {
        // First check if we can connect to Supabase
        const { error: healthCheckError } = await supabase.from('companies').select('count').limit(1);
        
        if (healthCheckError) {
          if (healthCheckError.message.includes('Failed to fetch')) {
            throw new Error('Please connect to Supabase using the "Connect to Supabase" button in the top right corner.');
          }
          throw healthCheckError;
        }

        // Get companies that are hiring
        let query = supabase
          .from('companies')
          .select(`
            *,
            professionals!company_id (
              id
            )
          `)
          .eq('is_hiring', true);

        if (searchQuery) {
          query = query.or(`name.ilike.%${searchQuery}%,description.ilike.%${searchQuery}%`);
        }

        const { data, error: queryError } = await query;

        if (queryError) throw queryError;

        if (!data) {
          setCompanies([]);
          return;
        }

        let formattedCompanies = data.map(company => ({
          id: company.id,
          name: company.name,
          description: company.description,
          location: company.location,
          website: company.website,
          latitude: company.latitude,
          longitude: company.longitude,
          employeeCount: (company.professionals || []).length,
          is_hiring: company.is_hiring
        }));

        // Apply employee count filters
        if (filters.minEmployees > 0) {
          formattedCompanies = formattedCompanies.filter(
            company => company.employeeCount >= filters.minEmployees
          );
        }

        if (filters.maxEmployees < 1000) {
          formattedCompanies = formattedCompanies.filter(
            company => company.employeeCount <= filters.maxEmployees
          );
        }

        // Apply radius filter if zipcode is provided
        if (filters.zipcode && filters.radius > 0) {
          const coords = await getZipCodeCoordinates(filters.zipcode);
          if (coords) {
            formattedCompanies = formattedCompanies.filter(company => {
              if (company.latitude && company.longitude) {
                const distance = calculateDistance(
                  coords.lat,
                  coords.lng,
                  company.latitude,
                  company.longitude
                );
                return distance <= filters.radius;
              }
              return false;
            });
          }
        }

        setCompanies(formattedCompanies);
        setError(null);
      } catch (error: any) {
        console.error('Error fetching companies:', error);
        setError(error.message || 'An error occurred while searching. Please try again.');
      } finally {
        setLoading(false);
      }
    }

    fetchCompanies();
  }, [searchQuery, filters]);

  const handleSearch = (term: string) => {
    setSearchParams({ q: term });
  };

  const handleFilterChange = (newFilters: EmployerFilters) => {
    setFilters(newFilters);
  };

  const renderCompanyInfoWindow = (company: Company) => (
    <div className="p-4 max-w-sm">
      <h3 className="text-lg font-semibold mb-2">{company.name}</h3>
      <p className="text-sm text-gray-600 mb-2">{company.description}</p>
      <div className="flex items-center justify-between text-sm">
        <div className="flex items-center">
          <Users className="h-4 w-4 text-gray-400 mr-1" />
          <span>{company.employeeCount} employees</span>
        </div>
        <span className="text-green-600 font-medium">Hiring</span>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-gray-50 pt-24">
      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <SearchSuggestions
            searchTerm={searchTerm}
            onSearch={handleSearch}
            onTermChange={setSearchTerm}
            placeholder="Search companies by name or description..."
            className="max-w-2xl mx-auto"
          />
        </div>

        <div className="flex flex-col md:flex-row gap-8">
          <div className="md:w-80">
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <div className="flex items-center mb-4">
                <Filter className="h-5 w-5 text-[#1f4968] mr-2" />
                <h2 className="text-lg font-semibold">Filters</h2>
              </div>
              
              <div className="space-y-6">
                {/* Company Size Filter */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    <div className="flex items-center">
                      <Users className="h-4 w-4 text-[#1f4968] mr-1" />
                      Company Size
                    </div>
                  </label>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs text-gray-500 mb-1">Min Employees</label>
                      <input
                        type="number"
                        min="0"
                        value={filters.minEmployees}
                        onChange={(e) => handleFilterChange({ 
                          ...filters, 
                          minEmployees: parseInt(e.target.value) || 0 
                        })}
                        className="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-500 mb-1">Max Employees</label>
                      <input
                        type="number"
                        min="0"
                        value={filters.maxEmployees}
                        onChange={(e) => handleFilterChange({ 
                          ...filters, 
                          maxEmployees: parseInt(e.target.value) || 1000 
                        })}
                        className="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                  </div>
                </div>

                {/* Location Filter */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    <div className="flex items-center">
                      <MapPin className="h-4 w-4 text-[#1f4968] mr-1" />
                      Location
                    </div>
                  </label>
                  <div className="space-y-2">
                    <input
                      type="text"
                      value={filters.zipcode}
                      onChange={(e) => handleFilterChange({
                        ...filters,
                        zipcode: e.target.value.trim()
                      })}
                      placeholder="Enter zipcode"
                      maxLength={5}
                      className="w-full border rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 px-3 py-2"
                    />
                    <input
                      type="range"
                      min="0"
                      max="250"
                      step="5"
                      value={filters.radius}
                      onChange={(e) => handleFilterChange({ 
                        ...filters, 
                        radius: parseInt(e.target.value)
                      })}
                      className="w-full"
                    />
                    <div className="text-sm text-gray-600">
                      {filters.radius === 0 ? 'Any distance' : `Within ${filters.radius} miles`}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="flex-1">
            <div className="mb-6">
              <div className="flex items-center justify-between">
                <div>
                  <h1 className="text-3xl font-bold text-gray-900">Find Employers</h1>
                  {searchQuery && (
                    <p className="mt-2 text-gray-600">
                      Showing results for "{searchQuery}"
                    </p>
                  )}
                </div>
                <div className="flex items-center gap-4">
                  {companies.length > 0 && (
                    <p className="text-sm text-gray-500">
                      {companies.length} company{companies.length !== 1 ? 'ies' : 'y'} hiring
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
              <div className="space-y-4">
                {[...Array(4)].map((_, i) => (
                  <div key={i} className="bg-white rounded-lg shadow-sm p-6 animate-pulse">
                    <div className="flex items-center space-x-4">
                      <div className="h-12 w-12 bg-gray-200 rounded-lg"></div>
                      <div className="flex-1">
                        <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
                        <div className="h-3 bg-gray-200 rounded w-1/2"></div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : companies.length > 0 ? (
              viewMode === 'list' ? (
                <div className="space-y-4">
                  {companies.map((company) => (
                    <div key={company.id} className="block bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow">
                      <div className="flex justify-between items-start">
                        <Link
                          to={`/company/${company.id}`}
                          className="flex items-start space-x-4 flex-1"
                        >
                          <div className="h-12 w-12 bg-gray-50 rounded-lg flex items-center justify-center">
                            <Building2 className="h-6 w-6 text-gray-600" />
                          </div>
                          <div>
                            <h3 className="text-xl font-semibold text-gray-900">{company.name}</h3>
                            <p className="mt-1 text-gray-600">{company.description}</p>
                            <div className="mt-2 flex items-center space-x-4">
                              <div className="flex items-center text-sm">
                                <Users className="h-4 w-4 text-gray-400 mr-1" />
                                <span>{company.employeeCount} employees</span>
                              </div>
                              <div className="flex items-center text-sm">
                                <MapPin className="h-4 w-4 text-gray-400 mr-1" />
                                <span className="text-gray-600">{company.location}</span>
                              </div>
                            </div>
                          </div>
                        </Link>
                        <div className="flex flex-col items-end">
                          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                            Hiring
                          </span>
                          {company.website && (
                            <a
                              href={company.website}
                              target="_blank"
                              rel="noopener noreferrer"
                              onClick={(e) => e.stopPropagation()}
                              className="mt-2 inline-flex items-center text-sm text-gray-500 hover:text-gray-700"
                            >
                              <Globe className="h-4 w-4 mr-1" />
                              Website
                            </a>
                          )}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <LocationMap
                  items={companies}
                  getCoordinates={(company) => company.latitude && company.longitude ? {
                    lat: company.latitude,
                    lng: company.longitude
                  } : null}
                  renderInfoWindow={renderCompanyInfoWindow}
                  getMarkerIcon={() => ({
                    url: '/marker.svg',
                    scaledSize: new google.maps.Size(30, 30),
                    anchor: new google.maps.Point(15, 15),
                    labelOrigin: new google.maps.Point(15, 15)
                  })}
                />
              )
            ) : (
              <div className="text-center py-12 bg-white rounded-lg shadow-sm">
                <h3 className="mt-4 text-lg font-medium text-gray-900">No companies found</h3>
                <p className="mt-2 text-gray-500">
                  No companies match your search criteria.
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