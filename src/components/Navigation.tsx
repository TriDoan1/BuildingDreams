import React, { useState, useEffect, useRef } from 'react';
import { Building2, ChevronDown, Menu, X, User } from 'lucide-react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { supabase } from '../lib/supabase';

interface NavigationProps {
  onNavigate: (page: 'home' | 'signin' | 'signup') => void;
  session: any;
}

export function Navigation({ onNavigate, session }: NavigationProps) {
  const [isFloating, setIsFloating] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [activeDropdown, setActiveDropdown] = useState<string | null>(null);
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();
  
  // Refs for dropdown containers
  const workDropdownRef = useRef<HTMLDivElement>(null);
  const hireDropdownRef = useRef<HTMLDivElement>(null);
  const profileDropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleScroll = () => {
      const scrollPosition = window.scrollY;
      setIsFloating(scrollPosition > 0);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      // Check if click is outside work dropdown
      if (workDropdownRef.current && !workDropdownRef.current.contains(event.target as Node)) {
        if (activeDropdown === 'work') {
          setActiveDropdown(null);
        }
      }

      // Check if click is outside hire dropdown
      if (hireDropdownRef.current && !hireDropdownRef.current.contains(event.target as Node)) {
        if (activeDropdown === 'hire') {
          setActiveDropdown(null);
        }
      }

      // Check if click is outside profile menu
      if (profileDropdownRef.current && !profileDropdownRef.current.contains(event.target as Node)) {
        setShowProfileMenu(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [activeDropdown]);

  const toggleMobileMenu = () => {
    setIsMobileMenuOpen(!isMobileMenuOpen);
    document.body.style.overflow = !isMobileMenuOpen ? 'hidden' : '';
  };

  const handleDropdownClick = (dropdown: string) => {
    setActiveDropdown(activeDropdown === dropdown ? null : dropdown);
  };

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    setShowProfileMenu(false);
    navigate('/');
  };

  const handleLogoClick = () => {
    navigate('/');
    onNavigate('home');
  };

  const handleLinkClick = () => {
    setActiveDropdown(null);
    setIsMobileMenuOpen(false);
    setShowProfileMenu(false);
  };

  return (
    <>
      <nav className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        isFloating ? 'bg-white/95 backdrop-blur-sm shadow-md' : 'bg-white'
      }`}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <button
                onClick={handleLogoClick}
                className="flex-shrink-0 flex items-center group"
              >
                <div className="h-8 w-8 bg-gradient-to-br from-coral-500 to-coral-600 rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-shadow">
                  <Building2 className="h-5 w-5 text-white" />
                </div>
                <span className="ml-2 text-xl font-bold text-navy-900 group-hover:text-coral-500 transition-colors">
                  Building Dreams
                </span>
              </button>
            </div>

            {/* Desktop menu */}
            <div className="hidden md:flex items-center space-x-6">
              {/* Work Dropdown */}
              <div className="relative" ref={workDropdownRef}>
                <button
                  onClick={() => handleDropdownClick('work')}
                  className="text-sm font-medium text-gray-700 hover:text-navy-900 flex items-center"
                >
                  Work
                  <ChevronDown className="h-4 w-4 ml-1" />
                </button>
                {activeDropdown === 'work' && (
                  <div className="absolute top-full right-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-2 z-50">
                    <Link 
                      to="/find-employers" 
                      className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                      onClick={handleLinkClick}
                    >
                      Find Employers
                    </Link>
                    <Link 
                      to="/projects" 
                      className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                      onClick={handleLinkClick}
                    >
                      Find Projects
                    </Link>
                  </div>
                )}
              </div>

              {/* Hire Dropdown */}
              <div className="relative" ref={hireDropdownRef}>
                <button
                  onClick={() => handleDropdownClick('hire')}
                  className="text-sm font-medium text-gray-700 hover:text-navy-900 flex items-center"
                >
                  Hire
                  <ChevronDown className="h-4 w-4 ml-1" />
                </button>
                {activeDropdown === 'hire' && (
                  <div className="absolute top-full right-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-2 z-50">
                    <Link 
                      to="/find-talents" 
                      className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                      onClick={handleLinkClick}
                    >
                      Find Talents
                    </Link>
                    <Link 
                      to="/post-project" 
                      className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                      onClick={handleLinkClick}
                    >
                      Post a Project
                    </Link>
                  </div>
                )}
              </div>

              <Link 
                to="/news" 
                className="text-sm font-medium text-gray-700 hover:text-navy-900"
                onClick={handleLinkClick}
              >
                News
              </Link>

              <div className="flex items-center space-x-4">
                {session ? (
                  <div className="relative" ref={profileDropdownRef}>
                    <button
                      onClick={() => setShowProfileMenu(!showProfileMenu)}
                      className="flex items-center space-x-2"
                    >
                      {session.user?.user_metadata?.avatar_url ? (
                        <img
                          src={session.user.user_metadata.avatar_url}
                          alt="Profile"
                          className="h-8 w-8 rounded-full object-cover border-2 border-white shadow-sm"
                        />
                      ) : (
                        <div className="h-8 w-8 rounded-full bg-coral-500 flex items-center justify-center">
                          <User className="h-5 w-5 text-white" />
                        </div>
                      )}
                    </button>
                    {showProfileMenu && (
                      <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-2 z-50">
                        <Link
                          to="/dashboard"
                          className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                          onClick={handleLinkClick}
                        >
                          Dashboard
                        </Link>
                        <Link
                          to="/profile"
                          className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                          onClick={handleLinkClick}
                        >
                          Profile Settings
                        </Link>
                        <button
                          onClick={handleSignOut}
                          className="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                        >
                          Sign Out
                        </button>
                      </div>
                    )}
                  </div>
                ) : (
                  <>
                    <button
                      onClick={() => onNavigate('signin')}
                      className="text-sm font-medium text-gray-700 hover:text-navy-900"
                    >
                      Sign In
                    </button>
                    <button
                      onClick={() => onNavigate('signup')}
                      className="bg-coral-500 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-coral-600 transition-colors"
                    >
                      Sign Up
                    </button>
                  </>
                )}
              </div>
            </div>

            {/* Mobile menu button */}
            <div className="flex items-center md:hidden">
              {session && (
                <button
                  onClick={() => setShowProfileMenu(!showProfileMenu)}
                  className="mr-4"
                >
                  {session.user?.user_metadata?.avatar_url ? (
                    <img
                      src={session.user.user_metadata.avatar_url}
                      alt="Profile"
                      className="h-8 w-8 rounded-full object-cover border-2 border-white shadow-sm"
                    />
                  ) : (
                    <div className="h-8 w-8 rounded-full bg-coral-500 flex items-center justify-center">
                      <User className="h-5 w-5 text-white" />
                    </div>
                  )}
                </button>
              )}
              <button
                onClick={toggleMobileMenu}
                className="inline-flex items-center justify-center p-2 rounded-md text-gray-700 hover:text-navy-900 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-coral-500"
              >
                {isMobileMenuOpen ? (
                  <X className="h-6 w-6" />
                ) : (
                  <Menu className="h-6 w-6" />
                )}
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* Mobile menu */}
      <div
        className={`fixed inset-0 z-40 transform transition-transform duration-300 ease-in-out ${
          isMobileMenuOpen ? 'translate-x-0' : 'translate-x-full'
        }`}
      >
        {/* Backdrop */}
        <div
          className={`absolute inset-0 bg-black/30 backdrop-blur-sm transition-opacity duration-300 ${
            isMobileMenuOpen ? 'opacity-100' : 'opacity-0'
          }`}
          onClick={toggleMobileMenu}
        />

        {/* Menu panel */}
        <div className="absolute right-0 top-0 h-full w-64 bg-white shadow-xl">
          <div className="p-6">
            <div className="flex items-center justify-between mb-8">
              <button
                onClick={() => {
                  handleLogoClick();
                  toggleMobileMenu();
                }}
                className="h-8 w-8 bg-gradient-to-br from-coral-500 to-coral-600 rounded-lg flex items-center justify-center shadow-sm hover:shadow-md transition-shadow"
              >
                <Building2 className="h-5 w-5 text-white" />
              </button>
              <button
                onClick={toggleMobileMenu}
                className="p-2 rounded-md text-gray-700 hover:text-navy-900 hover:bg-gray-100"
              >
                <X className="h-6 w-6" />
              </button>
            </div>

            <div className="space-y-6">
              {/* Work Section */}
              <div>
                <button
                  onClick={() => handleDropdownClick('work-mobile')}
                  className="flex items-center justify-between w-full py-3 px-4 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 hover:text-navy-900"
                >
                  Work
                  <ChevronDown className="h-4 w-4" />
                </button>
                {activeDropdown === 'work-mobile' && (
                  <div className="ml-4 mt-2 space-y-2">
                    <Link
                      to="/find-employers"
                      className="block py-2 px-4 text-sm text-gray-600 hover:text-navy-900"
                      onClick={handleLinkClick}
                    >
                      Find Employers
                    </Link>
                    <Link
                      to="/projects"
                      className="block py-2 px-4 text-sm text-gray-600 hover:text-navy-900"
                      onClick={handleLinkClick}
                    >
                      Find Projects
                    </Link>
                  </div>
                )}
              </div>

              {/* Hire Section */}
              <div>
                <button
                  onClick={() => handleDropdownClick('hire-mobile')}
                  className="flex items-center justify-between w-full py-3 px-4 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 hover:text-navy-900"
                >
                  Hire
                  <ChevronDown className="h-4 w-4" />
                </button>
                {activeDropdown === 'hire-mobile' && (
                  <div className="ml-4 mt-2 space-y-2">
                    <Link
                      to="/find-talents"
                      className="block py-2 px-4 text-sm text-gray-600 hover:text-navy-900"
                      onClick={handleLinkClick}
                    >
                      Find Talents
                    </Link>
                    <Link
                      to="/post-project"
                      className="block py-2 px-4 text-sm text-gray-600 hover:text-navy-900"
                      onClick={handleLinkClick}
                    >
                      Post a Project
                    </Link>
                  </div>
                )}
              </div>

              <Link
                to="/news"
                className="block py-3 px-4 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 hover:text-navy-900"
                onClick={handleLinkClick}
              >
                News
              </Link>

              <div className="pt-6 border-t border-gray-100 space-y-3">
                {session ? (
                  <>
                    <Link
                      to="/dashboard"
                      className="block py-3 px-4 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 hover:text-navy-900"
                      onClick={handleLinkClick}
                    >
                      Dashboard
                    </Link>
                    <Link
                      to="/profile"
                      className="block py-3 px-4 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 hover:text-navy-900"
                      onClick={handleLinkClick}
                    >
                      Profile Settings
                    </Link>
                    <button
                      onClick={() => {
                        handleSignOut();
                        handleLinkClick();
                      }}
                      className="block w-full py-3 px-4 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 hover:text-navy-900 text-left"
                    >
                      Sign Out
                    </button>
                  </>
                ) : (
                  <>
                    <button
                      onClick={() => {
                        onNavigate('signin');
                        handleLinkClick();
                      }}
                      className="block py-3 px-4 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 hover:text-navy-900 w-full text-left"
                    >
                      Sign In
                    </button>
                    <button
                      onClick={() => {
                        onNavigate('signup');
                        handleLinkClick();
                      }}
                      className="w-full bg-coral-500 text-white px-4 py-3 rounded-lg text-sm font-medium hover:bg-coral-600 transition-colors"
                    >
                      Sign Up
                    </button>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}