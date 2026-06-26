# Hosting Tableau Server on GCP VM

To host Tableau Server on a Linux VM in GCP, `you should choose a Long-Term Support (LTS) version of Ubuntu.`

While Tableau Server supports several Linux distributions (including RHEL, Rocky Linux, and AlmaLinux), `Ubuntu 22.04 LTS or 24.04 LTS` are the standard choice for most cloud deployments due to their extensive documentation, ease of use in the GCP ecosystem, and wide community support.

---

## Why Ubuntu LTS is the Best Choice for Tableau

* `Official Certification:` Tableau explicitly tests and supports `Ubuntu LTS releases (20.04, 22.04, and 24.04)`.

* `Ease of Management:` Most tutorials, troubleshooting guides, and infrastructure-as-code (Terraform/Ansible) scripts for Tableau on GCP are written for Ubuntu.

* `GCP Integration:` GCP provides excellent pre-configured images for Ubuntu that are optimized for performance within their cloud environment.

### Critical Considerations for Your VM

#### 1. Hardware Requirements (Non-Negotiable)

Tableau Server is extremely resource-intensive. Do not attempt to run it on "Micro" or "Small" instances.

* `CPU:` Ensure your VM has at least 8 physical cores (16 vCPUs) for production.
* `RAM:` A minimum of 64 GB of RAM is required for the initial node.
* `Storage:` Use high-performance Persistent Disks (SSD). Tableau is disk-I/O heavy. Ensure you have at least 500 GB, though you should size this based on the number of data extracts you plan to host.

#### 2. Avoid "Minimal" Images

While you want a clean system, avoid "Cloud Minimal" or "Core" versions of Ubuntu if you are new to Linux administration. Use the `standard Ubuntu LTS image` provided by Google. This ensures all the standard library dependencies (like `gdebi`, which Tableau requires for `.deb` package installation) are easily accessible through standard package repositories.

#### 3. Hostname and Network Configuration

* `Static Internal/External IP:` Assign a static internal IP to the VM. Tableau Server binds its services to the hostname and IP address during initialization.

* `DNS:` Ensure your VM has a fixed, resolvable hostname (FQDN). `Do not change the hostname after initializing Tableau.` If the hostname changes, the Tableau Services Manager (TSM) will break, and you will likely have to reinstall the server.

### Summary Checklist for your GCP Setup

1. `Image:` Ubuntu 22.04 LTS or 24.04 LTS (x86_64).

2. `Machine Type:` N2 or N2D series (balanced vCPU/Memory).

3. `Disk:` SSD Persistent Disk (minimum 500GB recommended).

4. `Network:` Open ports 80, 443, and 8850 (for TSM administration).

5. `Static IP:` Assign a static internal IP and ensure the hostname is properly configured.

6. `Non-preemptible:` Use a non-preemptible VM to ensure stability for your Tableau Server.

7. `OS Updates:` Regularly update the OS and apply security patches, but avoid major version upgrades that could break Tableau.

```json
{
  "tableau_server_gcp_deployment": {
    "image": "Ubuntu 22.04 LTS or 24.04 LTS (x86_64)",
    "machine_type": "N2 or N2D series (balanced vCPU/Memory)",
    "storage": {
      "type": "SSD Persistent Disk",
      "recommended_minimum_size": "500GB"
    },
    "network": {
      "open_ports": [80, 443, 8850],
      "configuration": "Assign a static internal IP and ensure the hostname is properly configured"
    },
    "instance_settings": {
      "type": "Non-preemptible VM"
    },
    "maintenance_strategy": {
      "os_updates": "Regularly apply security patches; avoid major version upgrades that could affect Tableau stability"
    }
  }
}

```
