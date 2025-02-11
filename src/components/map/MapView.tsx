import React, { useCallback, useState, useEffect } from 'react';
import { GoogleMap, Marker, InfoWindow } from '@react-google-maps/api';
import { Loader } from '@googlemaps/js-api-loader';
import type { Project } from '../../types';
import { ProjectCard } from '../projects/ProjectCard';
import { AlertCircle } from 'lucide-react';

interface MapViewProps {
  projects: Project[];
}

const mapContainerStyle = {
  width: '100%',
  height: '600px'
};

const options = {
  disableDefaultUI: false,
  zoomControl: true,
  mapTypeControl: false,
  streetViewControl: false,
  fullscreenControl: true,
  styles: [
    {
      featureType: 'poi',
      elementType: 'labels',
      stylers: [{ visibility: 'off' }]
    },
    {
      featureType: 'transit',
      elementType: 'labels',
      stylers: [{ visibility: 'off' }]
    }
  ]
};

const defaultCenter = {
  lat: 33.6846,  // Center of Orange County (Irvine)
  lng: -117.8265
};

const MAPS_API_KEY = import.meta.env.VITE_GOOGLE_MAPS_API_KEY;

interface MarkerCluster {
  center: google.maps.LatLng;
  markers: {
    project: Project;
    position: google.maps.LatLng;
  }[];
}

