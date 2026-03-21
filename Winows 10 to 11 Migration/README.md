# Windows 10 to 11 Migration
### **Overview**
In an enterprise environment, hardware lifecycles often outpace official software requirements. This project provides a professional, single-script solution to automate the Windows 11 In-Place Upgrade on workstations that do not meet standard TPM 2.0 or CPU specifications.

### **The Unified Framework**
Unlike standard deployments that require multiple files and complex staging, this suite uses a Self-Referencing Logic. The script handles global registry overrides and then "intercepts" the Windows installer to maintain compatibility throughout the entire upgrade process.

* Core Script: Win10\11_Migration.cmd

* Target Engine: Official Windows 11 setup.exe (from mounted ISO or USB)

*Design Goal: Zero-touch, single-file execution.

### **Key Features**
* Injects registry keys to bypass TPM 2.0, Secure Boot, RAM, CPU, and Storage checks before the installer launches.

* Uses Image File Execution Options (IFEO) to register itself as a readiness filter, ensuring "Dynamic Updates" don't re-trigger hardware blocks mid-install.

* Configured with /auto upgrade, /quiet, and /eula accept flags for a non-disruptive user experience.

* Includes logic to prevent the script from hanging in a background system context.

### **How to Use**
* Mount your Windows 11 ISO or prepare your deployment folder.

* Place the Win10\11_Migration.cmd in the root folder (the same folder where setup.exe is located).

* Execute the script as Administrator.

The script will handle the registry prep, register the bypass filter, and launch the silent upgrade automatically.

### **Deployment & Testing**
As this utility bypasses official hardware requirements, it must be validated on a subset of devices first.

*Use your Intune Testing Groups to verify the upgrade on various hardware models in the fleet.

### **Disclaimer**
**READ BEFORE USE**: These scripts are provided for educational and testing purposes only. I hold no responsibility for system instability, broken functionality, or data loss in your environment. Always validate in a sandbox/testing group before production use.

### **Deployment & Testing**
Before deploying these scripts to your entire fleet, it is strongly recommended to use a dedicated Testing Group to validate the results.

* For a step-by-step guide on how to set up a group, please refer to my documentation here: https://github.com/RickGua90/How_To/blob/7aa316a7a7313245b0006747091482029fab9251/Create_or_delete_a_group_in_Intune.pdf
