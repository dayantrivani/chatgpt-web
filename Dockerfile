# build front-end
FROM node:lts-alpine AS frontend

WORKDIR /app

COPY pnpm /root/.local/share/pnpm/store/v3

RUN npm install pnpm -g

COPY ./package.json /app

COPY ./pnpm-lock.yaml /app

COPY . /app

RUN pnpm install

RUN pnpm run build

# build backend
FROM node:lts-alpine as backend

WORKDIR /app

COPY pnpm /root/.local/share/pnpm/store/v3

RUN npm install pnpm -g

COPY /service/package.json /app

COPY /service/pnpm-lock.yaml /app

COPY /service /app

RUN pnpm install

RUN pnpm build

# service
FROM node:lts-alpine

WORKDIR /app

EXPOSE 3002

CMD ["pnpm", "run", "prod"]

RUN npm install pnpm -g

COPY /service/package.json /app

COPY /service/pnpm-lock.yaml /app

RUN pnpm install --production && rm -rf /root/.npm /root/.pnpm-store /usr/local/share/.cache /tmp/*

COPY /service /app

COPY --from=frontend /app/dist /app/public

COPY --from=backend /app/build /app/build
