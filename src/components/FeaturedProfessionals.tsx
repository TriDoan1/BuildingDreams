import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Star, MapPin, CheckCircle } from 'lucide-react';
import { supabase } from '../lib/supabase';
import type { User } from '../types';

export function FeaturedDesigners() {
  const [designers, setDesigners] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isAnimating, setIsAnimating] = useState(false);
  const [direction, setDirection] = useState<'forward' | 'back'>('forward');
  const [cardWidth, setCardWidth] = useState(320);
  const [spacing, setSpacing] = useState(20);

  // Update card width and spacing based on viewport
  useEffect(() => {
    const updateDimensions = () => {
      const width = window.innerWidth;
      if (width < 640) { // Mobile
        setCardWidth(280);
        setSpacing(12);
      } else { // Desktop
        setCardWidth(320);
        setSpacing(20);
      }
    };

    updateDimensions();
    window.addEventListener('resize', updateDimensions);
    return () => window.removeEventListener('resize', updateDimensions);
  }, []);

  useEffect(() => {
    async function fetchDesigners() {
      try {
        const { data, error: queryError } = await supabase
          .from('professionals')
          .select(`
            id,
            user_id,
            users (
              name,
              image_url
            ),
            role,
            location,
            rating,
            projects_completed,
            verified
          `)
          .in('role', ['Architect', 'Interior Designer'])
          .eq('is_featured', true)
          .order('rating', { ascending: false })
          .limit(15);

        if (queryError) throw queryError;

        const formattedData = data.map(prof => ({
          id: prof.user_id,
          name: prof.users.name,
          image: prof.users.image_url,
          role: prof.role,
          location: prof.location,
          rating: prof.rating,
          projects: prof.projects_completed,
          specialties: [],
          verified: prof.verified
        }));

        setDesigners(formattedData);
        setError(null);
      } catch (error) {
        console.error('Error fetching designers:', error);
        setError('Please connect to Supabase using the "Connect to Supabase" button in the top right corner.');
      } finally {
        setLoading(false);
      }
    }

    fetchDesigners();
  }, []);

  const normalizeIndex = (index: number) => {
    const length = designers.length;
    return ((index % length) + length) % length;
  };

  const getVisibleDesigners = () => {
    if (designers.length === 0) return [];
    
    const items = [...designers.slice(-2), ...designers, ...designers.slice(0, 2)];
    const visibleItems = [];

    for (let i = -2; i <= 2; i++) {
      const index = normalizeIndex(currentIndex + i);
      visibleItems.push({
        designer: items[index + 2],
        position: i,
        index
      });
    }

    return visibleItems;
  };

  const handleTransitionEnd = () => {
    setIsAnimating(false);
    
    // Normalize the index after animation
    setCurrentIndex(prev => normalizeIndex(prev));
  };

  const moveToIndex = (targetIndex: number) => {
    if (isAnimating) return;
    
    setIsAnimating(true);
    
    // Determine direction
    const length = designers.length;
    let delta = targetIndex - currentIndex;
    
    // Adjust for shortest path
    if (Math.abs(delta) > length / 2) {
      delta = delta > 0 ? delta - length : delta + length;
    }
    
    setDirection(delta > 0 ? 'forward' : 'back');
    setCurrentIndex(prev => prev + delta);
  };

  const handleCardClick = (position: number, id: string, index: number) => {
    if (position === 0) {
      return true;
    }
    
    if (!isAnimating) {
      moveToIndex(index);
    }
    return false;
  };

  // Auto-advance carousel
  useEffect(() => {
    const interval = setInterval(() => {
      if (!isAnimating) {
        setDirection('forward');
        setIsAnimating(true);
        setCurrentIndex(prev => prev + 1);
      }
    }, 5000);
    return () => clearInterval(interval);
  }, [isAnimating]);

  if (error) {
    return (
      <section className="py-24 bg-white">
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
      <section className="py-24 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-8"></div>
            <div className="relative h-[32rem]">
              <div className="absolute inset-x-0 top-1/2 -translate-y-1/2">
                <div className="relative flex justify-center items-center h-[28rem]">
                  {[...Array(3)].map((_, i) => (
                    <div
                      key={i}
                      className="absolute w-80"
                      style={{
                        transform: `translateX(${(i - 1) * spacing}rem) scale(${i === 1 ? 1.1 : 0.9})`,
                        zIndex: i === 1 ? 30 : 20,
                      }}
                    >
                      <div className="bg-gray-200 rounded-lg h-[400px]"></div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    );
  }

  return (
    <section className="py-24 bg-white overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-24 relative z-10">
          <h2 className="text-3xl font-bold text-navy-900">
            Build <span className="text-coral-500">Dreams</span>
          </h2>
          <p className="mt-4 text-xl text-gray-600">
            Work with a designer to bring your vision to life.
          </p>
        </div>

        <div className="relative h-[32rem]">
          <div className="absolute inset-x-0 top-1/2 -translate-y-1/2">
            <div className="relative flex justify-center items-center h-[28rem] max-w-full">
              {getVisibleDesigners().map(({ designer, position, index }) => {
                const scale = position === 0 ? 1.1 : Math.abs(position) === 1 ? 0.9 : 0.75;
                const translateX = position * (cardWidth + spacing);
                const opacity = Math.abs(position) === 2 ? 0.6 : Math.abs(position) === 1 ? 0.8 : 1;
                const zIndex = position === 0 ? 30 : Math.abs(position) === 1 ? 20 : 10;

                return (
                  <Link
                    key={`${designer.id}-${index}`}
                    to={`/profile/${designer.id}`}
                    onClick={(e) => {
                      if (!handleCardClick(position, designer.id, index)) {
                        e.preventDefault();
                      }
                    }}
                    className="absolute cursor-pointer"
                    style={{
                      transform: `translateX(${translateX}px) scale(${scale})`,
                      zIndex,
                      opacity,
                      transition: 'all 500ms cubic-bezier(0.4, 0, 0.2, 1)',
                      width: cardWidth,
                    }}
                    onTransitionEnd={position === 0 ? handleTransitionEnd : undefined}
                  >
                    <div className={`bg-white rounded-lg shadow-sm overflow-hidden border border-gray-100 hover:shadow-md transition-shadow ${
                      position === 0 ? 'ring-2 ring-coral-500' : ''
                    }`}>
                      <div className="relative h-48 bg-gradient-to-r from-navy-700 to-navy-900">
                        <div className="absolute inset-0 opacity-10">
                          <div className="w-full h-full bg-[radial-gradient(circle_at_top_right,_var(--tw-gradient-stops))] from-coral-500 to-transparent"></div>
                        </div>
                        <img
                          src={designer.image}
                          alt={designer.name}
                          className="absolute bottom-0 left-1/2 transform -translate-x-1/2 translate-y-1/2 w-24 h-24 rounded-full border-4 border-white object-cover"
                        />
                      </div>
                      
                      <div className="pt-16 p-6">
                        <div className="text-center mb-4">
                          <h3 className="text-xl font-semibold text-navy-900 flex items-center justify-center">
                            {designer.name}
                            {designer.verified && (
                              <CheckCircle className="h-5 w-5 text-coral-500 ml-2" />
                            )}
                          </h3>
                          <p className="text-gray-600">{designer.role}</p>
                        </div>

                        <div className="flex items-center justify-center space-x-4 mb-6">
                          <div className="flex items-center">
                            <Star className="h-5 w-5 text-yellow-400" />
                            <span className="ml-1 font-medium">{designer.rating}</span>
                          </div>
                          <div className="flex items-center">
                            <MapPin className="h-5 w-5 text-gray-400" />
                            <span className="ml-1 text-gray-600">{designer.location}</span>
                          </div>
                        </div>

                        <div className="text-center text-sm text-gray-500">
                          {designer.projects}+ projects completed
                        </div>
                      </div>
                    </div>
                  </Link>
                );
              })}
            </div>

            <button
              onClick={() => {
                setDirection('back');
                moveToIndex(normalizeIndex(currentIndex - 1));
              }}
              disabled={isAnimating}
              className="absolute left-0 top-1/2 -translate-y-1/2 -translate-x-4 lg:-translate-x-8 bg-white rounded-full p-3 shadow-lg hover:bg-gray-50 z-40 transition-opacity disabled:opacity-50"
            >
              <svg className="h-6 w-6 text-navy-900" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <button
              onClick={() => {
                setDirection('forward');
                moveToIndex(normalizeIndex(currentIndex + 1));
              }}
              disabled={isAnimating}
              className="absolute right-0 top-1/2 -translate-y-1/2 translate-x-4 lg:translate-x-8 bg-white rounded-full p-3 shadow-lg hover:bg-gray-50 z-40 transition-opacity disabled:opacity-50"
            >
              <svg className="h-6 w-6 text-navy-900" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </section>
  );
}