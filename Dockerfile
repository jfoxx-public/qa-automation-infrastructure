FROM node:18-alpine AS build-stage

WORKDIR /app

# Clone the sample app repository to test against
RUN apk add --no-cache git
RUN git clone https://github.com/saucelabs/sample-app-web.git .

# Install dependencies and build the app
RUN npm install
RUN npm run build

FROM nginx:alpine

COPY --from=build-stage /app/build /usr/share/nginx/html

# We use printf with single quotes so the IDE linter doesn't crash.
# Nginx will read this template and dynamically replace the ${PORT} variable with the value from docker-compose.
RUN mkdir -p /etc/nginx/templates && \
    printf 'server {\n    listen ${PORT};\n    location / {\n        root /usr/share/nginx/html;\n        index index.html index.htm;\n        try_files $uri $uri/ /index.html;\n    }\n}\n' > /etc/nginx/templates/default.conf.template

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]