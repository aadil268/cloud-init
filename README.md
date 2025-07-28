# Azure Ubuntu Cloud-Init Provisioning

This repository provides a complete solution for provisioning Ubuntu virtual machines on Azure using cloud-init. It's the Linux equivalent of the Windows Cloudbase-Init solution, where cloud-init runs a sample script during VM initialization.

## Overview

This solution creates an Ubuntu VM on Azure that uses cloud-init to:
1. Install required packages
2. Download and execute a sample script
3. Set up monitoring and logging
4. Create a comprehensive system report

## Repository Structure

```
azure-ubuntu-cloudinit/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Terraform variables
├── README.md                  # This documentation
└── config/
    ├── cloud-init.yaml        # Cloud-init configuration
    └── sample-script.sh       # Sample script executed by cloud-init
```

## Prerequisites

- Azure subscription
- Terraform installed
- Azure CLI installed and configured
- Appropriate Azure permissions to create resources

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd azure-ubuntu-cloudinit
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Set your Azure subscription ID:**
   ```bash
   export TF_VAR_subscription_id="your-subscription-id"
   ```

4. **Plan the deployment:**
   ```bash
   terraform plan
   ```

5. **Deploy the infrastructure:**
   ```bash
   terraform apply
   ```

## Configuration Details

### Cloud-Init Configuration (`config/cloud-init.yaml`)

The cloud-init configuration:
- Updates package cache and upgrades packages
- Installs essential packages (curl, wget, git, htop, unzip, jq)
- Creates necessary directories
- Downloads and executes the sample script
- Provides fallback execution for offline scenarios

### Sample Script (`config/sample-script.sh`)

The sample script performs:
- System information collection
- Network configuration analysis
- Disk and memory usage reporting
- Creation of sample application files
- Setup of monitoring service
- Log rotation configuration
- Generation of provisioning report

## What Gets Created

### Azure Resources
- Resource Group
- Virtual Network and Subnet
- Network Security Group (SSH access)
- Public IP Address
- Network Interface
- Ubuntu Virtual Machine (Standard_B2s)
- Storage Account

### VM Configuration
- **OS**: Ubuntu 20.04 LTS
- **User**: azureuser
- **Authentication**: Password (P@ssword1234!)
- **SSH**: Enabled on port 22

### Application Files Created on VM
- `/opt/sample-app/app.conf` - Application configuration
- `/opt/sample-app/status.json` - System status in JSON format
- `/opt/sample-app/monitor.sh` - Monitoring script
- `/opt/sample-app/provisioning-report.txt` - Detailed provisioning report
- `/etc/systemd/system/sample-monitor.service` - Systemd monitoring service

### Log Files
- `/var/log/cloudinit-scripts/main-script.log` - Main script execution log
- `/var/log/cloud-init.log` - Cloud-init system log
- `/var/log/cloud-init-output.log` - Cloud-init output log

## Customization

### Modifying the Sample Script

To customize the sample script:
1. Edit `config/sample-script.sh`
2. Update the script URL in `config/cloud-init.yaml` if hosting externally
3. Redeploy with `terraform apply`

### Adding Packages

To install additional packages, modify the `packages` section in `config/cloud-init.yaml`:
```yaml
packages:
  - curl
  - wget
  - git
  - your-package-here
```

### Changing VM Size

Modify the `size` parameter in `main.tf`:
```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  size = "Standard_B4ms"  # Change this
  # ... other configuration
}
```

## Accessing the VM

After deployment:

1. **Get the public IP:**
   ```bash
   terraform output
   ```

2. **SSH to the VM:**
   ```bash
   ssh azureuser@<public-ip>
   ```

3. **Check cloud-init status:**
   ```bash
   sudo cloud-init status
   ```

4. **View execution logs:**
   ```bash
   sudo cat /var/log/cloudinit-scripts/main-script.log
   ```

5. **Check the provisioning report:**
   ```bash
   cat /opt/sample-app/provisioning-report.txt
   ```

## Monitoring

The solution includes a monitoring service that can be started manually:

```bash
# Start the monitoring service
sudo systemctl start sample-monitor.service

# Check service status
sudo systemctl status sample-monitor.service

# View monitoring logs
sudo journalctl -u sample-monitor.service -f
```

## Troubleshooting

### Cloud-Init Issues
```bash
# Check cloud-init status
sudo cloud-init status --long

# View cloud-init logs
sudo cat /var/log/cloud-init.log
sudo cat /var/log/cloud-init-output.log

# Re-run cloud-init (for testing)
sudo cloud-init clean --logs
sudo cloud-init init
```

### Script Execution Issues
```bash
# Check main script log
sudo cat /var/log/cloudinit-scripts/main-script.log

# Manually run the sample script
sudo /opt/cloudinit-scripts/sample-script.sh
```

### Network Issues
```bash
# Check if script download failed
curl -I https://raw.githubusercontent.com/YOUR_USERNAME/azure-ubuntu-cloudinit/main/config/sample-script.sh
```

## Security Considerations

- The VM uses password authentication for simplicity. For production, consider using SSH keys.
- The Network Security Group allows SSH from any IP. Restrict this to your IP range for better security.
- The sample script runs with root privileges. Review and modify according to your security requirements.

## Cleanup

To destroy all created resources:
```bash
terraform destroy
```

## Comparison with Windows Cloudbase-Init

| Aspect | Windows (Cloudbase-Init) | Linux (Cloud-Init) |
|--------|-------------------------|-------------------|
| Init System | Cloudbase-Init | Cloud-Init |
| Script Language | PowerShell | Bash |
| Configuration | cloudbase-init.conf | cloud-init.yaml |
| Package Manager | Chocolatey/Windows | apt/yum/dnf |
| Service Management | Windows Services | systemd |
| Remote Access | RDP (3389) | SSH (22) |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review cloud-init logs
3. Open an issue in the repository

---

**Note**: Remember to update the script URL in `config/cloud-init.yaml` to point to your actual repository after pushing to GitHub.

