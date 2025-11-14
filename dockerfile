# ------------------------------
# 1️⃣ Build Stage
# ------------------------------
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first (caching)
COPY package*.json ./

# Install all dependencies (including devDependencies for build)
RUN npm ci

# Copy the rest of the app
COPY . .

# Build the NestJS app
RUN npm run build

# ------------------------------
# 2️⃣ Production Stage
# ------------------------------
FROM node:18-alpine

WORKDIR /app

# Copy only package.json and package-lock.json
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Copy built files from build stage
COPY --from=build /app/dist ./dist

# Copy .env or any other required files
COPY --from=build /app/.env ./

# Expose the port your NestJS app uses
EXPOSE 3000

CMD ["node", "dist/main.js"]
