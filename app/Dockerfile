FROM nginx:alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy custom index.html
COPY index.html /usr/share/nginx/html/index.html

# Copy metrics file
COPY app/metrics/metrics.prom /usr/share/nginx/html/metrics/metrics.prom

# Custom Nginx config with /metrics endpoint
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
