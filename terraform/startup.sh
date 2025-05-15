# #!/bin/bash

# # Update system packages
# apt-get update

# # Install required system packages
# apt-get install -y git python3-pip python3-venv

# # Clone your GitHub project
# git clone https://github.com/dhairyak668/gcptf.git
# cd /home/gcptf

# # Set up Python virtual environment
# python3 -m venv venv
# source venv/bin/activate

# # Install Python dependencies

# pip install --upgrade pip
# pip install -r requirements.txt

# # Install MySQL client
# apt-get install -y default-mysql-client

# # Initialize the database schema
# mysql -h "${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" << 'EOSQL'
# CREATE TABLE IF NOT EXISTS user (
#   id INT AUTO_INCREMENT PRIMARY KEY,
#   username VARCHAR(255) UNIQUE NOT NULL,
#   password VARCHAR(255) NOT NULL
# );

# CREATE TABLE IF NOT EXISTS photo (
#   PhotoID INT AUTO_INCREMENT PRIMARY KEY,
#   CreationTime DATETIME NOT NULL,
#   Title VARCHAR(255),
#   Description TEXT,
#   Tags TEXT,
#   URL VARCHAR(255),
#   ExifData JSON
# );
# EOSQL 

# # Set DB environment variables BEFORE running app
# export DB_USER="${DB_USER}"
# export DB_PASSWORD="${DB_PASSWORD}"
# export DB_NAME="${DB_NAME}"
# export DB_CONNECTION_NAME="${DB_HOST}"

# # Start the Flask app
# export FLASK_APP=app.py
# export FLASK_ENV=production
# flask run --host=0.0.0.0 --port=8080


#!/bin/bash

# Redirect all output to a log file
exec > >(tee /var/log/startup.log | logger -t startup-script -s 2>/dev/console) 2>&1

# Update system packages
apt-get update

# Install required packages
apt-get install -y git python3-pip python3-venv default-mysql-client

# Create a clean app directory
mkdir -p /opt/app
cd /opt/app

# Clone the Flask app
if [ -d .git ]; then
  echo "Pulling latest changes from GitHub..."
  git pull origin main
else
  echo "Cloning repo for the first time..."
  git clone https://github.com/dhairyak668/gcptf.git .
fi

if [ ! -f requirements.txt ]; then
  echo " ERROR: Failed to clone repo or requirements.txt missing."
  exit 1
fi

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Export DB environment variables
export DB_HOST=$(curl -s -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/attributes/DB_HOST)
export DB_USER=$(curl -s -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/attributes/DB_USER)
export DB_PASSWORD=$(curl -s -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/attributes/DB_PASSWORD)
export DB_NAME=$(curl -s -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/attributes/DB_NAME)

echo "DB_HOST=$DB_HOST"
echo "DB_USER=$DB_USER"
echo "DB_PASSWORD=$DB_PASSWORD"
echo "DB_NAME=$DB_NAME"


# Initialize DB schema
mysql --protocol=TCP -h "$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" << 'EOSQL'
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

# Ensure media folder exists with proper permissions
if [ ! -d /opt/app/media ]; then
    mkdir /opt/app/media
fi
chmod 777 /opt/app/media


# Start the app using nohup so it survives startup
export FLASK_APP=app.py
export FLASK_ENV=production
nohup flask run --host=0.0.0.0 --port=8080 > flask.log 2>&1 &
deactivate