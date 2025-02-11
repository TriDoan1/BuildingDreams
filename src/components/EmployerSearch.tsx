import React, { useState, useEffect } from 'react';
import { Search, MapPin, Briefcase, Target } from 'lucide-react';
import { supabase } from '../lib/supabase';

const TRADES = [
  'All Trades',
  'General Contractor',
  'Electrician',
  'Plumber',
  'Carpenter',
  'Mason',
  'HVAC Technician',
  'Painter',
  'Roofer',
  'Landscaper',
  'Interior Designer'
];

const RADIUS_OPTIONS = [
  { value: 'any', label: 'Any distance' },
  { value: 5, label: 'Within 5 miles' },
  { value: 10, label: 'Within 10 miles' },
  { value: 25, label: 'Within 25 miles' },
  { value: 50, label: 'Within 50 miles' },
  { value: 100, label: 'Within 100 miles' }
];

export function EmployerSearch() {
  const [selectedTrade, setSelectedTrade] = useState('All Trades');
  const [zipcode, setZipcode] = useState('');
  const [radius, setRadius] = useState('any');
  const [isLoading, setIsLoading] = useState(false);
  const [zipcodeError, setZipcodeError] = useState('');
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsVisible(true);
    }, 1000);

    return () => clearTimeout(timer);
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
    }
  };

  const handleSearch = async () => {
    if (!validateZipcode(zipcode)) {
      setZipcodeError('Please enter a valid 5-digit zipcode');
      return;
    }

    setIsLoading(true);
    try {
      let query = supabase
        .from('professionals')
        .select('*');

      if (selectedTrade !== 'All Trades') {
        query = query.eq('trade', selectedTrade);
      }

      // In a real application, we would use PostGIS or a similar geospatial database
      // to calculate actual distances. For now, we'll just simulate the radius filter
      const { data, error } = await query.limit(20);

      if (error) throw error;
      console.log('Search results:', { data, radius, zipcode });
    } catch (error) {
      console.error('Error searching professionals:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <section className="py-24 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className={`text-center mb-12 transition-all duration-1000 ease-out transform ${
          isVisible ? 'opacity-100 scale-100' : 'opacity-0 scale-75'
        }`}>
          <h2 className="text-3xl font-bold text-navy-900">
            Build a <span className="text-coral-500">Future</span>
          </h2>
          <p className="mt-4 text-xl text-gray-600">
            Find a local trade team to grow with.
          </p>
        </div>

        <div className="max-w-5xl mx-auto">
          <div className={`bg-white rounded-xl shadow-lg p-6 relative overflow-hidden transition-all duration-1000 ease-out transform ${
            isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
          }`}>
            {/* Background pattern */}
            <div className="absolute inset-0 opacity-5">
              <div className="absolute inset-0 bg-gradient-to-br from-coral-500 to-navy-900" />
              <div className="absolute inset-0" style={{ 
                backgroundImage: "url(\"data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23000000' fill-opacity='1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E\")",
              }} />
            </div>

            <div className="relative">
              <div className="flex flex-col md:flex-row gap-4">
                {/* Trade Selection */}
                <div className="flex-1">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Trade</label>
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <Briefcase className="h-5 w-5 text-gray-400" />
                    </div>
                    <select
                      value={selectedTrade}
                      onChange={(e) => setSelectedTrade(e.target.value)}
                      className="block w-full pl-10 pr-3 py-3 text-base border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-coral-500 focus:border-transparent"
                    >
                      {TRADES.map((trade) => (
                        <option key={trade} value={trade}>{trade}</option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Location Group */}
                <div className="flex-1 space-y-4 md:space-y-0 md:flex md:gap-4">
                  {/* Zipcode Input */}
                  <div className="flex-1">
                    <label className="block text-sm font-medium text-gray-700 mb-1">Location</label>
                    <div className="relative">
                      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <MapPin className="h-5 w-5 text-gray-400" />
                      </div>
                      <input
                        type="text"
                        value={zipcode}
                        onChange={handleZipcodeChange}
                        placeholder="Enter zipcode"
                        maxLength={5}
                        className={`block w-full pl-10 pr-3 py-3 text-base border rounded-lg focus:outline-none focus:ring-2 focus:ring-coral-500 focus:border-transparent ${
                          zipcodeError ? 'border-red-300' : 'border-gray-300'
                        }`}
                      />
                    </div>
                  </div>

                  {/* Radius Selection */}
                  <div className="flex-1">
                    <label className="block text-sm font-medium text-gray-700 mb-1">Distance</label>
                    <div className="relative">
                      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <Target className="h-5 w-5 text-gray-400" />
                      </div>
                      <select
                        value={radius}
                        onChange={(e) => setRadius(e.target.value)}
                        className="block w-full pl-10 pr-3 py-3 text-base border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-coral-500 focus:border-transparent"
                      >
                        {RADIUS_OPTIONS.map((option) => (
                          <option key={option.value} value={option.value}>
                            {option.label}
                          </option>
                        ))}
                      </select>
                    </div>
                  </div>
                </div>

                {/* Search Button */}
                <div className="flex-none">
                  <label className="block text-sm font-medium text-transparent mb-1">Search</label>
                  <button
                    onClick={handleSearch}
                    disabled={isLoading || !!zipcodeError || !zipcode}
                    className="w-full md:w-auto px-6 py-3 bg-coral-500 text-white rounded-lg hover:bg-coral-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-coral-500 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center whitespace-nowrap h-[46px]"
                  >
                    {isLoading ? (
                      <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                    ) : (
                      <>
                        <Search className="h-5 w-5 mr-2" />
                        Search
                      </>
                    )}
                  </button>
                </div>
              </div>
              
              {zipcodeError && (
                <p className="mt-2 text-sm text-red-600">{zipcodeError}</p>
              )}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}