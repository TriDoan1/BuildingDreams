import React from 'react';
import { Building2, Briefcase, Newspaper, Users2 } from 'lucide-react';

interface FooterProps {
  onNavigate: (page: 'home' | 'signin' | 'signup') => void;
}

export function Footer({ onNavigate }: FooterProps) {
  return (
    <footer className="bg-gray-900">
      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div>
            <button
              onClick={() => onNavigate('home')}
              className="flex items-center group"
            >
              <div className="h-8 w-8 bg-gradient-to-br from-coral-500 to-coral-600 rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-shadow">
                <Building2 className="h-5 w-5 text-white" />
              </div>
              <span className="ml-2 text-xl font-bold text-white group-hover:text-coral-500 transition-colors">
                Building Dreams
              </span>
            </button>
            <p className="mt-4 text-gray-400 text-sm">
              Connecting construction professionals and businesses to build better together.
            </p>
          </div>
          <div>
            <h3 className="text-sm font-semibold text-gray-400 tracking-wider uppercase">Platform</h3>
            <ul className="mt-4 space-y-4">
              <li><a href="#" className="text-base text-gray-300 hover:text-white">Browse Jobs</a></li>
              <li><a href="#" className="text-base text-gray-300 hover:text-white">Find Professionals</a></li>
              <li><a href="#" className="text-base text-gray-300 hover:text-white">Company Directory</a></li>
              <li><a href="#" className="text-base text-gray-300 hover:text-white">Success Stories</a></li>
            </ul>
          </div>
          <div>
            <h3 className="text-sm font-semibold text-gray-400 tracking-wider uppercase">Support</h3>
            <ul className="mt-4 space-y-4">
              <li><a href="#" className="text-base text-gray-300 hover:text-white">Help Center</a></li>
              <li><a href="#" className="text-base text-gray-300 hover:text-white">Safety Center</a></li>
              <li><a href="#" className="text-base text-gray-300 hover:text-white">Community Guidelines</a></li>
              <li><a href="#" className="text-base text-gray-300 hover:text-white">Contact Us</a></li>
            </ul>
          </div>
          <div>
            <h3 className="text-sm font-semibold text-gray-400 tracking-wider uppercase">Legal</h3>
            <ul className="mt-4 space-y-4">
              <li><a href="#" className="text-base text-gray-300 hover:text-white">Privacy Policy</a></li>
              <li><a href="#" className="text-base text-gray-300 hover:text-white">Terms of Service</a></li>
              <li><a href="#" className="text-base text-gray-300 hover:text-white">Cookie Policy</a></li>
              <li><a href="#" className="text-base text-gray-300 hover:text-white">Accessibility</a></li>
            </ul>
          </div>
        </div>
        <div className="mt-8 border-t border-gray-700 pt-8">
          <p className="text-base text-gray-400 text-center">
            © 2025 Building Dreams. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  );
}