import React, { useCallback, useState, useEffect, useRef } from 'react';
import { GoogleMap, Marker, InfoWindow } from '@react-google-maps/api';
import { Loader } from '@googlemaps/js-api-loader';
import { AlertCircle } from 'lucide-react';

interface Coordinates {
  lat: number;
  lng: number;
}

interface MarkerCluster {
  center: google.maps.LatLng;
  markers: {
    item: any;
    position: google.maps.LatLng;
  }[];
}

interface LocationMapProps<T> {
  items: T[];
  getCoordinates: (item: T) => Coordinates | null;
  renderInfoWindow: (item: T) => React.ReactNode;
  getMarkerIcon: (item: T, isCluster: boolean) => {
    url: string;
    scaledSize: google.maps.Size;
    anchor: google.maps.Point;
    labelOrigin: google.maps.Point;
  };
  defaultCenter?: Coordinates;
  clusterRadius?: number;
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

const defaultMapCenter = {
  lat: 33.6846,  // Center of Orange County (Irvine)
  lng: -117.8265
};

const MAPS_API_KEY = import.meta.env.VITE_GOOGLE_MAPS_API_KEY;

export function LocationMap<T>({
  items,
  getCoordinates,
  renderInfoWindow,
  getMarkerIcon,
  defaultCenter = defaultMapCenter,
  clusterRadius = 0.5
}: LocationMapProps<T>) {
  const [selectedItem, setSelectedItem] = useState<T | null>(null);
  const [map, setMap] = useState<google.maps.Map | null>(null);
  const [isLoaded, setIsLoaded] = useState(false);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [markerClusters, setMarkerClusters] = useState<MarkerCluster[]>([]);
  const [expandedCluster, setExpandedCluster] = useState<MarkerCluster | null>(null);
  const [zoom, setZoom] = useState(10);
  const markersRef = useRef<{ [key: string]: google.maps.Marker }>({});

  useEffect(() => {
    if (!MAPS_API_KEY) {
      setLoadError('Google Maps API key is required');
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
        setLoadError('Failed to load Google Maps');
      });
  }, []);

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

  const clusterMarkers = useCallback(() => {
    if (!map || !items) return;

    const clusters: MarkerCluster[] = [];
    const clusterDist = Math.max(clusterRadius, 10 / Math.pow(2, zoom));

    items.forEach(item => {
      const coords = getCoordinates(item);
      if (!coords) return;

      const position = new google.maps.LatLng(coords.lat, coords.lng);

      let addedToCluster = false;
      for (const cluster of clusters) {
        if (calculateDistance(cluster.center, position) <= clusterDist) {
          cluster.markers.push({ item, position });
          const lat = cluster.markers.reduce((sum, m) => sum + m.position.lat(), 0) / cluster.markers.length;
          const lng = cluster.markers.reduce((sum, m) => sum + m.position.lng(), 0) / cluster.markers.length;
          cluster.center = new google.maps.LatLng(lat, lng);
          addedToCluster = true;
          break;
        }
      }

      if (!addedToCluster) {
        clusters.push({
          center: position,
          markers: [{ item, position }]
        });
      }
    });

    setMarkerClusters(clusters);
  }, [items, map, zoom, getCoordinates, clusterRadius]);

  useEffect(() => {
    clusterMarkers();
  }, [clusterMarkers]);

  const onLoad = useCallback((map: google.maps.Map) => {
    setMap(map);

    if (items && items.length > 0) {
      const bounds = new google.maps.LatLngBounds();
      let hasValidCoordinates = false;

      items.forEach(item => {
        const coords = getCoordinates(item);
        if (coords) {
          bounds.extend(coords);
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
  }, [items, getCoordinates, defaultCenter]);

  const handleZoomChanged = () => {
    if (map) {
      setZoom(map.getZoom() || 10);
    }
  };

  const handleClusterClick = (cluster: MarkerCluster) => {
    if (cluster.markers.length === 1) {
      setSelectedItem(cluster.markers[0].item);
      setExpandedCluster(null);
    } else {
      setExpandedCluster(cluster);
      setSelectedItem(null);
      
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
        {markerClusters.map((cluster, index) => {
          const icon = getMarkerIcon(cluster.markers[0].item, cluster.markers.length > 1);
          return (
            <Marker
              key={`cluster-${index}`}
              position={cluster.center}
              onClick={() => handleClusterClick(cluster)}
              icon={icon}
              label={cluster.markers.length > 1 ? {
                text: cluster.markers.length.toString(),
                color: '#ffffff',
                fontSize: '14px',
                fontWeight: 'bold'
              } : undefined}
            />
          );
        })}

        {(selectedItem || expandedCluster) && (
          <InfoWindow
            position={selectedItem 
              ? getCoordinates(selectedItem)!
              : expandedCluster!.center
            }
            onCloseClick={() => {
              setSelectedItem(null);
              setExpandedCluster(null);
            }}
            options={{
              pixelOffset: new window.google.maps.Size(0, -15)
            }}
          >
            <div className="max-w-sm">
              {selectedItem ? (
                renderInfoWindow(selectedItem)
              ) : (
                <div className="space-y-4">
                  <h3 className="font-medium text-gray-900">
                    {expandedCluster!.markers.length} items in this area
                  </h3>
                  <div className="max-h-[300px] overflow-y-auto space-y-4">
                    {expandedCluster!.markers.map(({ item }, index) => (
                      <div key={index}>
                        {renderInfoWindow(item)}
                      </div>
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