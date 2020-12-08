FROM node:alpine as builder
RUN mkdir /opt/scoresauce
COPY package.json /opt/scoresauce/package.json
COPY yarn.lock /opt/scoresauce/yarn.lock
WORKDIR /opt/scoresauce
RUN yarn install
COPY public /opt/scoresauce/public
COPY src /opt/scoresauce/src
RUN yarn build

FROM nginx:alpine
COPY --from=builder /opt/scoresauce/build /usr/share/nginx/html
