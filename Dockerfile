FROM node:24-alpine AS development

WORKDIR /app

RUN chown node:node /app
USER node

ENV NODE_ENV=development

COPY --chown=node:node package.json package-lock.json ./
RUN npm ci --include=dev

COPY --chown=node:node . .

EXPOSE 3000
CMD ["npm", "run", "start:dev"]

FROM development AS build

RUN npm run build

FROM node:24-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=build --chown=node:node /app/dist ./dist

USER node

EXPOSE 3000
CMD ["node", "dist/main.js"]
