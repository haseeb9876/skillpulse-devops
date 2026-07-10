FROM nginx:stable-alpine3.23

RUN rm -f /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/conf.d/skillpulse.conf

COPY index.html /usr/share/nginx/html/index.html
COPY css /usr/share/nginx/html/css
COPY js /usr/share/nginx/html/js

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://127.0.0.1/ || exit 1
