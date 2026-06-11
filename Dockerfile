FROM node:22-bookworm-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    pip3 install --break-system-packages mkdocs-techdocs-core

COPY . .

RUN yarn install

RUN yarn build:backend

EXPOSE 7007

CMD ["node", "packages/backend", "--config", "app-config.yaml"]