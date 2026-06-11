FROM node:22-bookworm-slim AS build

RUN apt-get update && apt-get install -y python3 make g++ git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages/app/package.json ./packages/app/package.json
COPY packages/backend/package.json ./packages/backend/package.json

RUN yarn install --immutable

COPY . .

RUN yarn tsc
RUN yarn build:backend

# ---------------- Production ----------------
FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y python3 python3-pip git \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install mkdocs-techdocs-core --break-system-packages

WORKDIR /app

# Copy skeleton and bundle
COPY --from=build /app/packages/backend/dist/skeleton.tar.gz ./
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz

COPY --from=build /app/packages/backend/dist/bundle.tar.gz ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

COPY app-config.yaml ./
COPY app-config.production.yaml ./

ENV NODE_ENV=production
ENV PORT=8080

EXPOSE 8080

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]