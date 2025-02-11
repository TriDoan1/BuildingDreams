/**
 * CRITICAL: DO NOT MODIFY THIS FILE WITHOUT APPROVAL
 * 
 * This file contains the core configuration for map markers used throughout the application.
 * The marker implementation has been carefully tested and optimized for both performance
 * and compatibility with Google Maps API.
 * 
 * Any changes to this configuration could break:
 * 1. Marker rendering
 * 2. Clustering functionality
 * 3. InfoWindow positioning
 * 4. Map performance
 * 
 * @version 1.0.0
 * @lastModified 2025-02-10
 */

import type { User, Project } from '../types';

interface MarkerIcon {
  url: string;
  scaledSize: google.maps.Size;
  anchor: google.maps.Point;
  labelOrigin: google.maps.Point;
}

/**
 * Creates a marker icon configuration for professionals
 * @param professional The professional user data
 * @param isCluster Whether the marker represents a cluster
 * @returns Marker icon configuration
 */
export function getProfessionalMarkerIcon(professional: User, isCluster: boolean): MarkerIcon {
  const size = isCluster ? 40 : 30;
  return {
    url: isCluster 
      ? '/cluster-marker.svg'
      : professional.verified 
        ? '/verified-marker.svg'
        : '/marker.svg',
    scaledSize: new window.google.maps.Size(size, size),
    anchor: new window.google.maps.Point(size/2, size/2),
    labelOrigin: new window.google.maps.Point(size/2, size/2)
  };
}

/**
 * Creates a marker icon configuration for projects
 * @param project The project data
 * @param isCluster Whether the marker represents a cluster
 * @returns Marker icon configuration
 */
export function getProjectMarkerIcon(project: Project, isCluster: boolean): MarkerIcon {
  const size = isCluster ? 40 : 30;
  return {
    url: isCluster 
      ? '/cluster-marker.svg'
      : project.professional.verified 
        ? '/verified-marker.svg'
        : '/marker.svg',
    scaledSize: new window.google.maps.Size(size, size),
    anchor: new window.google.maps.Point(size/2, size/2),
    labelOrigin: new window.google.maps.Point(size/2, size/2)
  };
}

/**
 * Gets coordinates for a professional
 * @param professional The professional user data
 * @returns Coordinates or null if not available
 */
export function getProfessionalCoordinates(professional: User) {
  if (professional.coordinates) {
    return professional.coordinates;
  }
  return null;
}

/**
 * Gets coordinates for a project
 * @param project The project data
 * @returns Coordinates or null if not available
 */
export function getProjectCoordinates(project: Project) {
  if (project.latitude && project.longitude) {
    return {
      lat: project.latitude,
      lng: project.longitude
    };
  }
  return null;
}