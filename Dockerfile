# Stage 1: Build Dependencies Stage
FROM node:20-alpine AS builder

# Set working directory inside the container
WORKDIR /app

# Copy package dependency definitions
COPY package*.json ./

# Install production dependencies safely
RUN npm install --omit=dev

# Copy application source code
COPY . .


# Stage 2: Final Minimal & Secure Production Stage
FROM node:20-alpine AS runner

# Set working directory
WORKDIR /app

# Set environment to production
ENV NODE_ENV=production

# Create a non-root group and user for security compliance
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy built app from builder stage directly to current dir with proper ownership
COPY --chown=appuser:appgroup --from=builder /app .

# Switch ownership to non-root user
USER appuser

# Expose application port
EXPOSE 3000

# Set entrypoint command
CMD ["node", "server.js"]
