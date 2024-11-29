# Use node-python image as the base image
FROM beevk/node-python:0.2

# Set the working directory inside the container
WORKDIR /app

# Copy the local_settings.py file to the working directory
COPY ./sefaria/local_settings.py ./sefaria/local_settings.py

# Copy the requirements.txt file and package.json files for dependencies
COPY requirements.txt ./
COPY package*.json ./

# Install global Python and Node.js dependencies
RUN pip install -r requirements.txt
RUN npm install --unsafe-perm

# Check the installed version of Pillow after installing requirements
RUN python -m pip show Pillow

# Copy JavaScript files and node dependencies
COPY ./node ./node
COPY ./static/js ./static/js

# Run setup and build for the node-based components
RUN npm run setup
RUN npm run build-prod

# Install Nginx and Supervisor (to manage multiple processes)
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor && \
    apt-get clean

# Copy the entire application source code
COPY . ./

# Copy Nginx configuration
COPY ./nginx.conf /etc/nginx/nginx.conf

# Copy Supervisor configuration
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Collect static files for Django
RUN python manage.py collectstatic --noinput

# Expose ports for Nginx and Django
EXPOSE 80 8000

# Start Supervisor to manage both Nginx and Django
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
