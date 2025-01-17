FROM node:lts AS BUILD_IMAGE
WORKDIR /app
COPY . /app
RUN yarn install --registry https://registry.npmmirror.com/ && yarn run build

FROM node:lts-alpine
COPY --from=BUILD_IMAGE /app/configs /app/configs
COPY --from=BUILD_IMAGE /app/package.json /app/package.json
COPY --from=BUILD_IMAGE /app/dist /app/dist
COPY --from=BUILD_IMAGE /app/public /app/public
COPY --from=BUILD_IMAGE /app/*.wasm /app/
COPY --from=BUILD_IMAGE /app/node_modules /app/node_modules

RUN addgroup -g 1014 appuser && \
    adduser -u 10001 -G appuser -s /bin/sh --disabled-password appuser && \
    chown -R appuser:appuser /app && \
    mkdir -p /app/logs

USER 10001

WORKDIR /app

EXPOSE 8000

CMD ["npm", "start"]
