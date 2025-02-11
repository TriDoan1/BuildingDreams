import { viewProfessionals, viewProjects } from './dbViewer';

// View all data
console.log('Fetching database data...');

Promise.all([
  viewProfessionals(),
  viewProjects()
]).then(() => {
  console.log('Data fetch complete. Check the console output above for results.');
}).catch(error => {
  console.error('Error fetching data:', error);
});