FROM node:20-bullseye AS Build 

WORKDIR /workspace

COPY . .

RUN npm i 