PARSER_VERSION=0.18.16

# This make command curls the examples for certain repos.
# If the rule doesn't exist, the error doesn't interrupt the build process.
make examples

if [ ! -d "snooty-parser" ]; then
  echo "Snooty parser not installed, downloading..."
  curl -L -o snooty-parser.zip https://github.com/mongodb/snooty-parser/releases/download/v${PARSER_VERSION}/snooty-v${PARSER_VERSION}-linux_x86_64.zip
  unzip -d ./snooty-parser snooty-parser.zip
  chmod +x ./snooty-parser/snooty
fi

echo "======================================================================================================================================================================="
echo "========================================================================== Running parser... =========================================================================="
./snooty-parser/snooty/snooty build docs-java/ --no-caching --output=./bundle-java.zip --branch=${BRANCH_NAME}
echo "========================================================================== Parser complete ============================================================================"
echo "======================================================================================================================================================================="

./snooty-parser/snooty/snooty build docs-relational-migrator/ --no-caching --output=./bundle-migrator.zip --branch=${BRANCH_NAME}

ls 

if [ ! -d "snooty" ]; then
  echo "snooty frontend not installed, downloading"
  git clone -b netlify-poc --depth 1 https://github.com/mongodb/snooty.git 
  pushd snooty
  npm ci --legacy-peer-deps
  popd
fi

# if [ -d "docs-worker-pool" ]; then
#   echo "Running persistence module"
#   node --unhandled-rejections=strict docs-worker-pool/modules/persistence/dist/index.js --path bundle.zip --githubUser netlify
# fi



echo GATSBY_MANIFEST_PATH=$(pwd)/bundle-java.zip > snooty/.env.production
echo PATH_PREFIX=/java >> snooty/.env.production 

pushd snooty
ls -a 
npm run build
mv ./public ./java
popd

echo GATSBY_MANIFEST_PATH=$(pwd)/bundle-migrator.zip > snooty/.env.production 

pushd snooty
npm run build:no-prefix 
mv ./java ./public/java
popd
