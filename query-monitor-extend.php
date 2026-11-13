<?php
/**
 * Plugin Name: Query Monitor Extend
 * Plugin URI: https://github.com/crstauf/query-monitor-extend
 * Description: Additional panels for Query Monitor by John Blackbourn.
 * Version: 1.7.2
 * Author: Caleb Stauffer
 * Author URI: https://develop.calebstauffer.com
 * Update URI: false
 * Requires Plugins: query-monitor
 *
 * QM tested up to: 4.1.1
 */

defined( 'WPINC' ) || die();

defined( 'QMX_DISABLED' ) || define( 'QMX_DISABLED', false );

if ( defined( 'QM_DISABLED' ) && constant( 'QM_DISABLED' ) ) {
	return;
}

if ( constant( 'QMX_DISABLED' ) ) {
	return;
}

// Prevent combo mu-plugin and plugin.
if ( defined( 'QMX_LOADED' ) ) {
	trigger_error( sprintf( 'Query Monitor Extend loaded previously: %s', constant( 'QMX_LOADED' ) ), E_USER_NOTICE );
	return;
}

define( 'QMX_LOADED', __FILE__ );

/**
 * Filter: extra_plugin_headers
 *
 * Include the "QM tested up to" header in the plugin data that
 * WordPress reads for the Plugins screen.
 *
 * @param string[] $headers
 * @return string[]
 */
add_filter( 'extra_plugin_headers', static function ( array $headers ) : array {
	$headers[] = 'QM tested up to';

	return $headers;
} );

/**
 * Filter: plugin_row_meta
 *
 * - add "Tested up to" notice
 * - add "Requires QM" notice
 *
 * @param array $meta
 * @param string $file
 * @param array $plugin_data
 * @return string[]
 */
add_filter( 'plugin_row_meta', static function ( array $meta, string $file, array $plugin_data ) : array {
	if ( 'query-monitor-extend/query-monitor-extend.php' !== $file ) {
		return $meta;
	}

	$tested_with_qm = $plugin_data['QM tested up to'] ?? '';

	if ( '' !== $tested_with_qm ) {
		$first = array_shift( $meta );

		array_unshift(
			$meta,
			$first,
			sprintf(
				'Tested up to <a href="%1$s" rel="noopener noreferrer">Query Monitor</a> <a href="%2$s%3$s" rel="noopener noreferrer">%3$s</a>',
				'https://wordpress.org/plugins/query-monitor/',
				'https://github.com/johnbillion/query-monitor/releases/tag/',
				esc_html( $tested_with_qm )
			)
		);
	}

	if ( class_exists( 'QueryMonitor' ) ) {
		return $meta;
	}

	$first = array_shift( $meta );

	array_unshift(
		$meta,
		$first,
		sprintf(
			'Requires <a href="%1$s" rel="noopener noreferrer">Query Monitor</a>',
			'https://wordpress.org/plugins/query-monitor/'
		)
	);

	return $meta;
}, 10, 3 );

$dir = trailingslashit( __DIR__ );

/**
 * If loading as an mu-plugin, add "query-monitor-extend"
 * to directory path.
 */
if ( trailingslashit( constant( 'WPMU_PLUGIN_DIR' ) ) === $dir ) {
	$dir .= 'query-monitor-extend/';
}

# Include hook timing feature; no Query Monitor dependency, so load right away.
include_once $dir . 'qmx-time-hooks.php';

/**
 * Action: plugins_loaded
 *
 * Load collectors and outputters once all plugins are loaded:
 * plugins load alphabetically, so Query Monitor is not yet
 * available when this file is included (unless its db.php
 * drop-in is installed).
 *
 * Priority 9: before Query Monitor registers collectors (10).
 *
 * @return void
 */
add_action( 'plugins_loaded', static function () use ( $dir ) : void {
	if ( ! class_exists( 'QueryMonitor' ) || did_action( 'qm/cease' ) ) {
		return;
	}

	$collector_names = apply_filters( 'qmx/collectors', array(
		'acf',
		'constants',
		'files',
		'globals-get',
		'globals-post',
		'globals-server',
		'heartbeat',
		'image-sizes',
		'paths',
		'time',
	) );

	# Load the shared concerned-hooks outputter before registration runs.
	require_once $dir . 'qmx-output-html-concerned-hooks.php';

	# Include all collector and outputters.
	foreach ( $collector_names as $collector_name ) {
		$files = array(
			sprintf( '%1$s%2$s/qmx-%2$s-collector.php', $dir, $collector_name ),
			sprintf( '%1$s%2$s/qmx-%2$s-output.php', $dir, $collector_name ),
		);

		$files = array_filter( $files, 'file_exists' );

		if ( count( $files ) !== 2 ) {
			continue;
		}

		foreach ( $files as $file ) {
			require_once $file;
		}
	}

	# Include additional conditionals.
	include_once $dir . 'qmx-conditionals.php';
}, 9 );
