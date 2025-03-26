FROM node:23-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app

RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile

RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app

# Set default port for Render
ENV PORT=10000
# Set listen address to 0.0.0.0 for Render
ENV API_LISTEN_ADDRESS=0.0.0.0

COPY --from=build --chown=node:node /prod/api /app

USER node

EXPOSE ${PORT}
CMD [ "node", "src/cobalt" ]
