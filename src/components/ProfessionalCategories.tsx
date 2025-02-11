import React from 'react';
import { Building2, Ruler, Wrench, Palette } from 'lucide-react';

const categories = [
  {
    icon: Building2,
    title: 'General Contractors',
    description: 'Expert builders managing complex construction projects from start to finish',
    features: ['Project Management', 'Cost Estimation', 'Quality Control', 'Timeline Planning']
  },
  {
    icon: Ruler,
    title: 'Architects',
    description: 'Creative professionals designing innovative and functional spaces',
    features: ['Building Design', 'Site Planning', 'Sustainability', 'Code Compliance']
  },
  {
    icon: Wrench,
    title: 'Tradesmen',
    description: 'Skilled specialists in specific construction disciplines',
    features: ['Electrical', 'Plumbing', 'HVAC', 'Carpentry']
  },
  {
    icon: Palette,
    title: 'Interior Designers',
    description: 'Design experts creating beautiful and functional interior spaces',
    features: ['Space Planning', 'Material Selection', 'Color Schemes', 'Furniture Layout']
  }
];

export function ProfessionalCategories() {
  return (
    <section className="py-24 bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl font-bold text-navy-900">
            Find the Right <span className="text-coral-500">Professional</span> for Your Project
          </h2>
          <p className="mt-4 text-xl text-gray-600">
            Connect with verified experts across all construction disciplines
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {categories.map((category) => {
            const Icon = category.icon;
            return (
              <div key={category.title} className="bg-white rounded-lg p-8 shadow-sm hover:shadow-md transition-shadow">
                <div className="h-12 w-12 bg-coral-500/10 rounded-lg flex items-center justify-center mb-6">
                  <Icon className="h-6 w-6 text-coral-500" />
                </div>
                <h3 className="text-xl font-semibold text-navy-900 mb-4">{category.title}</h3>
                <p className="text-gray-600 mb-6">{category.description}</p>
                <ul className="space-y-2">
                  {category.features.map((feature) => (
                    <li key={feature} className="text-sm text-gray-500 flex items-center">
                      <span className="h-1.5 w-1.5 bg-coral-500 rounded-full mr-2"></span>
                      {feature}
                    </li>
                  ))}
                </ul>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}