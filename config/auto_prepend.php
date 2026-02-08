<?php
/**
 * Auto-prepend file for reverse proxy HTTPS detection
 * This file is automatically included before all PHP scripts
 * It fixes $_SERVER['REQUEST_SCHEME'] when behind a reverse proxy
 */

// Override REQUEST_SCHEME if we detect HTTPS from reverse proxy
if (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') {
    $_SERVER['REQUEST_SCHEME'] = 'https';
}
