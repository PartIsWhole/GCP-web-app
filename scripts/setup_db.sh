#!/bin/bash

# Exit on error
set -e

echo "========================================"
echo "      Setting up PostgreSQL Database    "
echo "========================================"

DB_NAME="app_db"
DB_USER="admin"
DB_PASS="admin@123"

# Create User if it doesn't exist
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1 || sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"

# Create Database if it doesn't exist
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1 || sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"

echo "Database '$DB_NAME' is ready with user '$DB_USER'."