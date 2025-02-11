import React, { useState } from 'react';
import { Filter, MapPin, Search } from 'lucide-react';

// Function to format budget value for display
const formatBudget = (value: number) => {
  if (value >= 1000000) {
    return `$${(value / 1000000).toFixed(1)}M`;
  } else if (value >= 1000) {
    return `$${(value / 1000).toFixed(0)}K`;
  }
  return `$${value}`;
};

interface ProjectFilters {
  minBudget: number;
  maxBudget: number;
  zipcode: string;
  radius: number;
}

interface Props {
  filters: ProjectFilters;
  onFilterChange: (filters: ProjectFilters) => void;
}

export function ProjectFilters({ filters, onFilterChange }: Props) {
  const [zipcode, setZipcode] = useState(filters.zipcode);
  const [zipcodeError, setZipcodeError] = useState('');
  const [minBudget, setMinBudget] = useState(filters.minBudget.toString());
  const [maxBudget, setMaxBudget] = useState(filters.maxBudget.toString());
  const [budgetError, setBudgetError] = useState('');
  const [localFilters, setLocalFilters] = useState(filters);

  const validateZipcode = (zip: string) => {
    const zipRegex = /^\d{5}$/;
    return zipRegex.test(zip);
  };

  const handleZipcodeChange = (value: string) => {
    const cleanValue = value.trim();
    setZipcode(cleanValue);
    
    if (cleanValue && !validateZipcode(cleanValue)) {
      setZipcodeError('Please enter a valid 5-digit zipcode');
    } else {
      setZipcodeError('');
      setLocalFilters(prev => ({ ...prev, zipcode: cleanValue }));
    }
  };

  const handleBudgetChange = (type: 'min' | 'max', value: string) => {
    // Remove any non-numeric characters
    const numericValue = value.replace(/[^0-9]/g, '');
    
    if (type === 'min') {
      setMinBudget(numericValue);
    } else {
      setMaxBudget(numericValue);
    }

    // Convert to numbers for validation
    const min = type === 'min' ? parseInt(numericValue) || 0 : parseInt(minBudget) || 0;
    const max = type === 'max' ? parseInt(numericValue) || 0 : parseInt(maxBudget) || 0;

    // Validate budget range
    if (min > max && max !== 0) {
      setBudgetError('Minimum budget cannot be greater than maximum budget');
      return;
    }

    setBudgetError('');
    setLocalFilters(prev => ({
      ...prev,
      minBudget: min,
      maxBudget: max || 1000000000 // Use a very high number if max is empty
    }));
  };

  const handleRadiusChange = (value: number) => {
    setLocalFilters(prev => ({ ...prev, radius: value }));
  };

  const handleSearch = () => {
    if (!budgetError && !zipcodeError) {
      onFilterChange(localFilters);
    }
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-sm">
      <div className="flex items-center mb-4">
        <Filter className="h-5 w-5 text-[#1f4968] mr-2" />
        <h2 className="text-lg font-semibold">Filters</h2>
      </div>
      
      <div className="space-y-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Budget Range</label>
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-xs text-gray-500 mb-1">Min Budget</label>
                <div className="relative">
                  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">$</span>
                  <input
                    type="text"
                    value={minBudget}
                    onChange={(e) => handleBudgetChange('min', e.target.value)}
                    placeholder="Min"
                    className="w-full pl-7 pr-3 py-2 border rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
              </div>
              <div>
                <label className="block text-xs text-gray-500 mb-1">Max Budget</label>
                <div className="relative">
                  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">$</span>
                  <input
                    type="text"
                    value={maxBudget}
                    onChange={(e) => handleBudgetChange('max', e.target.value)}
                    placeholder="Max"
                    className="w-full pl-7 pr-3 py-2 border rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
              </div>
            </div>
            {budgetError && (
              <p className="text-sm text-red-600">{budgetError}</p>
            )}
            <div className="text-xs text-gray-500 text-center">
              Enter budget range in dollars
            </div>
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
              onChange={(e) => handleZipcodeChange(e.target.value)}
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
              value={localFilters.radius}
              onChange={(e) => handleRadiusChange(parseInt(e.target.value))}
              className="w-full accent-coral-500"
            />
            <div className="text-sm text-gray-600">
              {localFilters.radius === 0 ? 'Any distance' : `Within ${localFilters.radius} miles`}
            </div>
          </div>
        </div>

        <button
          onClick={handleSearch}
          disabled={!!budgetError || !!zipcodeError}
          className="w-full flex items-center justify-center px-4 py-2 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-coral-500 hover:bg-coral-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-coral-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <Search className="h-4 w-4 mr-2" />
          Search Projects
        </button>
      </div>
    </div>
  );
}