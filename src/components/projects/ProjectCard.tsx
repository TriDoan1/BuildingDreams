import React from 'react';
import { Link } from 'react-router-dom';
import { MapPin, DollarSign, Star, CheckCircle } from 'lucide-react';
import type { Project } from '../../types';

interface Props {
  project: Project;
}

export function ProjectCard({ project }: Props) {
  return (
    <div className="bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-shadow">
      <Link to={`/project/${project.id}`} className="block">
        <div className="relative h-48">
          <img
            src={project.image_url}
            alt={project.title}
            className="w-full h-full object-cover"
          />
        </div>
      </Link>

      <div className="p-4">
        <Link 
          to={`/project/${project.id}`}
          className="block font-semibold text-gray-900 hover:text-coral-500 mb-2"
        >
          {project.title}
        </Link>

        <p className="text-sm text-gray-600 mb-4 line-clamp-2">
          {project.description}
        </p>

        <div className="flex items-center justify-between text-sm text-gray-600 mb-4">
          <div className="flex items-center">
            <MapPin className="h-4 w-4 mr-1" />
            {project.location}
          </div>
          {project.budget && (
            <div className="flex items-center font-medium">
              <DollarSign className="h-4 w-4 text-gray-400 mr-1" />
              {project.budget.toLocaleString()}
            </div>
          )}
        </div>

        <Link
          to={`/profile/${project.professional.id}`}
          className="flex items-center space-x-3 group"
        >
          <img
            src={project.professional.image_url}
            alt={project.professional.name}
            className="h-10 w-10 rounded-full object-cover"
          />
          <div>
            <div className="flex items-center">
              <span className="font-medium text-gray-900 group-hover:text-coral-500">
                {project.professional.name}
              </span>
              {project.professional.verified && (
                <CheckCircle className="h-4 w-4 text-coral-500 ml-1" />
              )}
            </div>
            <div className="flex items-center text-sm text-gray-600">
              <Star className="h-4 w-4 text-yellow-400 mr-1" />
              <span>{project.professional.rating}</span>
            </div>
          </div>
        </Link>
      </div>
    </div>
  );
}