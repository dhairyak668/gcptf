#!/bin/bash

# Update system packages
apt-get update

# Install required system packages
apt-get install -y git python3-pip python3-venv

# Clone your GitHub project
git clone https://github.com/dhairyak668/gcptf.git
cd /home/gcptf

# Set up Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies

pip install --upgrade pip
pip install -r requirements.txt

# Install MySQL client
apt-get install -y default-mysql-client

# Initialize the database schema
mysql -h "${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" << 'EOSQL'
CREATE TABLE IF NOT EXISTS user (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS photo (
  PhotoID INT AUTO_INCREMENT PRIMARY KEY,
  CreationTime DATETIME NOT NULL,
  Title VARCHAR(255),
  Description TEXT,
  Tags TEXT,
  URL VARCHAR(255),
  ExifData JSON
);
EOSQL 

# Set DB environment variables BEFORE running app
export DB_USER="${DB_USER}"
export DB_PASSWORD="${DB_PASSWORD}"
export DB_NAME="${DB_NAME}"
export DB_CONNECTION_NAME="${DB_HOST}"

# Start the Flask app
export FLASK_APP=app.py
export FLASK_ENV=production
flask run --host=0.0.0.0 --port=8080