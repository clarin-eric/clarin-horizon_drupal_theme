#!/bin/sh
PACKAGE_VERSION="${THEME_VERSION}"
DRUPAL_BOOTSTRAP_VERSION="7.x-3.26"
DRUPAL_BOOTSTRAP_STYLES_VERSION="0.0.2"
BASE_STYLE_REPOSITORY="https://github.com/clarin-eric/base_style"
BASE_STYLE_VERSION="0.4.0"
BASE_STYLE_TAG="${BASE_STYLE_VERSION}"

BASE_DIRECTORY=$(cd "$(dirname "$BASH_SOURCE[0]")"; pwd)
OUTPUT_DIRECTORY="${BASE_DIRECTORY}/target"
BUILD_DIRECTORY="${OUTPUT_DIRECTORY}/CLARIN_Horizon/"
BUILD_PACKAGE="${OUTPUT_DIRECTORY}/CLARIN_Horizon-${PACKAGE_VERSION}.tgz"

set -e

#gcp and grm can be installed on MacOS via brew. Run "brew install coreutils" to do so.
RM=`which grm||which rm`  #if grm available (on Mac), use it instead of BSD rm

# Cleanup potential previous build output
${RM} -fr -- "${BUILD_DIRECTORY}" "${BUILD_PACKAGE}" "${OUTPUT_DIRECTORY}/basestyle"

# Create transient directories
mkdir -p "${OUTPUT_DIRECTORY}/basestyle"
mkdir -p "${OUTPUT_DIRECTORY}/bootstrap-${DRUPAL_BOOTSTRAP_VERSION}"
mkdir -p "${BUILD_DIRECTORY}/js"


# Install less compiler if not installed yet
if ! hash lessc 2>/dev/null; then
    echo 'Installing LESS compiler...'
    npm set progress='false'
    npm install --silent --prefix=${OUTPUT_DIRECTORY} --depth '0' 'less' 'less-plugin-clean-css'
    LESSC=${OUTPUT_DIRECTORY}/'node_modules/less/bin/lessc'
else
    LESSC=`which lessc`
fi

echo 'Using lessc: ' ${LESSC}

echo 'Retrieving dependencies...'
# Retrieve bootstrap drupal theme
curl --fail --location --show-error --silent --tlsv1 \
    "https://ftp.drupal.org/files/projects/bootstrap-${DRUPAL_BOOTSTRAP_VERSION}.tar.gz" | \
        tar -x -z -p --strip-components 1 -C "${OUTPUT_DIRECTORY}/bootstrap-${DRUPAL_BOOTSTRAP_VERSION}/" -f - "bootstrap"
mv "${OUTPUT_DIRECTORY}/bootstrap-${DRUPAL_BOOTSTRAP_VERSION}/starterkits/THEMENAME" "${OUTPUT_DIRECTORY}/bootstrap-${DRUPAL_BOOTSTRAP_VERSION}/starterkits/less"
# Retrieve drupal bootstrap styles
curl --fail --location --show-error --silent --tlsv1 \
    "https://codeload.github.com/unicorn-fail/drupal-bootstrap-styles/tar.gz/v${DRUPAL_BOOTSTRAP_STYLES_VERSION}" | \
        tar -x -z -p --strip-components 4 -C "${OUTPUT_DIRECTORY}/bootstrap-${DRUPAL_BOOTSTRAP_VERSION}/starterkits/less/" \
        -f - "drupal-bootstrap-styles-${DRUPAL_BOOTSTRAP_STYLES_VERSION}/src/3.x.x/7.x-3.x/less"
# Retrieve CLARIN base style
curl --fail --location --show-error --silent --tlsv1 \
	"${BASE_STYLE_REPOSITORY}/releases/download/${BASE_STYLE_TAG}/base-style-${BASE_STYLE_VERSION}-less-with-bootstrap.jar" | \
	bsdtar -x -p -C ${OUTPUT_DIRECTORY}/basestyle -f -

echo 'Customising...'
# Prepare less sources transient directory inside basestyle
## Copy drupal bootstrap less files to basestyle
rsync --ignore-existing -r "${OUTPUT_DIRECTORY}/bootstrap-${DRUPAL_BOOTSTRAP_VERSION}/starterkits/less/less" "${OUTPUT_DIRECTORY}/basestyle/"
## Copy source style.less to basetyle
rsync -r "${BASE_DIRECTORY}/src/less/" "${OUTPUT_DIRECTORY}/basestyle/less/"

# Copy static theme resources into package directory
rsync -r "${BASE_DIRECTORY}/src/theme/" "${BUILD_DIRECTORY}"
## Move fonts into package directory
mv -f -- "${OUTPUT_DIRECTORY}/basestyle/fonts" "${BUILD_DIRECTORY}"
## Move bootstrap.js library into package directory
mv -f -- "${OUTPUT_DIRECTORY}/basestyle/js/" "${BUILD_DIRECTORY}/js/bootstrap"

echo 'Compiling LESS...'
## Compile style from basedstyle less folder
${LESSC} "${OUTPUT_DIRECTORY}/basestyle/less/style.less" --clean-css='--s0' > "${BUILD_DIRECTORY}/css/style.css"

echo 'Packaging...'
## Make distribution
tar -c -p -z -f "${BUILD_PACKAGE}" -C "${OUTPUT_DIRECTORY}" "CLARIN_Horizon" "bootstrap-${DRUPAL_BOOTSTRAP_VERSION}"

echo 'Done!

Result written to' ${BUILD_PACKAGE}
