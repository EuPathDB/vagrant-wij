# vagrant-wij

----

This Vagrant project combines WDK-based webserver with iRODS and Jenkins
services. It is intended as a production-like environment for EBRC
Workspace development.

The base image is the EBRC webdev vagrant box which has been
pre-provisioned as a EBRC web server. This Vagrant project adds
provisioning for iRODS and Jenkins services. The provisioning requires
network access to EBRC resources located behind a firewall. Therefore
you will need to be on a trusted network for the provisioning phase.

The `ebrc/webdev` base box is a 6 GB download. The additional
provisioning of iRODS and Jenkins is another 500MB of downloads. I
recommend you do your first provisioning while on a fast network. The
`ebrc/webdev` box is the same one used for the
[vagrant-webdev](https://github.com/mheiges/vagrant-webdev) project so
if you have been using that then the box should already be cached on
your host and not need to be downloaded again.

Prerequisites
=====

The host computer needs the following.

Vagrant
---------------

Vagrant manages the lifecycle of the virtual machine, following by the instructions in the `Vagrantfile` that is included with this project.

[https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html)

You should refer to Vagrant documentation and related online forums for information not covered in this document.

VirtualBox
------------------

Vagrant needs VirtualBox to host the virtual machine defined in this project's `Vagrantfile`. Other virtualization software (e.g. VMWare) are not compatible with this Vagrant project as it is currently configured.

[https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)

You should refer to VirtualBox documentation and related online forums for information not covered in this document.

Vagrant Librarian Puppet Plugin
--------------------------------------

This plugin downloads the Puppet module dependencies. Install the plugin with the command

    vagrant plugin install vagrant-librarian-puppet

Vagrant Landrush Plugin (Optional)
--------------------------------------

The [Landrush](https://github.com/phinze/landrush) plugin for Vagrant
provides a local DNS where guest hostnames are registered. This permits,
for example, the `rs1` guest to contact the iCAT enabled server by its
`wij.vm` hostname - a requirement for iRODS installation and function.
This plugin is not strictly required but it makes life easier than
editing `/etc/hosts` files. This plugin has maximum benefit for OS X
hosts, some benefit for Linux hosts and no benefit for Windows. Windows
hosts will need to edit the `hosts` file.

EBRC uses a custom fork of Landrush. In an OS X terminal, run the
following.

    git clone https://github.com/mheiges/landrush.git
    cd landrush
    rake build
    vagrant plugin install pkg/landrush-0.18.0.gem

_If you have trouble getting the host to resolve guest hostnames through landrush try clearing the host DNS cache by running_

`sudo killall -HUP mDNSResponder`.

You should refer to Landrush and Vagrant documentation and related online forums for information not covered in this document.

Usage
=======

    git clone git@github.com:EuPathDB/vagrant-wij.git

    cd vagrant-wij

    vagrant up

Shell access to the guest VM

    vagrant ssh

The `/vagrant` directory on the guest is mounted from the hosts's
Vagrant project directory so its contents persist across recreation of
the guest VM. The `scratch` directory is excluded from git so is a good
place to place persistent, non-versioned data.

Web Hosting
=======

The virtual machine has the standard set of Tomcat instances, Apache web
server and infrastructure required for WDK-based websites and associated
development.

iRODS Basics
=======

host
--------

The iCAT enable server is **`wij.vm`**, the irods server port is `1247`.


zone
--------

The zone is **ebrc**.

accounts
--------

Listed as `username/password`

  - `icatadmin/passWORD` : full administrator of the irods zone, i.e.
  can run all the `iadmin` commands.
  - `wrkspuser/passWORD` : iRODS account for workspaces development.
  This has read/write rights to `/ebrc/workspaces`.
  - `irods` : (no password) The operating system account that runs the irods
  processes. This system account is preconfigured with `icatadmin`
  credentials and that should not be changed. You can `sudo su - irods`
  to access this system account and then issue iCommands as the irods
  administrator.
  - `irods/passWORD` : The admin account for the `ICAT` Postgres
  database. You typically should not need to tinker in the database, but
  if you must, you can get in with

          PGPASSWORD=passWORD psql -U irods -h localhost ICAT

**_Note: iRODS on this virtual machine is not configured for LDAP authentication._**

resources
---------

The default resource is **`ebrcResc`**

Example `iinit`
-------------

Putting together the above, here's an example `iinit` to log in as the `wrkspuser`.

    [vagrant@wij ~]$ iinit
    One or more fields in your iRODS environment file (irods_environment.json) are
    missing; please enter them.
    Enter the host name (DNS) of the server to connect to: wij.vm
    Enter the port number: 1247
    Enter your irods user name: wrkspuser
    Enter your irods zone: ebrc
    Those values will be added to your environment file (for use by
    other iCommands) if the login succeeds.

    Enter your current iRODS password: passWORD

Service Managment
---------

The iRODS service is managed with the systemctl command.

    sudo systemctl [start|stop|restart|status] irods

Jenkins
=======

Initial Setup
---------

The first time accessing the Jenkins website you will be prompted to
setup a new admin account and install plugins. Follow the prompts. If
you get the error
"_An error occurred during installation: No such plugin: cloudbees-folder_"
when attempting plugin installation, try restarting the Jenkins service
and then start again with the website setup wizard.

I recommend that you "Install suggested plugins". You can install other
desired plugins later.

Web Address
---------

  [http://wij.vm:9171/](http://wij.vm:9171/)

Service Managment
---------

The jenkins service is managed with the `systemctl` command.

    sudo systemctl [start|stop|restart|status] jenkins@WS

Jenkins Layout
---------

`JENKINS_HOME`, where master and job configurations are stored, is
`/usr/local/home/jenkins/Instances/WS`.

Logging is at `/var/log/jenkins/WS.log`


Example Node Setup
---------

You can run jobs on the master but you may want to run jobs on a node as
a specific user. In production we typically use nodes running in the
`joeuser` account. You can simulate that environment here if you wish;
the advantage is that you can be assured that the `joeuser` account is
capable to run your jobs.

In this simulation, the node is on the same virtual machine as the
master but is configured with an ssh connections using the `joeuser`
account as it would be for remote production nodes.

You will need the `SSH Slaves plugin` installed; this will be installed
if you chose to installed the suggested plugins at setup, otherwise
install it manually.

Use Jenkins' web interface to add a node configuration.

*UI Navigation Guidance for Add Node.*

        Manage Jenkins
          Manage Nodes
            New Nodes
              Name: webdev <or your choice>
              Type: Permanent Agent
              OK
              
                Name: webdev <or your choice>
                # of executors 1 <or your choice>
                Remote root directory /var/tmp <or your choice>
                Labels: <blank>
                Launch method: Launch slave agents on Unix machines via SSH
                Host: localhost
                Credentials: joeuser <see next Guidance below for adding joeuser>
                <remaining options can be left empty for now>

Once saved, it will take several seconds for the node to be setup. You
can view the node log for details.

*Guidance for Add Credentials.*

          Domain: Global credentials
          Kind: SSH Username with private key
          Scope: System
          Username: joeuser
          Private Key: From the Jenkins master ~/.ssh
          Passphrase: <blank>
          Id: <blank>
          Description: <your choice>

