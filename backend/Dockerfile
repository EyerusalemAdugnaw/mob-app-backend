# Use an official Node.js runtime as the base image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install the application dependencies
RUN npm ci --omit=dev

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on. 
# Cloud providers (like Railway) will inject their own PORT environment variable, 
# but we expose 9000 as the default fallback.
EXPOSE 9000

# Start the application
CMD ["npm", "start"]
