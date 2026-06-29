FROM public.ecr.aws/nginx/nginx:latest

COPY webpages /usr/share/nginx/html/

# Expose port 80 for documentation purposes
EXPOSE 80
