#/bin/bash
set -e

NPM_VOLUME=git2.prov.npm.${GO_PIPELINE_NAME}
NODEMOD_VOLUME=git2.prov.nodemod.${GO_PIPELINE_NAME}

VOL_COMMANDS="-v $NPM_VOLUME:/app/.npm -v $NODEMOD_VOLUME:/app/node_modules"

DOCKER_VERSION=$(docker --version | sed 's/[^0-9]//g')
if [ x${DOCKER_VERSION} == x17178629171  ]; then
   echo "Old Docker detected"
   VOL_COMMANDS=''
   mkdir -p .npm
   mkdir -p node_modules
fi

echo "My UID : ${UID}"

docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u 0:0 \
       $VOL_COMMANDS \
       -i -e HOME=/app vladistan/node \
       chown -R $UID /app/.npm

docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u 0:0 \
       $VOL_COMMANDS \
       -i -e HOME=/app vladistan/node \
       chown -R $UID /app/node_modules

docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u $UID:$UID \
       $VOL_COMMANDS \
       -i -e HOME=/app vladistan/node \
       npm install

docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u $UID:$UID \
       $VOL_COMMANDS \
       -i -e HOME=/app vladistan/node \
       npm run-script test

docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u $UID:$UID \
       $VOL_COMMANDS \
       -i -e HOME=/app vladistan/node \
       npm run-script test-cov



docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u $UID:$UID \
       $VOL_COMMANDS \
       -i -e HOME=/app vladistan/node \
       npm run-script cov-jenkins

sed  -i.bak  's@^SF:/app/@SF:@' coverage/lcov.info

/usr/local/sonar-runner/bin/sonar-runner