export function MapView({ projects }: MapViewProps) {
  const [selectedProject, setSelectedProject] = useState<Project | null>(null);
  const [map, setMap] = useState<google.maps.Map | null>(null);
  const [isLoaded, setIsLoaded] = useState(false);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [hoveredProject, setHoveredProject] = useState<Project | null>(null);
  const [markerClusters, setMarkerClusters] = useState<MarkerCluster[]>([]);
  const [expandedCluster, setExpandedCluster] = useState<MarkerCluster | null>(null);
  const [zoom, setZoom] = useState(10);

  useEffect(() => {
    if (!MAPS_API_KEY) {
      setLoadError('Google Maps API key is required. Please add VITE_GOOGLE_MAPS_API_KEY to your environment variables.');
      return;
    }

    const loader = new Loader({
      apiKey: MAPS_API_KEY,
      version: "weekly",
      libraries: ["places"]
    });

    loader.load()
      .then(() => {
        setIsLoaded(true);
      })
      .catch((error) => {
        console.error('Error loading Google Maps:', error);
        setLoadError('Failed to load Google Maps. Please check your API key and try again.');
      });
  }, []);

  // Function to calculate distance between two points
  const calculateDistance = (p1: google.maps.LatLng, p2: google.maps.LatLng): number => {
    const R = 6371; // Earth's radius in km
    const dLat = (p2.lat() - p1.lat()) * Math.PI / 180;
    const dLon = (p2.lng() - p1.lng()) * Math.PI / 180;
    const a = 
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(p1.lat() * Math.PI / 180) * Math.cos(p2.lat() * Math.PI / 180) * 
      Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
  };

  // Function to cluster markers based on zoom level and proximity
  const clusterMarkers = useCallback(() => {
    if (!map || !projects) return;

    const clusters: MarkerCluster[] = [];
    const clusterRadius = Math.max(0.5, 10 / Math.pow(2, zoom)); // Adjust radius based on zoom

    projects.forEach(project => {
      if (!project.latitude || !project.longitude) return;

      const position = new google.maps.LatLng(
        project.latitude,
        project.longitude
      );

      // Find nearby cluster
      let addedToCluster = false;
      for (const cluster of clusters) {
        if (calculateDistance(cluster.center, position) <= clusterRadius) {
          cluster.markers.push({ project, position });
          // Recalculate cluster center
          const lat = cluster.markers.reduce((sum, m) => sum + m.position.lat(), 0) / cluster.markers.length;
          const lng = cluster.markers.reduce((sum, m) => sum + m.position.lng(), 0) / cluster.markers.length;
          cluster.center = new google.maps.LatLng(lat, lng);
          addedToCluster = true;
          break;
        }
      }

      // Create new cluster if not added to existing one
      if (!addedToCluster) {
        clusters.push({
          center: position,
          markers: [{ project, position }]
        });
      }
    });

    setMarkerClusters(clusters);
  }, [projects, map, zoom]);

  useEffect(() => {
    clusterMarkers();
  }, [clusterMarkers, zoom]);

  const onLoad = useCallback((map: google.maps.Map) => {
    setMap(map);

    if (projects && projects.length > 0) {
      const bounds = new google.maps.LatLngBounds();
      let hasValidCoordinates = false;

      projects.forEach(project => {
        if (project.latitude && project.longitude) {
          bounds.extend({ lat: project.latitude, lng: project.longitude });
          hasValidCoordinates = true;
        }
      });

      if (hasValidCoordinates) {
        map.fitBounds(bounds, {
          padding: { top: 50, right: 50, bottom: 50, left: 50 }
        });
      } else {
        map.setCenter(defaultCenter);
        map.setZoom(10);
      }
    }
  }, [projects]);

  const handleZoomChanged = () => {
    if (map) {
      setZoom(map.getZoom() || 10);
    }
  };

  const handleClusterClick = (cluster: MarkerCluster) => {
    if (cluster.markers.length === 1) {
      setSelectedProject(cluster.markers[0].project);
      setExpandedCluster(null);
    } else {
      setExpandedCluster(cluster);
      setSelectedProject(null);
      
      // Zoom to cluster if zoom level is low
      if (zoom < 12) {
        map?.setZoom(Math.min(zoom + 2, 14));
        map?.panTo(cluster.center);
      }
    }
  };

  if (loadError) {
    return (
      <div className="rounded-lg bg-red-50 p-4">
        <div className="flex items-center">
          <AlertCircle className="h-5 w-5 text-red-400" />
          <p className="ml-3 text-sm text-red-700">{loadError}</p>
        </div>
      </div>
    );
  }

  if (!isLoaded) {
    return (
      <div className="rounded-lg bg-white p-4 shadow-sm">
        <div className="h-[600px] bg-gray-100 rounded-lg animate-pulse flex items-center justify-center">
          <div className="text-gray-500">Loading map...</div>
        </div>
      </div>
    );
  }

  return (
    <div className="relative rounded-lg overflow-hidden shadow-sm">
      <GoogleMap
        mapContainerStyle={mapContainerStyle}
        zoom={10}
        center={defaultCenter}
        options={options}
        onLoad={onLoad}
        onZoomChanged={handleZoomChanged}
      >
        {markerClusters.map((cluster, index) => (
          <Marker
            key={`cluster-${index}`}
            position={cluster.center}
            onClick={() => handleClusterClick(cluster)}
            icon={{
              url: cluster.markers.length > 1 
                ? '/cluster-marker.svg'
                : cluster.markers[0].project.professional.verified 
                  ? '/verified-marker.svg'
                  : '/marker.svg',
              scaledSize: new window.google.maps.Size(
                cluster.markers.length > 1 ? 40 : 30,
                cluster.markers.length > 1 ? 40 : 30
              ),
              anchor: new window.google.maps.Point(20, 20),
            }}
            label={cluster.markers.length > 1 ? {
              text: cluster.markers.length.toString(),
              color: '#ffffff',
              fontSize: '14px',
              fontWeight: 'bold'
            } : undefined}
          />
        ))}

        {(selectedProject || expandedCluster) && (
          <InfoWindow
            position={selectedProject 
              ? { lat: selectedProject.latitude!, lng: selectedProject.longitude! }
              : expandedCluster!.center
            }
            onCloseClick={() => {
              setSelectedProject(null);
              setExpandedCluster(null);
            }}
            options={{
              pixelOffset: new window.google.maps.Size(0, -15)
            }}
          >
            <div className="max-w-sm">
              {selectedProject ? (
                <ProjectCard project={selectedProject} />
              ) : (
                <div className="space-y-4">
                  <h3 className="font-medium text-gray-900">
                    {expandedCluster!.markers.length} Projects in this area
                  </h3>
                  <div className="max-h-[300px] overflow-y-auto space-y-4">
                    {expandedCluster!.markers.map(({ project }) => (
                      <ProjectCard
                        key={project.id}
                        project={project}
                      />
                    ))}
                  </div>
                </div>
              )}
            </div>
          </InfoWindow>
        )}
      </GoogleMap>
    </div>
  );
}