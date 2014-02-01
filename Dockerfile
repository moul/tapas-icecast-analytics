FROM moul/node

RUN npm install -g node-dev
ADD . /app
RUN npm -q install --production

ENTRYPOINT ["node-dev", "/app/start.coffee"]
