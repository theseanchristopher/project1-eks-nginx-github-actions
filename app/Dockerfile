FROM nginx:alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy custom index.html
COPY index.html /usr/share/nginx/html/index.html

