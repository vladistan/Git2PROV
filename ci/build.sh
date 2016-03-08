docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u $UID:$UID \
       -i -e HOME=/app vladistan/node \
       npm install

docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u $UID:$UID \
       -i -e HOME=/app vladistan/node \
       npm run-script test

docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u $UID:$UID \
       -i -e HOME=/app vladistan/node \
       npm run-script test-cov



docker run -w /app -v `pwd`/.m2:/.m2 -v `pwd`:/app -u $UID:$UID \
       -i -e HOME=/app vladistan/node \
       npm run-script cov-jenkins
