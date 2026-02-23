/*
===============================================================================
 Project: Data Warehouse Setup
 File: 01_database_setup.sql

 Description:
 This script resets the development environment by:
   1. Switching to a safe system database.
   2. Dropping the 'datawarehouse' database if it exists.
   3. Creating a fresh 'datawarehouse' database.
   4. Setting it as the active database.

 WARNING:
 Running this script will permanently delete the entire 'datawarehouse'
 database if it already exists, including all tables and data.
 Use only in development environments.
===============================================================================
*/

-- Switch to a safe database to avoid dropping the one in use
USE mysql;

-- Drop database if it exists
DROP DATABASE IF EXISTS DataWarehouse;

-- Create a fresh database
CREATE DATABASE datawarehouse;

-- Use the new database
USE datawarehouse;
