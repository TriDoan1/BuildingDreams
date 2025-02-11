import React, { useState, useEffect } from 'react';
import type { Testimonial } from '../types';

const TESTIMONIALS: Testimonial[] = [
  {
    id: '1',
    content: "BuildingDreams has transformed how we find and hire skilled tradespeople. The verification system gives us confidence in every hire.",
    author: {
      name: "Robert Chen",
      role: "Project Manager",
      company: "Urban Development Co.",
      avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=facearea&facepad=2&w=256&h=256"
    }
  },
  {
    id: '2',
    content: "As an independent contractor, this platform has helped me showcase my work and connect with quality clients consistently.",
    author: {
      name: "Lisa Martinez",
      role: "Master Electrician",
      company: "Martinez Electric",
      avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=facearea&facepad=2&w=256&h=256"
    }
  }
];

export function Testimonials() {
  const [visibleTestimonials, setVisibleTestimonials] = useState<boolean[]>(new Array(TESTIMONIALS.length).fill(false));

  useEffect(() => {
    // Add a 1-second delay before starting the fade-in
    const timer = setTimeout(() => {
      // Fade in testimonials one after another with a slight delay between each
      TESTIMONIALS.forEach((_, index) => {
        setTimeout(() => {
          setVisibleTestimonials(prev => {
            const newState = [...prev];
            newState[index] = true;
            return newState;
          });
        }, index * 200); // 200ms delay between each testimonial
      });
    }, 1000);

    return () => clearTimeout(timer);
  }, []);

  return (
    <section className="py-12 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
          {TESTIMONIALS.map((testimonial, index) => (
            <div
              key={testimonial.id}
              className={`bg-gray-50 rounded-lg p-8 shadow-sm transition-all duration-1000 ease-out transform ${
                visibleTestimonials[index] 
                  ? 'opacity-100 translate-y-0' 
                  : `opacity-0 ${index === 0 ? '-translate-x-full' : 'translate-x-full'}`
              }`}
            >
              <p className="text-gray-600 text-lg italic">"{testimonial.content}"</p>
              <div className="mt-6 flex items-center">
                <img
                  className="h-12 w-12 rounded-full"
                  src={testimonial.author.avatar}
                  alt={testimonial.author.name}
                />
                <div className="ml-4">
                  <p className="text-base font-medium text-gray-900">
                    {testimonial.author.name}
                  </p>
                  <p className="text-sm text-gray-500">
                    {testimonial.author.role} at {testimonial.author.company}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}