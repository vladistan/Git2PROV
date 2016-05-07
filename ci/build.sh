NPM_VOLUME=git2.prov.npm.${GO_PIPELINE_NAME}
NODEMOD_VOLUME=git2.prov.nodemod.${GO_PIPELINE_NAME}

VOL_COMMANDS="-v $NPM_VOLUME:/app/.npm -v $NODEMOD_VOLUME:/app/node_modules"

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

/usr/local/sonar-runner/bin/sonar-runner