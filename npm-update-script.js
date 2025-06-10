const { execSync } = require('child_process');

console.log('Updating dependencies to fix security vulnerabilities...');

try {
  // Install updated dependencies
  execSync('npm install', { stdio: 'inherit' });

  // Rebuild the project
  execSync('npm run build', { stdio: 'inherit' });

  console.log('Successfully updated dependencies and rebuilt the project!');
} catch (error) {
  console.error('Error updating dependencies:', error);
  process.exit(1);
}
