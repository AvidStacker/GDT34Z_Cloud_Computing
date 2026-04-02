# Lab 2 – Oracle Cloud Infrastructure (OCI)

**Course:** Cloud Computing / Network Security / System Administration (GDT34Z)  
**Platform:** Oracle Cloud Infrastructure (OCI)  
**Operating System:** Ubuntu Linux (ARM64)

---

# Introduction
This lab demonstrates how to deploy and manage cloud infrastructure in Oracle Cloud Infrastructure (OCI).  
The tasks include Infrastructure as Code (Terraform), block storage configuration, object storage with IAM access, logging, and monitoring.

---

# 2.2.1 Infrastructure as Code (Terraform)

A compute instance was automatically provisioned using Terraform.  
This fulfills the requirement of deploying infrastructure using Infrastructure as Code.

![Compute instance](Screenshots/oci_instance_overview.png)

The instance was successfully created and is running in OCI.  
This demonstrates automated provisioning instead of manual configuration.

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

The results show how OCI provides a secure and scalable cloud environment with integrated logging, monitoring, and access control.

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
