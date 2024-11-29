# Use node-python image as the base image
FROM beevk/node-python:0.2

# Set the working directory inside the container
WORKDIR /app

# Copy the local_settings.py file to the working directory
COPY ./sefaria/local_settings.py ./sefaria/local_settings.py

# Copy the requirements.txt file and install dependencies
COPY requirements.txt ./
COPY package*.json ./

# Install global Python and Node.js dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    npm install --unsafe-perm

# Check the installed version of Pillow after installing requirements
RUN python -m pip show Pillow

COPY ./node ./node
COPY ./static/js ./static/js

# Copy prebuilt Webpack bundles into the Docker image
COPY static/bundles/ /app/static/bundles/


# Copy application source code
COPY . ./


COPY staticfiles/ /app/staticfiles/

# Run Django migrations and start the server
CMD ["bash", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]

# Expose the port for the Django application
EXPOSE 8000