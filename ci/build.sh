#/bin/bash
set -e

NPM_VOLUME=git2.prov.npm.${GO_PIPELINE_NAME}
NODEMOD_VOLUME=git2.prov.nodemod.${GO_PIPELINE_NAME}

VOL_COMMANDS="-v $NPM_VOLUME:/app/.npm -v $NODEMOD_VOLUME:/app/node_modules"

DOCKER_VERSION=$(docker --version | sed 's/[^0-9]//g')
if [ "x${DOCKER_VERSION}" == x17178629171  ]; then
   echo "Old Docker detected"
   VOL_COMMANDS=''
   mkdir -p .npm
   mkdir -p node_modules
fi

echo "Initial UID: ${UID}"

export


if [ "x${UID}" == "x" ]; then
   UID=500
fi

echo "My UID : ${UID}"

echo Reset Permissions
docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u 0:0 \
       $VOL_COMMANDS \
       -i -e HOME=/app vladistan/node \
       chown -R $UID /app/.npm

docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u 0:0 \
       $VOL_COMMANDS \
       -i -e HOME=/app vladistan/node \
       chown -R $UID /app/node_modules

echo Install NPM packs
docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u $UID:$UID \
       $VOL_COMMANDS \
       -i -e HOME=/app vladistan/node \
       npm install

echo Test
docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u $UID:$UID \
       $VOL_COMMANDS \
       -i -e HOME=/app vladistan/node \
       npm run-script test

echo Cover
docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u $UID:$UID \
       $VOL_COMMANDS \
       -i -e HOME=/app vladistan/node \
       npm run-script test-cov


echo Convert Cover
docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u $UID:$UID \
       $VOL_COMMANDS \
       -i -e HOME=/app vladistan/node \
       npm run-script cov-jenkins

sed  -i.bak  's@^SF:/app/@SF:@' coverage/lcov.info


# Get project key from SSM
SONAR_PROJECT_KEY=git2prov
SONAR_TOKEN=$(aws ssm get-parameter --name /ci/sonar/ga_token --with-decryption --query Parameter.Value --output text)

docker run \
    --rm \
    -u "$(id -u go)" \
    -e SONAR_HOST_URL="http://sonar.r4.v-lad.org:9000" \
    -e SONAR_SCANNER_OPTS="-Dsonar.projectKey=${SONAR_PROJECT_KEY}" \
    -v "$(pwd):/usr/src" \
    sonarsource/sonar-scanner-cli:5.0.1 \
    -Dsonar.sources=/usr/src \
    -Dsonar.login="${SONAR_TOKEN}"
