<?php
$db = new SQLite3('/opt/catalog.db');
$db->exec('DROP TABLE IF EXISTS users');
$db->exec('CREATE TABLE users (id INTEGER PRIMARY KEY, username TEXT, password TEXT, role TEXT)');
$db->exec("INSERT INTO users (username, password, role) VALUES ('guest', 'guest', 'user')");
$db->exec("INSERT INTO users (username, password, role) VALUES ('catalog_admin', 'SummerCatalog1', 'admin')");
