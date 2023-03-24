FROM openwhisk/action-nodejs-v14:1.20.0

# Install request module
RUN npm install request

CMD ["node", "--expose-gc", "app.js"]