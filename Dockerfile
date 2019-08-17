# FROM node:10.15.0-alpine

# WORKDIR /usr/src/your-app

# COPY package*.json ./

# RUN if [ "$NODE_ENV" = "development" ]; \
#     then npm install;  \
#     else npm install --only=production; \
#     fi

# EXPOSE 3000 5000 9229

# COPY . .


# common base image for development and production
FROM node:10.15.0-alpine AS base

WORKDIR /usr/src/app

EXPOSE 3000 5000 9229

# dev image contains everything needed for testing, development and building
FROM base AS development

COPY package*.json ./

# first set aside prod dependencies so we can copy in to the prod image
RUN npm install --only=production
RUN cp -R node_modules /tmp/node_modules

# install all dependencies and add source code
RUN npm install 
COPY . .


# builder runs unit tests and linter, then builds production code 
FROM development as builder
# RUN yarn lint
# RUN yarn test:unit --colors

RUN npm run build

RUN ls -d build/*

# release includes bare minimum required to run the app, copied from builder
FROM base AS release
COPY --from=builder /tmp/node_modules ./node_modules
COPY --from=builder /usr/src/app/build ./build
COPY --from=builder /usr/src/app/package.json ./
RUN ls
