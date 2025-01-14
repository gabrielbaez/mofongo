# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for development. Use with Docker Compose or build'n'run by hand:
# docker build -t app .
# docker run -d -p 3000:3000 --name app app

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    libpq-dev \
    netcat-openbsd \
    nodejs \
    npm \
    chromium \
    chromium-driver \
    && rm -rf /var/lib/apt/lists/*

# Install yarn
RUN npm install -g yarn

# Create user and set up directory
RUN useradd -m -s /bin/bash appuser && \
    mkdir -p /app && \
    chown -R appuser:appuser /app && \
    mkdir -p /usr/local/bundle && \
    chown -R appuser:appuser /usr/local/bundle

WORKDIR /app

# Switch to appuser for all subsequent operations
USER appuser

# Set up Chrome environment variables
ENV CHROME_BIN=/usr/bin/chromium \
    CHROME_PATH=/usr/lib/chromium/ \
    CHROMEDRIVER_PATH=/usr/bin/chromedriver

# Copy Gemfile and install dependencies
COPY --chown=appuser:appuser Gemfile ./
RUN bundle install

# Copy the rest of the application
COPY --chown=appuser:appuser . .

# Make entrypoint script executable and ensure Unix line endings
USER root
RUN sed -i 's/\r$//' /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh
USER appuser

# Set up entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

# Configure the main process to run when running the image
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
