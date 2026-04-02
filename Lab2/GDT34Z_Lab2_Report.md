# Lab 2 – Oracle Cloud Infrastructure (OCI)

**Course:** Cloud Computing / Network Security / System Administration (GDT34Z)  
**Platform:** Oracle Cloud Infrastructure (OCI)  
**Operating System:** Ubuntu Linux (ARM64)

---

# Introduction
This lab demonstrates how to deploy and manage cloud infrastructure in Oracle Cloud Infrastructure (OCI).  
The tasks include Infrastructure as Code (Terraform), block storage configuration, object storage with IAM access, logging, and monitoring.

---

## 2.2.1 Infrastructure as Code (Terraform)

A Terraform-based environment was configured to enable automated provisioning of cloud infrastructure in Oracle Cloud Infrastructure (OCI). This setup included installation of necessary tools, configuration of authentication via the OCI CLI, and defining infrastructure using Infrastructure as Code (IaC).

Terraform was used to declaratively define and deploy resources in OCI. Authentication was handled through the OCI CLI configuration, which allowed secure access without hardcoding sensitive credentials in the Terraform configuration files.

To ensure flexibility and reusability, variables were used for key parameters such as compartment ID, availability domain, network ranges, instance shape, and SSH key. This makes it possible to reuse the same configuration across different environments by modifying variable values instead of changing the core code.

The infrastructure definition included both networking components and a compute instance. A Virtual Cloud Network (VCN), subnet, Internet Gateway, and route table were provisioned to enable external connectivity. Security rules allowed SSH access, and the compute instance was assigned a public IP address.

The compute instance was configured with an SSH public key for secure access and deployed using an Ubuntu 22.04 image. It was successfully created in the **eu-stockholm-1** region using the **VM.Standard.E2.1.Micro** shape.

Terraform was initialized, validated, and deployed using the following standard workflow:

- `terraform init`
- `terraform plan`
- `terraform apply`

This process ensured that all resources were created automatically and consistently, demonstrating the benefits of Infrastructure as Code such as reproducibility, version control, and reduced manual configuration.

![OCI Compute Instance](./images/oci-instance.png)

As shown in the figure, the instance is in a running state and has been assigned a public IP address, making it accessible via SSH. This confirms that the Terraform deployment was successful and that the infrastructure was provisioned entirely through code.

---

# 2.3 Block Storage Configuration

A block storage volume was attached to the compute instance and mounted to `/mnt/block`.

Commands used:
sudo mkdir /mnt/block
sudo mount /dev/sdb /mnt/block


Disk usage verification:
df -h


![Block volume mounted](Screenshots/df_output.png)

Block device layout:
lsblk


![lsblk output](Screenshots/lsblk_output.png)

---

## Persistent Mount

To ensure the volume persists after reboot, `/etc/fstab` was configured using UUID.

cat /etc/fstab


![fstab configuration](Screenshots/fstab_configuration.png)

This confirms correct persistent mounting.

---

# 2.4.1 Object Storage and Manual Access

## Bucket Creation

An Object Storage bucket named `lab2-bucket` was created.

![Object storage bucket](Screenshots/object_storage_bucket.png)

Objects were uploaded successfully.

![Object bucket reachability test](Screenshots/bucket_reachability_test.png)

---

## IAM User and Policy Configuration

A new user with limited privileges was created for accessing object storage.

Steps performed:

- Created a new user in OCI
- Generated **Customer Secret Keys**
- Created a group and added the user
- Created a policy:

Allow group <group-name> to manage all-resources in compartment <compartment-name>


---

## Public Bucket Access

A public object was uploaded and accessed via a browser URL.

![Public bucket access](Screenshots/public_bucket_access.png)

This confirms that public access works.

---

## Private Bucket Access

Access to a private bucket was tested using S3-compatible tools.

![Private bucket access](Screenshots/private_bucket_access.png)

This confirms secure access using credentials.

---

# 2.7.1 Cloud Logging (VCN Flow Logs)

VCN Flow Logs were enabled to capture network traffic within the subnet.

![Flow log configuration](Screenshots/flow_logs_dashboard.png)

Logs show network activity such as:

- Source IP  
- Destination IP  
- Allowed traffic  

![Flow log events](Screenshots/logs_event_chart.png)

This demonstrates successful logging of network traffic.

---

# 2.8.1 Monitoring, Alarms and Notifications

## Alarm Configuration

An OCI Monitoring alarm was created with:

- Metric: `CpuUtilization`
- Threshold: `> 80%`
- Interval: `1 minute`
- Severity: `Critical`

![CPU alarm configuration](Screenshots/cpu_alarm_configuration.png)

---

## Alarm Trigger Test

CPU load was generated:
stress --cpu 2 --timeout 300


![Stress command execution](Screenshots/stress_command.png)

---

## Alarm Notification

The alarm was triggered successfully and an email notification was received.

![Alarm email notification](Screenshots/alarm_email.png)

This confirms that monitoring and notifications are functioning correctly.

---

# Conclusion

This lab demonstrated the deployment and management of cloud resources in Oracle Cloud Infrastructure.  
Key components such as compute instances, block storage, object storage, vault secrets, logging, and monitoring alarms were successfully configured and tested.

The following key tasks were completed:

- Infrastructure provisioning using Terraform (2.2.1)
- Block storage configuration (2.3)
- Object storage with IAM-based access (2.4.1)
- Network logging using VCN Flow Logs (2.7.1)
- Monitoring and alerting (2.8.1)

The lab highlights how OCI provides secure, scalable, and manageable infrastructure for cloud-based applications.
