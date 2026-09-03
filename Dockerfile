# syntax=docker/dockerfile:1

# Vite + Vue SPA → nginx (port 3000, matches host reverse-proxy pattern)

FROM node:20-alpine AS builder
WORKDIR /app
RUN apk add --no-cache libc6-compat
COPY frontend/package.json frontend/package-lock.json ./
ENV CI=true
ENV NPM_CONFIG_REGISTRY=https://registry.npmjs.org/
ENV NPM_CONFIG_LEGACY_PEER_DEPS=true
ENV NODE_OPTIONS=--max-old-space-size=4096
RUN npm ci
COPY frontend/ ./
# Optional: override Polygon RPC at image build time (useful in China)
ARG VITE_POLYGON_RPC_URL
ENV VITE_POLYGON_RPC_URL=$VITE_POLYGON_RPC_URL
RUN npm run build

FROM nginx:1.27-alpine AS runner
COPY deploy/docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/health >/dev/null || exit 1
CMD ["nginx", "-g", "daemon off;"]
