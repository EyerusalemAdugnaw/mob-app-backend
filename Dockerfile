# Use an official Node.js runtime as the base image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /app

# Copy the backend package.json and package-lock.json
COPY backend/package*.json ./

# Install the application dependencies
RUN npm ci --omit=dev

# Copy the rest of the backend application code
COPY backend/ .

# Expose the port the app runs on.
EXPOSE 9000

# Start the application
CMD ["npm", "start"]
