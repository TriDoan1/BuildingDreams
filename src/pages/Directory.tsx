import React, { useState } from 'react';
import { SearchFilters } from '../components/directory/SearchFilters';
import { ProfessionalCard } from '../components/directory/ProfessionalCard';
import type { SearchFilters as SearchFiltersType, User } from '../types';

const MOCK_PROFESSIONALS: User[] = [
  {
    id: '1',
    name: 'David Chen',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=facearea&facepad=2&w=256&h=256',
    trade: 'General Contractor',
    location: 'New York, NY',
    rating: 4.9,
    verified: true,
    hourlyRate: 85,
    availability: 'immediate',
    certifications: ['OSHA Certified', 'Licensed Contractor'],
    specialties: ['Commercial Renovation', 'Project Management'],
    completedProjects: 127,
    bio: 'Experienced general contractor specializing in commercial renovations and project management.'
  },
  {
    id: '2',
    name: 'Sarah Miller',
    avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=facearea&facepad=2&w=256&h=256',
    trade: 'Master Electrician',
    location: 'Los Angeles, CA',
    rating: 4.8,
    verified: true,
    hourlyRate: 95,
    availability: 'within-week',
    certifications: ['Master Electrician', 'OSHA Certified'],
    specialties: ['Industrial Wiring', 'Smart Home Integration'],
    completedProjects: 89,
    bio: 'Master electrician with expertise in industrial wiring and smart home technology.'
  },
  {
    id: '3',
    name: 'Michael Rodriguez',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=facearea&facepad=2&w=256&h=256',
    trade: 'HVAC Technician',
    location: 'Chicago, IL',
    rating: 4.7,
    verified: true,
    hourlyRate: 75,
    availability: 'within-month',
    certifications: ['HVAC Certified', 'EPA Certified'],
    specialties: ['Commercial HVAC', 'Green Energy Systems'],
    completedProjects: 156,
    bio: 'Specialized in commercial HVAC systems and green energy solutions.'
  }
];

export function Directory() {
  const [filters, setFilters] = useState<SearchFiltersType>({
    trade: 'All Trades',
    location: 'All Locations',
    rating: 4,
    availability: 'any',
    certification: 'All Certifications',
    priceRange: [0, 200]
  });

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="flex flex-col md:flex-row gap-8">
          <div className="md:w-80">
            <SearchFilters
              filters={filters}
              onFilterChange={setFilters}
            />
          </div>
          
          <div className="flex-1">
            <div className="mb-6">
              <h1 className="text-3xl font-bold text-gray-900">Find Professionals</h1>
              <p className="mt-2 text-gray-600">Connect with skilled tradespeople in your area</p>
            </div>
            
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {MOCK_PROFESSIONALS.map((professional) => (
                <ProfessionalCard
                  key={professional.id}
                  professional={professional}
                />
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}