export interface User {
  id: string;
  name: string;
  avatar: string;
  trade: string;
  location: string;
  rating: number;
  verified: boolean;
  hourlyRate?: number;
  availability?: string;
  certifications?: string[];
  specialties?: string[];
  completedProjects?: number;
  bio?: string;
  email?: string;
  phone?: string;
  yearsOfExperience?: number;
  businessName?: string;
  insuranceInfo?: string;
  licenseNumber?: string;
  coordinates?: {
    lat: number;
    lng: number;
  } | null;
  isCompany?: boolean;
  isHiring?: boolean;
}

export interface SearchFilters {
  rating: number;
  certifications: string[];
  specialties: string[];
  radius: number;
  zipcode?: string;
}

export interface Project {
  id: string;
  title: string;
  description: string;
  image_url: string;
  likes: number;
  budget?: number;
  location?: string;
  latitude?: number;
  longitude?: number;
  professional: {
    id: string;
    name: string;
    role: string;
    location: string;
    rating: number;
    image_url: string;
    verified: boolean;
    projects?: Project[];
  };
}

export interface Testimonial {
  id: string;
  content: string;
  author: {
    name: string;
    role: string;
    company: string;
    avatar: string;
  };
}

export type OnboardingStep = 'personal' | 'professional' | 'verification' | 'complete';