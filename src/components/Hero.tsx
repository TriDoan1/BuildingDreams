import React from 'react';
import { useNavigate } from 'react-router-dom';
import { SearchSuggestions } from './search/SearchSuggestions';

export function Hero() {
  const [searchTerm, setSearchTerm] = React.useState('');
  const navigate = useNavigate();

  const handleSearch = (term: string) => {
    navigate(`/find-talents?q=${encodeURIComponent(term)}`);
  };

  return (
    <div className="relative overflow-hidden min-h-[100vh]">
      <div className="absolute inset-0 w-full h-full overflow-hidden">
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat"
          style={{
            backgroundImage: 'url("https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&q=80")',
          }}
        />
        <div className="absolute inset-0" style={{ backgroundColor: '#1f4968', opacity: '0.9' }} />
      </div>
      
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 min-h-[100vh] flex items-center relative">
        <div className="w-full max-w-2xl py-32 md:py-0">
          <h1 className="text-5xl font-bold text-white mb-6 drop-shadow-lg">
            Build <span className="text-coral-500">Relationships</span>
          </h1>
          <p className="text-xl text-white mb-12 drop-shadow">
            Post a project or search our network to connect with trade professionals
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="order-last sm:order-first sm:w-1/3">
              <button className="w-full bg-coral-500 text-white px-8 py-4 rounded-lg font-medium hover:bg-coral-600 transition-colors shadow-lg">
                Post a Project
              </button>
            </div>
            <div className="order-first sm:order-last sm:w-2/3">
              <SearchSuggestions
                searchTerm={searchTerm}
                onSearch={handleSearch}
                onTermChange={setSearchTerm}
                placeholder="Search by trade (e.g., Electrician, Plumber)..."
                showSearchButton={true}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}