#!/bin/bash

# DazzloDocs Deployment Script for Render
echo "🚀 Starting DazzloDocs deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_blue() {
    echo -e "${BLUE}[DEPLOY]${NC} $1"
}

# Check if running in production
if [ "$NODE_ENV" = "production" ]; then
    print_blue "Production environment detected"
else
    print_warning "Not running in production mode"
fi

# Create necessary directories
print_status "Creating required directories..."
mkdir -p temp
mkdir -p outputs
mkdir -p uploads
mkdir -p public

# Set correct permissions
print_status "Setting directory permissions..."
chmod 755 temp outputs uploads public

# Install dependencies
print_status "Installing dependencies..."
npm ci --only=production

# Verify Puppeteer installation
print_status "Verifying Puppeteer installation..."
if command -v google-chrome-stable &> /dev/null; then
    print_status "Chrome found: $(google-chrome-stable --version)"
else
    print_warning "Chrome not found - will try to use Puppeteer's bundled Chromium"
fi

# Check environment variables
print_status "Checking environment variables..."
if [ -n "$PUPPETEER_EXECUTABLE_PATH" ]; then
    print_status "PUPPETEER_EXECUTABLE_PATH: $PUPPETEER_EXECUTABLE_PATH"
else
    print_warning "PUPPETEER_EXECUTABLE_PATH not set"
fi

# Test Chrome availability
print_status "Testing Chrome availability..."
if [ -n "$PUPPETEER_EXECUTABLE_PATH" ] && [ -f "$PUPPETEER_EXECUTABLE_PATH" ]; then
    print_status "Chrome executable found at: $PUPPETEER_EXECUTABLE_PATH"
elif command -v google-chrome-stable &> /dev/null; then
    print_status "Chrome found in system PATH"
else
    print_error "Chrome not found! PDF conversion may fail."
    exit 1
fi

# Create a test file to verify everything works
print_status "Creating test HTML file..."
cat > temp/test.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>DazzloDocs Deployment Test</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .header { background: #008080; color: white; padding: 20px; text-align: center; }
    </style>
</head>
<body>
    <div class="header">
        <h1>DazzloDocs Deployment Test</h1>
        <p>If you can see this PDF, the deployment was successful!</p>
    </div>
    <p>Deployment completed at: $(date)</p>
</body>
</html>
EOF

print_status "Deployment preparation completed successfully!"
print_blue "DazzloDocs is ready for production!"

# Print deployment info
echo ""
echo "🎉 Deployment Summary:"
echo "   📦 Dependencies: Installed"
echo "   🌐 Chrome: Available"
echo "   📁 Directories: Created"
echo "   🔧 Permissions: Set"
echo "   ✅ Status: Ready"
echo ""
print_green "🚀 Start the application with: npm start"