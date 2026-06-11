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
 
RUN yarn workspace backend build
 
# --- Production ---
FROM node:22-bookworm-slim
 
RUN apt-get update && apt-get install -y python3 python3-pip git \
    && rm -rf /var/lib/apt/lists/*
 
RUN pip3 install mkdocs-techdocs-core --break-system-packages
 
WORKDIR /app
 
COPY --from=build /app/packages/backend/dist/bundle.tar.gz .
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz
 
COPY --from=build /app/node_modules ./node_modules
 
COPY app-config.yaml .
COPY app-config.production.yaml .
 
ENV NODE_ENV=production
EXPOSE 8080
 
CMD ["node", "packages/backend", \
     "--config", "app-config.yaml", \
     "--config", "app-config.production.yaml"]