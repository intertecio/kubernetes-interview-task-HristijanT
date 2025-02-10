FROM node:20-slim

WORKDIR /src/app

COPY app/package*.json ./

RUN npm install

COPY app/src/ .

EXPOSE 3000

CMD ["npm", "start"]