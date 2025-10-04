# Use official Node 16 image as base
FROM node:16

# Set working directory inside container
WORKDIR /usr/src/app

# Copy package files first to install dependencies
COPY package*.json ./

# Install dependencies
RUN npm install --save

# Copy rest of the application
COPY . .

# Expose port 8080 (Elastic Beanstalk/Express default)
EXPOSE 8080

# Start the Node app
CMD ["npm", "start"]
