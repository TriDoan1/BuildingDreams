import React, { useState, useEffect } from 'react';
import { Filter, Star, MapPin, X } from 'lucide-react';
import { supabase } from '../../lib/supabase';
import type { SearchFilters } from '../../types';

interface Props {
  filters: SearchFilters;
  onFilterChange: (filters: SearchFilters) => void;
}

export function SearchFilters({ filters, onFilterChange }: Props) {
  const [zipcode, setZipcode] = useState('');
  const [zipcodeError, setZipcodeError] = useState('');
  const [availableCertifications, setAvailableCertifications] = useState<string[]>([]);
  const [availableSpecialties, setAvailableSpecialties] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        // Fetch certifications
        const { data: certData, error: certError } = await supabase
          .from('professional_certifications')
          .select('certification')
          .order('certification');

        if (certError) throw certError;

        // Fetch specialties
        const { data: specData, error: specError } = await supabase
          .from('professional_specialties')
          .select('specialty')
          .order('specialty');

        if (specError) throw specError;

        // Get unique values
        const uniqueCertifications = Array.from(new Set(certData.map(item => item.certification)));
        const uniqueSpecialties = Array.from(new Set(specData.map(item => item.specialty)));

        setAvailableCertifications(uniqueCertifications);
        setAvailableSpecialties(uniqueSpecialties);
      } catch (error) {
        console.error('Error fetching data:', error);
      } finally {
        setIsLoading(false);
      }
    }

    fetchData();
  }, []);

  const validateZipcode = (zip: string) => {
    const zipRegex = /^\d{5}$/;
    return zipRegex.test(zip);
  };

  const handleZipcodeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value.trim();
    setZipcode(value);
    
    if (value && !validateZipcode(value)) {
      setZipcodeError('Please enter a valid 5-digit zipcode');
    } else {
      setZipcodeError('');
      onFilterChange({ ...filters, zipcode: value });
    }
  };

  const handleCertificationAdd = (certification: string) => {
    if (!filters.certifications.includes(certification)) {
      onFilterChange({
        ...filters,
        certifications: [...filters.certifications, certification]
      });
    }
  };

  const handleCertificationRemove = (certification: string) => {
    onFilterChange({
      ...filters,
      certifications: filters.certifications.filter(cert => cert !== certification)
    });
  };

  const handleSpecialtyAdd = (specialty: string) => {
    if (!filters.specialties.includes(specialty)) {
      onFilterChange({
        ...filters,
        specialties: [...filters.specialties, specialty]
      });
    }
  };

  const handleSpecialtyRemove = (specialty: string) => {
    onFilterChange({
      ...filters,
      specialties: filters.specialties.filter(spec => spec !== specialty)
    });
  };

  const handleRatingChange = (value: number) => {
    // Ensure rating is between 0 and 5
    const rating = Math.max(0, Math.min(5, value));
    onFilterChange({ ...filters, rating });
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-sm">
      <div className="flex items-center mb-4">
        <Filter className="h-5 w-5 text-[#1f4968] mr-2" />
        <h2 className="text-lg font-semibold">Filters</h2>
      </div>
      
      <div className="space-y-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            <div className="flex items-center">
              <Star className="h-4 w-4 text-[#1f4968] mr-1" />
              Minimum Rating
            </div>
          </label>
          <div className="flex items-center space-x-4">
            <input
              type="range"
              min="0"
              max="5"
              step="0.5"
              value={filters.rating}
              onChange={(e) => handleRatingChange(parseFloat(e.target.value))}
              className="flex-1"
            />
            <span className="text-sm text-gray-600 min-w-[4rem]">
              {filters.rating === 0 ? 'Any' : `${filters.rating}+`}
            </span>
          </div>
        </div>

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
              value={zipcode}
              onChange={handleZipcodeChange}
              placeholder="Enter zipcode"
              maxLength={5}
              className={`w-full border rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 px-3 py-2 ${
                zipcodeError ? 'border-red-300' : 'border-gray-300'
              }`}
            />
            {zipcodeError && (
              <p className="text-sm text-red-600">{zipcodeError}</p>
            )}
            <input
              type="range"
              min="0"
              max="250"
              step="5"
              value={filters.radius}
              onChange={(e) => onFilterChange({ 
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

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            <div className="flex items-center">
              <Star className="h-4 w-4 text-[#1f4968] mr-1" />
              Specialties
            </div>
          </label>
          
          <select
            className="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
            value=""
            onChange={(e) => {
              if (e.target.value) handleSpecialtyAdd(e.target.value);
              e.target.value = ''; // Reset select after selection
            }}
            disabled={isLoading}
          >
            <option value="">Add specialty...</option>
            {availableSpecialties.map((specialty) => (
              <option key={specialty} value={specialty}>{specialty}</option>
            ))}
          </select>

          {filters.specialties.length > 0 && (
            <div className="mt-2 flex flex-wrap gap-2">
              {filters.specialties.map((specialty) => (
                <span
                  key={specialty}
                  className="inline-flex items-center px-2.5 py-0.5 rounded-full text-sm bg-green-100 text-green-800"
                >
                  {specialty}
                  <button
                    onClick={() => handleSpecialtyRemove(specialty)}
                    className="ml-1.5 hover:text-green-900"
                  >
                    <X className="h-3 w-3" />
                  </button>
                </span>
              ))}
            </div>
          )}
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            <div className="flex items-center">
              <Star className="h-4 w-4 text-[#1f4968] mr-1" />
              Certifications
            </div>
          </label>
          
          <select
            className="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
            value=""
            onChange={(e) => {
              if (e.target.value) handleCertificationAdd(e.target.value);
              e.target.value = ''; // Reset select after selection
            }}
            disabled={isLoading}
          >
            <option value="">Add certification...</option>
            {availableCertifications.map((cert) => (
              <option key={cert} value={cert}>{cert}</option>
            ))}
          </select>

          {filters.certifications.length > 0 && (
            <div className="mt-2 flex flex-wrap gap-2">
              {filters.certifications.map((cert) => (
                <span
                  key={cert}
                  className="inline-flex items-center px-2.5 py-0.5 rounded-full text-sm bg-blue-100 text-blue-800"
                >
                  {cert}
                  <button
                    onClick={() => handleCertificationRemove(cert)}
                    className="ml-1.5 hover:text-blue-900"
                  >
                    <X className="h-3 w-3" />
                  </button>
                </span>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}