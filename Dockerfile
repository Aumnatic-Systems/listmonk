# STEP 1: Build the Frontend (UI)
FROM node:22-alpine AS frontend-builder
WORKDIR /frontend
# Pre-create directory to satisfy internal build dependencies
RUN mkdir -p /static/public/static && touch .gitignore
RUN corepack enable && corepack prepare yarn@stable --activate
COPY frontend/package.json frontend/yarn.lock ./
RUN yarn install --network-timeout 600000
COPY frontend/ .
RUN touch .gitignore && yarn build

# STEP 2: Build the Backend (The Engine)
FROM golang:1.24-alpine AS backend-builder
RUN apk add --no-cache make git grep
WORKDIR /listmonk
COPY . .
# Compile the binary
RUN make build

# STEP 3: Final Production Image
FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /listmonk

# 1. Create all possible paths the app might look for
RUN mkdir -p uploads static/frontend i18n queries frontend static/public/static

# 2. Copy the Binary
COPY --from=backend-builder /listmonk/listmonk .

# 3. THE PATH FIX: Copy UI to both expected locations (Resolves 'stat frontend/dist' error)
COPY --from=frontend-builder /frontend/dist ./frontend/dist
COPY --from=frontend-builder /frontend/dist ./static/frontend/dist

# 4. Copy Support Folders (Preserving source structure for email-templates etc.)
COPY --from=backend-builder /listmonk/static ./static
COPY --from=backend-builder /listmonk/i18n ./i18n
COPY --from=backend-builder /listmonk/queries ./queries

# 5. Copy Database & Config files
# Wildcards handle schema.sql and queries.sql at the root
COPY --from=backend-builder /listmonk/*.sql ./
COPY --from=backend-builder /listmonk/*.json ./
COPY --from=backend-builder /listmonk/config.toml.sample ./config.toml.sample
COPY --from=backend-builder /listmonk/config.toml.sample ./config.toml

# 6. Logo Injection (FIXED: Removed invalid shell logic)
# Note: This requires your logo to exist at static/public/static/logo.png in the repo
COPY --from=backend-builder /listmonk/static/public/static/logo.png ./static/public/static/logo.png
COPY --from=backend-builder /listmonk/static/public/static/logo.png ./static/public/logo.png

EXPOSE 9000
CMD ["./listmonk"]