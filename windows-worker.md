Instructions for setting up a Windows Concourse worker for building vSphere stemcells.

## Host machine requirements
	1. Windows Server 2012R2 or Windows Server 2016
	1. If running in a VM VT-x pass-through must be enabled
	1. At least 200GB of disk space (more is better)

## Software Requirements
	1. [VMware Workstation 12.5 Pro](http://store.vmware.com/store/vmware/home)
		- A free trial is [available](http://www.vmware.com/se/products/workstation/workstation-evaluation.html), but will expire in 30 days
	1. [Golang (latest)](https://golang.org/dl/)
	1. [Ruby 2.3.X](https://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.3.3-x64.exe)

	1. [tar.exe](https://greenhouse.ci.cf-app.com/teams/main/pipelines/tar/resources/s3-bucket)
	1. [Packer](https://github.com/greenhouse-org/packer/releases/tag/stemcell-builder-1.0.0): Download the Windows binary from the linked release.
	1. [concourse_windows_amd64.exe](http://concourse.ci/downloads.html)
	1. [WinSW v2.x.x](https://github.com/kohsuke/winsw): [Download](http://repo.jenkins-ci.org/releases/com/sun/winsw/winsw/2.1.0/)

## Installation (installers)
	1. VMware Workstation: use defaults, you can select the "Enhanced Keyboard Driver" if desired.
		- If VT-x (Intel hardware virtualization) pass-through is not enabled you may get an error during the install or when trying to run Workstation.
	1. Golang: use defaults
	1. Ruby: in the Installation Destination and Optional Tasks section (immediately after license agreement) select: "Add Ruby executables to your PATH" and "Associate .rb and .rbw files with Ruby installation".

## Install path things RENAME!
	1. Create a C:\bin directory and add it to the System PATH:
	```
	New-Item -ItemType directory -Path C:\bin -Force
	[Environment]::SetEnvironmentVariable("Path", "$env:PATH;C:\bin", [System.EnvironmentVariableTarget]::Machine)
	```
	1. Copy the downloaded tar executable to C:\bin\tar.exe - you may have to rename the downloaded file.
	1. Extract the downloaded packer zip and copy packer.exe to C:\bin
	1.

## Install Concourse Worker
	1. Create the following directories: C:\containers, C:\concourse, C:\vmx-data
	2. Move WinSW.NET4.exe to C:\concourse\concourse.exe
	3. Save below configuration as C:\concourse\concourse.xml
	4. Save tsa-public-key.pub and tsa-worker-private-key to C:\concourse directory
	5. Install concourse service using WinSW `concourse.exe install`

```xml
<service>
  <id>concourse</id>
  <name>Concourse</name>
  <description>Concourse Windows worker.</description>
  <startmode>Automatic</startmode>
  <executable>C:\concourse\concourse_windows_amd64.exe</executable>
  <arguments>worker /work-dir C:\containers /tsa-worker-private-key C:\concourse\tsa-worker-private-key /tsa-public-key C:\concourse\tsa-public-key.pub /tsa-host "main.bosh-ci.cf-app.com" /tag "vsphere-windows-worker"
  </arguments>
  <onfailure action="restart" delay="10 sec"/>
  <onfailure action="restart" delay="20 sec"/>
  <logmode>rotate</logmode>
</service>
```

## Registering worker

	If the worker cannot connect to TSA make sure it's IP is allowed through the firewall.
