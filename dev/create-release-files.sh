#!/bin/bash

# Creates release zips with the following panels:
# - ACF
# - Constants
# - Files
# - Globals: $_GET
# - Globals: $_POST
# - Globals: $_SERVER
# - Heartbeat
# - Image Sizes
# - Paths
# - Time
#
# Requires the zip command. See "Building the zip files" in readme.md.

if ! command -v zip > /dev/null 2>&1; then
	echo "The zip command is required. See \"Building the zip files\" in readme.md.";
	exit 1;
fi

rm -rf dist;

echo "Making directories...";

mkdir dist;
mkdir dist/plugins;
mkdir dist/mu-plugins;
mkdir dist/plugins/query-monitor-extend;
mkdir dist/mu-plugins/query-monitor-extend;

echo "Copying directories...";

# ACF
cp -r acf/ dist/plugins/query-monitor-extend/acf;
cp -r acf/ dist/mu-plugins/query-monitor-extend/acf;
echo "- acf";

# Constants
cp -r constants/ dist/plugins/query-monitor-extend/constants;
cp -r constants/ dist/mu-plugins/query-monitor-extend/constants;
echo "- constants";

# Files
cp -r files/ dist/plugins/query-monitor-extend/files;
cp -r files/ dist/mu-plugins/query-monitor-extend/files;
echo "- files";

# Globals: $_GET
cp -r globals-get/ dist/plugins/query-monitor-extend/globals-get;
cp -r globals-get/ dist/mu-plugins/query-monitor-extend/globals-get;
echo "- globals-get";

# Globals: $_POST
cp -r globals-post/ dist/plugins/query-monitor-extend/globals-post;
cp -r globals-post/ dist/mu-plugins/query-monitor-extend/globals-post;
echo "- globals-post";

# Globals: $_SERVER
cp -r globals-server/ dist/plugins/query-monitor-extend/globals-server;
cp -r globals-server/ dist/mu-plugins/query-monitor-extend/globals-server;
echo "- globals-server";

# Heartbeat
cp -r heartbeat/ dist/plugins/query-monitor-extend/heartbeat;
cp -r heartbeat/ dist/mu-plugins/query-monitor-extend/heartbeat;
echo "- heartbeat";

# Image Sizes
cp -r image-sizes/ dist/plugins/query-monitor-extend/image-sizes;
cp -r image-sizes/ dist/mu-plugins/query-monitor-extend/image-sizes;
echo "- image-sizes";

# Paths
cp -r paths/ dist/plugins/query-monitor-extend/paths;
cp -r paths/ dist/mu-plugins/query-monitor-extend/paths;
echo "- paths";

# Time
cp -r time/ dist/plugins/query-monitor-extend/time;
cp -r time/ dist/mu-plugins/query-monitor-extend/time;
echo "- time";

echo "Copying files...";

# Conditionals
cp qmx-conditionals.php dist/plugins/query-monitor-extend/qmx-conditionals.php;
cp qmx-conditionals.php dist/mu-plugins/query-monitor-extend/qmx-conditionals.php;
echo "- qmx-conditionals.php";

# Plugin files
cp query-monitor-extend.php dist/plugins/query-monitor-extend/query-monitor-extend.php;
cp query-monitor-extend.php dist/mu-plugins/query-monitor-extend/query-monitor-extend.php;
cp qmx-output-html-concerned-hooks.php dist/plugins/query-monitor-extend/qmx-output-html-concerned-hooks.php;
cp qmx-output-html-concerned-hooks.php dist/mu-plugins/query-monitor-extend/qmx-output-html-concerned-hooks.php;
echo "- query-monitor-extend.php";

# Time hooks
cp qmx-time-hooks.php dist/plugins/query-monitor-extend/qmx-time-hooks.php;
cp qmx-time-hooks.php dist/mu-plugins/query-monitor-extend/qmx-time-hooks.php;
echo "- qmx-time-hooks.php";

echo "Creating mu-plugin loader...";

# Create file to load mu-plugin.
# Uses printf, as echo only expands "\t" and "\n" in some shells.
# Query Monitor fires plugin_loaded when activated on a site, and
# network_plugin_loaded when network-activated.
head -13 query-monitor-extend.php > dist/mu-plugins/load-qmx.php;
printf '%s\n' "function qmx_load_after_query_monitor( string \$plugin ) : void {" >> dist/mu-plugins/load-qmx.php;
printf '\t%s\n\t\t%s\n\t%s\n\n' "if ( trailingslashit( constant( 'WP_PLUGIN_DIR' ) ) . 'query-monitor/query-monitor.php' !== \$plugin ) {" "return;" "}" >> dist/mu-plugins/load-qmx.php;
printf '\t%s\n' "require_once 'query-monitor-extend/query-monitor-extend.php';" >> dist/mu-plugins/load-qmx.php;
printf '%s\n\n' "}" >> dist/mu-plugins/load-qmx.php;
printf '%s\n' "add_action( 'plugin_loaded', 'qmx_load_after_query_monitor' );" >> dist/mu-plugins/load-qmx.php;
printf '%s\n' "add_action( 'network_plugin_loaded', 'qmx_load_after_query_monitor' );" >> dist/mu-plugins/load-qmx.php;

echo "";
echo "Done copying files.";

echo "";
echo "==========================================="
echo "";

ls -lR dist;

echo "";
echo "==========================================="
echo "";

echo "Creating zips..."
echo ""

cd dist/plugins/;
zip --test --display-bytes --display-counts -r "../plugin.zip" query-monitor-extend/;
cd ../../;

echo ""

cd dist/;
zip --test --display-bytes --display-counts -r "mu-plugin.zip" mu-plugins/;
cd ../../;

echo ""
echo "Done creating zip files."
echo ""

echo "Complete"
