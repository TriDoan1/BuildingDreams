import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, useNavigate, useLocation } from 'react-router-dom';
import { Navigation } from './components/Navigation';
import { Footer } from './components/Footer';
import { Hero } from './components/Hero';
import { FeaturedDesigners } from './components/FeaturedProfessionals';
import { TrendingProjects } from './components/TrendingProjects';
import { EmployerSearch } from './components/EmployerSearch';
import { Testimonials } from './components/Testimonials';
import { Auth } from './pages/Auth';
import { Search } from './pages/Search';
import { FindTalents } from './pages/FindTalents';
import { FindEmployers } from './pages/FindEmployers';
import { Projects } from './pages/Projects';
import { Profile } from './pages/Profile';
import { Project } from './pages/Project';
import { Company } from './pages/Company';
import { supabase } from './lib/supabase';

// ScrollToTop component that handles scrolling on route changes
function ScrollToTop() {
  const { pathname } = useLocation();

  useEffect(() => {
    window.scrollTo(0, 0);
  }, [pathname]);

  return null;
}

function AuthRedirectHandler() {
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    // Handle OAuth redirect
    const handleOAuthRedirect = async () => {
      if (location.hash) {
        const { data, error } = await supabase.auth.getSession();
        
        if (error) {
          console.error('Error getting session:', error);
          return;
        }

        if (data.session) {
          // Successfully authenticated
          navigate('/', { replace: true });
        }
      }
    };

    handleOAuthRedirect();
  }, [location.hash, navigate]);

  return null;
}

function App() {
  const [currentPage, setCurrentPage] = useState<'home' | 'signin' | 'signup'>('home');
  const [session, setSession] = useState<any>(null);
  const [showAuth, setShowAuth] = useState(false);
  const [authMode, setAuthMode] = useState<'signin' | 'signup'>('signin');

  useEffect(() => {
    // Set up auth state listener
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      if (session) {
        setShowAuth(false);
      }
    });

    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
    });

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  const handleNavigate = (page: 'home' | 'signin' | 'signup') => {
    if (page === 'signin' || page === 'signup') {
      setAuthMode(page);
      setShowAuth(true);
    } else {
      setCurrentPage(page);
      setShowAuth(false);
    }
  };

  const renderContent = () => {
    if (showAuth) {
      return <Auth initialMode={authMode} onClose={() => setShowAuth(false)} />;
    }

    switch (currentPage) {
      case 'home':
        return (
          <>
            <Hero />
            <FeaturedDesigners />
            <TrendingProjects />
            <EmployerSearch />
            <Testimonials />
          </>
        );
      default:
        return null;
    }
  };

  return (
    <Router>
      <div className="min-h-screen bg-white">
        <ScrollToTop />
        <Navigation 
          onNavigate={handleNavigate} 
          session={session} 
          showAuth={showAuth}
        />
        <AuthRedirectHandler />
        <Routes>
          <Route path="/search" element={<Search />} />
          <Route path="/find-employers" element={<FindEmployers />} />
          <Route path="/find-talents" element={<FindTalents />} />
          <Route path="/projects" element={<Projects />} />
          <Route path="/profile/:id" element={<Profile />} />
          <Route path="/project/:id" element={<Project />} />
          <Route path="/company/:id" element={<Company />} />
          <Route path="/" element={renderContent()} />
        </Routes>
        <Footer onNavigate={handleNavigate} />
      </div>
    </Router>
  );
}

export default App;