FROM jrottenberg/ffmpeg:7.1-nvidia2204

WORKDIR /app

# Ensures tzinfo doesn't ask for region info.
ENV DEBIAN_FRONTEND noninteractive

## INSTALL NODE VIA NVM

RUN apt-get update && apt-get install -y \
    dumb-init \
    xvfb \
    libcairo2-dev \
    libjpeg-dev \
    libpango1.0-dev \
    libgif-dev \
    build-essential \
    g++

# Source: https://gist.github.com/remarkablemark/aacf14c29b3f01d6900d13137b21db3a
# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# update the repository sources list
# and install dependencies
RUN apt-get update \
    && apt-get install -y curl \
    && apt-get -y autoclean

# nvm environment variables
ENV NVM_VERSION 0.40.0
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 16.20.2

# install nvm
# https://github.com/creationix/nvm#install-script
RUN mkdir -p $NVM_DIR \
    && curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash

# install node and npm
RUN source ${NVM_DIR}/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH ${NVM_DIR}/v${NODE_VERSION}/lib/node_modules
ENV PATH      ${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:$PATH

# confirm installation
RUN node -v
RUN npm -v

## INSTALL EDITLY

# ## Install app dependencies
COPY package.json /app/
RUN npm install

# Add app source
COPY . /app

# Ensure `editly` binary available in container
RUN npm link

RUN cd node_modules/canvas && npm rebuild canvas && npm rebuild canvas --update-binary

ENTRYPOINT ["/usr/bin/dumb-init", "--", "xvfb-run", "--server-args", "-screen 0 1280x1024x24 -ac"]
CMD [ "editly" ]
