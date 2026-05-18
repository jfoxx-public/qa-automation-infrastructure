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
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]