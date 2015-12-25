FROM node:5

MAINTAINER Gabor Szathmari "gszathmari@gmail.com"

ENV APPLICATION_NAME sritest-backend

COPY package.json /tmp/package.json
WORKDIR /tmp
RUN npm install
RUN mkdir /app && cp -R /tmp/node_modules /app
RUN npm install -g coffee-script forever gulp

WORKDIR /app
COPY . /app
RUN gulp build

CMD ["forever", "./dist/server.js"]

EXPOSE 8080
