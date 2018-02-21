#!/bin/sh

SCRIPT="$0"

while [ -h "$SCRIPT" ] ; do
  ls=$(ls -ld "$SCRIPT")
  link=$(expr "$ls" : '.*-> \(.*\)$')
  if expr "$link" : '/.*' > /dev/null; then
    SCRIPT="$link"
  else
    SCRIPT=$(dirname "$SCRIPT")/"$link"
  fi
done

if [ ! -d "${APP_DIR}" ]; then
  APP_DIR=$(dirname "$SCRIPT")/..
  APP_DIR=$(cd "${APP_DIR}"; pwd)
fi

executable="./modules/swagger-codegen-cli/target/swagger-codegen-cli.jar"

if [ ! -f "$executable" ]
then
  mvn clean package
fi

# if you've executed sbt assembly previously it will use that instead.
export JAVA_OPTS="${JAVA_OPTS} -XX:MaxPermSize=256M -Xmx1024M -DloggerPath=conf/log4j.properties"
ags="generate -t modules/swagger-codegen/src/main/resources/kotlin-client -i /Users/xiaowen/Developer/api-specification/dist/specification.yml -l kotlin --artifact-id kotlin-vc-client -o kotlin $@"

java ${JAVA_OPTS} -jar ${executable} ${ags}
cd kotlin/src/main/kotlin/fr/vestiairecollective/network/redesign/model
sed -i.bak 's/, )/)/' *.kt
rm *.bak
cd -