

# GCP-Based Photo Gallery App with Terraform

##  Overview

This project is a cloud-deployed photo gallery web application using Flask, MySQL, and Google Cloud Platform (GCP). Terraform is used for full Infrastructure-as-Code (IaC) provisioning. The application allows user registration, login, image uploads, and storage of photo metadata.

##  Project Components

- **Terraform (app-deploy.tf)** – provisions VM, firewall rules, Cloud SQL instance
- **GCP VM Instance** – runs the Flask app
- **Cloud SQL (MySQL)** – stores user and photo data
- **Startup Script (startup.sh)** – automates app setup and launch
- **Flask App (app.py)** – user interface and backend logic
- **Media Uploads** – stored in `/opt/app/media` on the VM

>  Note: `main.tf` is the main Terraform configuration file (not using name (previous) `app-deploy.tf`).
>  Note: `startup.sh` is the shell script and not `cloud-init`

---

##  How to Set Up the Project

### 1. Clone the Repository

```bash
git clone https://github.com/dhairyak668/gcptf.git
```

### 2. Initialize Terraform

```bash
cd terraform
terraform init
```

### 3. Configure Project Variables

Edit `terraform.tfvars`:

```hcl
project_id  = "your-gcp-project-id"
region      = "us-central1"
zone        = "us-central1-a"
db_password = "your-secure-password"
```

### 4. Apply Infrastructure

```bash
terraform apply
```

Terraform provisions:
- A VM instance with your Flask app running on port 8080
- A Cloud SQL instance for MySQL
- Required networking and firewall rules

Once applied, visit:

```bash
http://<vm_ip>:8080
```

Use the Terraform output or GCP Console to get your VM's external IP.

---

##  Testing Functionality

- Register a new user via `/create-user`
- Log in through the homepage
- Upload a photo via `/add`
- View the gallery on `/home`

All uploads are stored locally in `/opt/app/media` on the VM.

---

##  How to Tear Down the Project

If you wish to destroy all deployed resources:

1. Ensure deletion protection is off in `app-deploy.tf`:
   ```hcl
   deletion_protection = false
   ```

2. Then run:

```bash
terraform destroy
```

---

##  File Summary

| File              | Purpose |
|-------------------|---------|
| `app-deploy.tf`   | Main Terraform config for VM + app deployment |
| `variables.tf`    | Input variables |
| `terraform.tfvars`| Your project-specific values |
| `outputs.tf`      | Outputs VM IP and DB info |
| `startup.sh`      | Bootstraps the app, installs deps, creates DB |
| `app.py`          | Flask app code |
| `requirements.txt`| Python dependencies |

---

##  Dependencies

```text
flask
boto3
pymysql
exifread
requests
gunicorn
```

Install them automatically via `startup.sh`.

---

##  Deployment Automation Features

- Infrastructure-as-Code via Terraform
- Application deployment handled by `startup.sh`
- Automatic app start on VM boot
- DB schema initialized automatically
- Logs available in `/var/log/startup.log` and `flask.log`

---

