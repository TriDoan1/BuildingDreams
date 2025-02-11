import React, { useState } from 'react';
import { Camera, Building2, CheckCircle, ArrowRight, Upload, MapPin, Briefcase, Phone, Mail, FileText, Award } from 'lucide-react';
import type { User, OnboardingStep } from '../types';

const TRADES = [
  'General Contractor',
  'Electrician',
  'Plumber',
  'Carpenter',
  'Mason',
  'HVAC Technician',
  'Painter',
  'Roofer',
  'Landscaper',
  'Interior Designer'
];

export function Onboarding() {
  const [step, setStep] = useState<OnboardingStep>('personal');
  const [profileData, setProfileData] = useState<Partial<User>>({
    avatar: '',
    rating: 0,
    verified: false
  });
  const [previewImage, setPreviewImage] = useState<string>('');

  const handleImageUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreviewImage(reader.result as string);
        setProfileData({ ...profileData, avatar: reader.result as string });
      };
      reader.readAsDataURL(file);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setProfileData({ ...profileData, [name]: value });
  };

  const handleNext = () => {
    const steps: OnboardingStep[] = ['personal', 'professional', 'verification', 'complete'];
    const currentIndex = steps.indexOf(step);
    if (currentIndex < steps.length - 1) {
      setStep(steps[currentIndex + 1]);
    }
  };

  const renderPersonalInfo = () => (
    <div className="space-y-6">
      <div className="flex flex-col items-center">
        <div className="relative group">
          <div className="w-32 h-32 rounded-full bg-gray-100 flex items-center justify-center overflow-hidden">
            {previewImage ? (
              <img src={previewImage} alt="Profile preview" className="w-full h-full object-cover" />
            ) : (
              <Camera className="h-12 w-12 text-gray-400" />
            )}
          </div>
          <label className="absolute bottom-0 right-0 bg-blue-600 rounded-full p-2 cursor-pointer hover:bg-blue-700">
            <Upload className="h-4 w-4 text-white" />
            <input type="file" className="hidden" onChange={handleImageUpload} accept="image/*" />
          </label>
        </div>
        <p className="mt-2 text-sm text-gray-500">Upload your profile picture</p>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Full Name</label>
        <input
          type="text"
          name="name"
          value={profileData.name || ''}
          onChange={handleInputChange}
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          required
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Email</label>
        <div className="mt-1 relative rounded-md shadow-sm">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center">
            <Mail className="h-4 w-4 text-gray-400" />
          </div>
          <input
            type="email"
            name="email"
            value={profileData.email || ''}
            onChange={handleInputChange}
            className="block w-full pl-10 rounded-md border-gray-300 focus:border-blue-500 focus:ring-blue-500"
            required
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Phone</label>
        <div className="mt-1 relative rounded-md shadow-sm">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center">
            <Phone className="h-4 w-4 text-gray-400" />
          </div>
          <input
            type="tel"
            name="phone"
            value={profileData.phone || ''}
            onChange={handleInputChange}
            className="block w-full pl-10 rounded-md border-gray-300 focus:border-blue-500 focus:ring-blue-500"
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Location</label>
        <div className="mt-1 relative rounded-md shadow-sm">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center">
            <MapPin className="h-4 w-4 text-gray-400" />
          </div>
          <input
            type="text"
            name="location"
            value={profileData.location || ''}
            onChange={handleInputChange}
            className="block w-full pl-10 rounded-md border-gray-300 focus:border-blue-500 focus:ring-blue-500"
            placeholder="City, State"
            required
          />
        </div>
      </div>
    </div>
  );

  const renderProfessionalInfo = () => (
    <div className="space-y-6">
      <div>
        <label className="block text-sm font-medium text-gray-700">Trade</label>
        <div className="mt-1 relative rounded-md shadow-sm">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center">
            <Briefcase className="h-4 w-4 text-gray-400" />
          </div>
          <select
            name="trade"
            value={profileData.trade || ''}
            onChange={handleInputChange}
            className="block w-full pl-10 rounded-md border-gray-300 focus:border-blue-500 focus:ring-blue-500"
            required
          >
            <option value="">Select your trade</option>
            {TRADES.map(trade => (
              <option key={trade} value={trade}>{trade}</option>
            ))}
          </select>
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Years of Experience</label>
        <input
          type="number"
          name="yearsOfExperience"
          value={profileData.yearsOfExperience || ''}
          onChange={handleInputChange}
          min="0"
          className="mt-1 block w-full rounded-md border-gray-300 focus:border-blue-500 focus:ring-blue-500"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Hourly Rate ($)</label>
        <input
          type="number"
          name="hourlyRate"
          value={profileData.hourlyRate || ''}
          onChange={handleInputChange}
          min="0"
          className="mt-1 block w-full rounded-md border-gray-300 focus:border-blue-500 focus:ring-blue-500"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Business Name</label>
        <div className="mt-1 relative rounded-md shadow-sm">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center">
            <Building2 className="h-4 w-4 text-gray-400" />
          </div>
          <input
            type="text"
            name="businessName"
            value={profileData.businessName || ''}
            onChange={handleInputChange}
            className="block w-full pl-10 rounded-md border-gray-300 focus:border-blue-500 focus:ring-blue-500"
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Bio</label>
        <textarea
          name="bio"
          value={profileData.bio || ''}
          onChange={handleInputChange}
          rows={4}
          className="mt-1 block w-full rounded-md border-gray-300 focus:border-blue-500 focus:ring-blue-500"
          placeholder="Tell us about your experience and expertise..."
        />
      </div>
    </div>
  );

  const renderVerification = () => (
    <div className="space-y-6">
      <div>
        <label className="block text-sm font-medium text-gray-700">License Number</label>
        <div className="mt-1 relative rounded-md shadow-sm">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center">
            <Award className="h-4 w-4 text-gray-400" />
          </div>
          <input
            type="text"
            name="licenseNumber"
            value={profileData.licenseNumber || ''}
            onChange={handleInputChange}
            className="block w-full pl-10 rounded-md border-gray-300 focus:border-blue-500 focus:ring-blue-500"
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Insurance Information</label>
        <div className="mt-1 relative rounded-md shadow-sm">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center">
            <FileText className="h-4 w-4 text-gray-400" />
          </div>
          <input
            type="text"
            name="insuranceInfo"
            value={profileData.insuranceInfo || ''}
            onChange={handleInputChange}
            className="block w-full pl-10 rounded-md border-gray-300 focus:border-blue-500 focus:ring-blue-500"
            placeholder="Insurance provider and policy number"
          />
        </div>
      </div>

      <div className="bg-blue-50 p-4 rounded-md">
        <p className="text-sm text-blue-700">
          Your information will be verified within 24-48 hours. We'll notify you by email once the verification is complete.
        </p>
      </div>
    </div>
  );

  const renderComplete = () => (
    <div className="text-center">
      <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-green-100">
        <CheckCircle className="h-6 w-6 text-green-600" />
      </div>
      <h2 className="mt-4 text-lg font-medium text-gray-900">Profile Setup Complete!</h2>
      <p className="mt-2 text-sm text-gray-500">
        Your profile is now set up and pending verification. You'll receive an email once your account is verified.
      </p>
      <button
        className="mt-6 inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
      >
        Go to Dashboard
      </button>
    </div>
  );

  const renderStepContent = () => {
    switch (step) {
      case 'personal':
        return renderPersonalInfo();
      case 'professional':
        return renderProfessionalInfo();
      case 'verification':
        return renderVerification();
      case 'complete':
        return renderComplete();
      default:
        return null;
    }
  };

  const renderProgressBar = () => {
    const steps = [
      { id: 'personal', name: 'Personal Info' },
      { id: 'professional', name: 'Professional Details' },
      { id: 'verification', name: 'Verification' },
    ];

    return (
      <div className="py-4">
        <div className="flex items-center justify-between w-full">
          {steps.map((s, i) => (
            <div key={s.id} className="flex items-center">
              <div className={`flex items-center justify-center w-8 h-8 rounded-full ${
                steps.findIndex(x => x.id === step) >= i ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-400'
              }`}>
                {i + 1}
              </div>
              <div className="ml-2 text-sm font-medium text-gray-500">{s.name}</div>
              {i < steps.length - 1 && (
                <div className="ml-4 w-24 h-0.5 bg-gray-200" />
              )}
            </div>
          ))}
        </div>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="max-w-3xl mx-auto">
        <div className="bg-white rounded-lg shadow px-6 py-8">
          <h1 className="text-2xl font-bold text-gray-900 mb-6">Complete Your Profile</h1>
          
          {step !== 'complete' && renderProgressBar()}
          
          <div className="mt-6">
            {renderStepContent()}
          </div>
          
          {step !== 'complete' && (
            <div className="mt-8 flex justify-end">
              <button
                onClick={handleNext}
                className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
              >
                {step === 'verification' ? 'Submit' : 'Next'}
                <ArrowRight className="ml-2 h-4 w-4" />
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}