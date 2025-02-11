import React, { useState, useEffect, useRef } from 'react';
import { Search as SearchIcon } from 'lucide-react';
import { supabase } from '../../lib/supabase';

interface SearchSuggestionsProps {
  searchTerm: string;
  onSearch: (term: string) => void;
  onTermChange: (term: string) => void;
  placeholder?: string;
  className?: string;
  showSearchButton?: boolean;
}

export function SearchSuggestions({
  searchTerm,
  onSearch,
  onTermChange,
  placeholder = "Search...",
  className = "",
  showSearchButton = true
}: SearchSuggestionsProps) {
  const [suggestions, setSuggestions] = useState<string[]>([]);
  const [showSuggestions, setShowSuggestions] = useState(false);
  const suggestionsRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    async function fetchSuggestions() {
      if (!searchTerm.trim()) {
        setSuggestions([]);
        return;
      }

      try {
        // Get unique roles from professionals table
        const { data, error } = await supabase
          .from('professionals')
          .select('role')
          .ilike('role', `%${searchTerm}%`)
          .limit(10);

        if (error) throw error;

        // Extract unique roles
        const uniqueRoles = Array.from(new Set(data.map(item => item.role)));
        setSuggestions(uniqueRoles);
      } catch (error) {
        console.error('Error fetching suggestions:', error);
      }
    }

    const debounceTimer = setTimeout(fetchSuggestions, 300);
    return () => clearTimeout(debounceTimer);
  }, [searchTerm]);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (
        suggestionsRef.current &&
        !suggestionsRef.current.contains(event.target as Node) &&
        !inputRef.current?.contains(event.target as Node)
      ) {
        setShowSuggestions(false);
      }
    }

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleSuggestionClick = (suggestion: string) => {
    onTermChange(suggestion);
    onSearch(suggestion);
    setShowSuggestions(false);
    if (inputRef.current) {
      inputRef.current.blur();
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    onTermChange(value);
    setShowSuggestions(value.trim().length > 0);
  };

  const handleInputFocus = () => {
    if (searchTerm.trim() && suggestions.length > 0) {
      setShowSuggestions(true);
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchTerm.trim()) {
      onSearch(searchTerm.trim());
      setShowSuggestions(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className={className}>
      <div className="relative" ref={suggestionsRef}>
        <input
          ref={inputRef}
          type="search"
          value={searchTerm}
          onChange={handleInputChange}
          onFocus={handleInputFocus}
          className="block w-full pl-4 pr-12 py-4 border border-gray-300 rounded-lg leading-5 bg-white text-gray-900 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-coral-500 focus:border-transparent"
          placeholder={placeholder}
        />
        {showSearchButton && (
          <button
            type="submit"
            className="absolute inset-y-0 right-0 px-4 flex items-center text-gray-400 hover:text-coral-500 transition-colors"
          >
            <SearchIcon className="h-5 w-5" />
          </button>
        )}

        {showSuggestions && suggestions.length > 0 && (
          <div className="absolute z-10 w-full mt-1 bg-white rounded-lg shadow-lg max-h-60 overflow-auto">
            {suggestions.map((suggestion, index) => (
              <button
                key={index}
                onClick={() => handleSuggestionClick(suggestion)}
                className="w-full text-left px-4 py-2 hover:bg-gray-100 focus:bg-gray-100 focus:outline-none first:rounded-t-lg last:rounded-b-lg"
              >
                <span className="text-gray-900">{suggestion}</span>
              </button>
            ))}
          </div>
        )}
      </div>
    </form>
  );
}