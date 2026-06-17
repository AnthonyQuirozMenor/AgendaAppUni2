FROM nginx:alpine

# Copy the built Flutter web files into the default Nginx public directory
COPY build/web /usr/share/nginx/html

# Expose port 80 to access the application
EXPOSE 80

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
