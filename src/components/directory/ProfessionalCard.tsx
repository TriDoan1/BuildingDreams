import React from 'react';
import { Link } from 'react-router-dom';
import { Star, MapPin, CheckCircle, MessageSquare } from 'lucide-react';
import type { User } from '../../types';

interface Props {
  professional: User;
  compact?: boolean;
  listView?: boolean;
}

export function ProfessionalCard({ professional, compact = false, listView = false }: Props) {
  if (compact) {
    return (
      <div className="bg-white p-4 rounded-lg shadow-sm">
        <div className="flex items-center space-x-3">
          <img
            src={professional.avatar}
            alt={professional.name}
            className="h-10 w-10 rounded-full object-cover"
          />
          <div>
            <h3 className="text-sm font-medium text-gray-900 flex items-center">
              <Link to={`/profile/${professional.id}`} className="hover:text-coral-500">
                {professional.name}
              </Link>
              {professional.verified && (
                <CheckCircle className="h-4 w-4 text-blue-500 ml-1" />
              )}
            </h3>
            <p className="text-xs text-gray-500">{professional.trade}</p>
          </div>
        </div>
        <div className="mt-2 flex items-center justify-between text-xs">
          <div className="flex items-center text-yellow-400">
            <Star className="h-4 w-4 mr-1" />
            <span className="font-medium">{professional.rating}</span>
          </div>
          <div className="flex items-center text-gray-500">
            <MapPin className="h-4 w-4 mr-1" />
            {professional.location}
          </div>
        </div>
        <Link
          to={`/profile/${professional.id}`}
          className="mt-3 block w-full px-3 py-1.5 border border-blue-600 text-blue-600 rounded text-sm text-center hover:bg-blue-50"
        >
          View Profile
        </Link>
      </div>
    );
  }

  if (listView) {
    return (
      <div className="bg-white rounded-lg shadow-sm overflow-hidden">
        <div className="p-6">
          <div className="flex items-start space-x-4">
            <img
              src={professional.avatar}
              alt={professional.name}
              className="h-16 w-16 rounded-full object-cover border-2 border-white shadow-sm"
            />
            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between">
                <h3 className="text-xl font-semibold text-gray-900 flex items-center">
                  <Link to={`/profile/${professional.id}`} className="hover:text-coral-500">
                    {professional.name}
                  </Link>
                  {professional.verified && (
                    <CheckCircle className="h-5 w-5 text-blue-500 ml-2" />
                  )}
                </h3>
                <div className="flex items-center">
                  <Star className="h-5 w-5 text-yellow-400" />
                  <span className="ml-1 font-medium">{professional.rating}</span>
                </div>
              </div>
              <p className="text-gray-600 mt-1">{professional.trade}</p>
              <div className="mt-2 flex items-center text-gray-600">
                <MapPin className="h-4 w-4 mr-1" />
                {professional.location}
              </div>
              
              {professional.specialties && professional.specialties.length > 0 && (
                <div className="mt-3 flex flex-wrap gap-2">
                  {professional.specialties.map((specialty) => (
                    <span
                      key={specialty}
                      className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
                    >
                      {specialty}
                    </span>
                  ))}
                </div>
              )}
            </div>
            <div className="flex flex-col items-end space-y-4">
              <div className="text-gray-900">
                <span className="font-medium text-lg">${professional.hourlyRate}</span>
                <span className="text-gray-500">/hour</span>
              </div>
              <Link
                to={`/profile/${professional.id}`}
                className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
              >
                <MessageSquare className="h-4 w-4 mr-2" />
                Contact
              </Link>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow-sm overflow-hidden">
      <div className="relative h-32 bg-gradient-to-r from-blue-500 to-blue-600">
        <img
          src={professional.avatar}
          alt={professional.name}
          className="absolute bottom-0 left-6 transform translate-y-1/2 w-24 h-24 rounded-full border-4 border-white object-cover"
        />
      </div>
      
      <div className="pt-16 p-6">
        <div className="flex items-start justify-between">
          <div>
            <h3 className="text-xl font-semibold text-gray-900 flex items-center">
              <Link to={`/profile/${professional.id}`} className="hover:text-coral-500">
                {professional.name}
              </Link>
              {professional.verified && (
                <CheckCircle className="h-5 w-5 text-blue-500 ml-2" />
              )}
            </h3>
            <p className="text-gray-600">{professional.trade}</p>
          </div>
          <div className="flex items-center">
            <Star className="h-5 w-5 text-yellow-400" />
            <span className="ml-1 font-medium">{professional.rating}</span>
          </div>
        </div>

        <div className="mt-4 flex items-center text-gray-600">
          <MapPin className="h-4 w-4 mr-1" />
          {professional.location}
        </div>

        {professional.specialties && (
          <div className="mt-4">
            <div className="flex flex-wrap gap-2">
              {professional.specialties.map((specialty) => (
                <span
                  key={specialty}
                  className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
                >
                  {specialty}
                </span>
              ))}
            </div>
          </div>
        )}

        {professional.certifications && (
          <div className="mt-4">
            <div className="flex flex-wrap gap-2">
              {professional.certifications.map((cert) => (
                <span
                  key={cert}
                  className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800"
                >
                  {cert}
                </span>
              ))}
            </div>
          </div>
        )}

        <div className="mt-6 flex items-center justify-between">
          <div className="text-gray-900">
            <span className="font-medium">${professional.hourlyRate}</span>
            <span className="text-gray-500">/hour</span>
          </div>
          <Link
            to={`/profile/${professional.id}`}
            className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
          >
            <MessageSquare className="h-4 w-4 mr-2" />
            Contact
          </Link>
        </div>
      </div>
    </div>
  );
}