**********************************************************************
Guide to the Tesora DBaaS Platform Plugin version 1.9-1.9.5-1 for Fuel
**********************************************************************

This document provides instructions for installing, configuring and using
the **Tesora DBaaS Platform plugin for Fuel**.

Tesora DBaas Platform
=====================

The Tesora DBaaS Platform Fuel plugin provides an automated method
to deploy Tesora DBaaS components within Fuel. The plugin extends the Fuel
Web UI to provide necessary configuration information fields.

Deploying Tesora DBaaS Platform into your Fuel environment will provide
additional nodes to run the Tesora services (API, taskmanager and conductor).

Additionally, once installed Horizon will be extended with additional
screens for managing Tesora DBaaS databases.

License
-------

============================================  ==================
Component                                     License type
============================================  ==================
Tesora DBaaS Platform Enterprise Edition 1.9  Commercial
============================================  ==================


Requirements
------------

===============================  ===============
Requirement                      Version/Comment
===============================  ===============
Fuel                             9.0
===============================  ===============

Pre-requisites
--------------

* This guide assumes that you have installed Fuel and all the nodes of your
  future environment are discovered and functional.

* Use of the Tesora DBaaS Fuel plugin requires that you have previously
  registered for a trial of `Tesora DBaaS Enterprise Edition
  <http://resources.tesora.com/download-free-trial-tesora-dbaas-platform-enterprise-edition>`_.

Limitations
-----------

This plugin currently supports only Ubuntu Fuel environments.


Installation Guide
==================

Tesora DBaaS Platform plugin installation
-----------------------------------------

To install the Tesora DBaaS Platform Fuel plugin, follow these steps:

#. Download the plugin from the `Fuel Plugins Catalog <https://www.mirantis.com/products/openstack-drivers-and-plugins/fuel-plugins/>`_.

#. Copy the plugin to an already installed
   `Fuel Master node <http://docs.openstack.org/developer/fuel-docs/userdocs/fuel-install-guide/install_install_fuel.html>`_::

   # scp fuel-plugin-tesora-dbaas-1.9-1.9.5-1.noarch.rpm root@:/\<fuel master node IP>:/tmp

#. Log into the Fuel Master node.

#. Install the plugin::

     # cd /tmp
     # fuel plugins --install fuel-plugin-tesora-dbaas-1.9-1.9.5-1.noarch.rpm

#. Check if the plugin was installed successfully::

     # fuel plugins
     id | name                     | version | package_version
     ---|--------------------------|---------|----------------
     1  | fuel-plugin-tesora-dbaas | 1.9.5   | 4.0.0

#. Create a new Fuel environment using the Fuel UI Wizard.

#. Within the environment you just created, open the Settings tab of the Fuel Web UI
   and select `Other` from the left-hand panel.
   Enable the Tesora DBaaS plugin, and enter values in the username and password fields:

   .. Note::
      You should have received a username and password from Tesora via email
      when you registered for your trial of Tesora DBaaS Enterprise Edition.
      You can register for a 60 day trial
      `here <http://resources.tesora.com/download-free-trial-tesora-dbaas-platform-enterprise-edition>`_.

   You will also need to accept the `Tesora, Inc. Terms of Use` by entering `I AGREE` in the terms of use field.

   .. image:: figures/enable-plugin.png

#. Select nodes for Tesora DBaaS Platform.
   The plugin is designed to install the Tesora DBaaS Platform into a separate node:

   .. image:: figures/add-node.png

#. Perform network validation on your new fuel environment.

#. Deploy your Fuel environment containing the Tesora DBaaS Platform.
   Once provisioned launch Horizon. You should see additional screens in Horizon for Database:

   .. image:: figures/horizon-tesora.png


User Guide
==========

Tesora DBaaS Platform requires the user to download and install a
`datastore guest image` prior to launching any databases.
Tesora provides guest images for different types and versions of databases - see the full `list <http://www.tesora.com/openstack-trove-certified-databases/>`_.

How to Install a datastore guest image
--------------------------------------

To install a datastore for say `mysql 5.6`, follow these steps:

#. Log in to the fuel node running the Tesora DBaaS Controller.

#. Change directory.
   ::

     # cd /opt/tesora/dbaas/bin

#. Source the `openrc.sh` file located in this directory.
   ::

     # source openrc.sh

#. Run `add-datastore.sh` to download and install the datastore guest image you want.
   ::

     # ./add-datastore.sh mysql 5.6
     
     Add datastore mysql 5.6 to Tesora DBaaS
     
     Selecting guest based on platform, command line args and environment variables:
         Platform OS              ubuntu
         Guest OS                 ubuntu
         Tesora DBaaS Release     enterprise
         Tesora DBaaS Version     1.9
         Tesora DBaaS Repository  main
     
     Checking connectivity to Glance service
     
     Guest name determined as 'tesora-ubuntu-trusty-mysql-5.6-EE-1.9'
     
     
     Downloading guest 'tesora-ubuntu-trusty-mysql-5.6-EE-1.9.guest'
     --2016-11-01 15:10:07--  ftp://enterprise19:*password*@ftp.tesora.com/main/ubuntu/tesora-ubuntu-trusty-mysql-5.6-EE-1.9.guest
                => ‘/tmp/tmp.PwTR8Ov3Cs’
     Resolving ftp.tesora.com (ftp.tesora.com)... 199.182.122.232
     Connecting to ftp.tesora.com (ftp.tesora.com)|199.182.122.232|:21... connected.
     Logging in as enterprise19 ... Logged in!
     ==> SYST ... done.    ==> PWD ... done.
     ==> TYPE I ... done.  ==> CWD (1) /main/ubuntu ... done.
     ==> SIZE tesora-ubuntu-trusty-mysql-5.6-EE-1.9.guest ... 502609920
     ==> PASV ... done.    ==> RETR tesora-ubuntu-trusty-mysql-5.6-EE-1.9.guest ... done.
     Length: 502609920 (479M) (unauthoritative)
     
     100%[======================================>] 502,609,920 16.9MB/s   in 27s    
     
     2016-11-01 15:10:34 (17.7 MB/s) - ‘/tmp/tmp.PwTR8Ov3Cs’ saved [502609920]
     
     
     Moving guest '/tmp/tmp.PwTR8Ov3Cs' into guest cache
     
     Uploading guest 'tesora-ubuntu-trusty-mysql-5.6-EE-1.9-75' to Glance
     [=============================>] 100%
     +------------------------------+------------------------------------------+
     | Property                     | Value                                    |
     +------------------------------+------------------------------------------+
     | checksum                     | b03598ecd8b0840c7794acae95b85471         |
     | container_format             | bare                                     |
     | created_at                   | 2016-11-01T15:10:31Z                     |
     | disk_format                  | qcow2                                    |
     | id                           | 68ceb1df-f65e-4806-a4a4-0df38445f479     |
     | min_disk                     | 0                                        |
     | min_ram                      | 0                                        |
     | name                         | tesora-ubuntu-trusty-mysql-5.6-EE-1.9-75 |
     | owner                        | 1274ced4337a4700a7b27a156c0a318b         |
     | protected                    | False                                    |
     | size                         | 502530048                                |
     | status                       | active                                   |
     | tags                         | []                                       |
     | tesora-agent-build           | 137                                      |
     | tesora-agent-full-version    | 1.9.5                                    |
     | tesora-agent-version         | 1.9                                      |
     | tesora-database              | mysql                                    |
     | tesora-database-version      | 5.6                                      |
     | tesora-database-version_long | 5.6.33                                   |
     | tesora-edition               | enterprise                               |
     | tesora-edition-short         | EE                                       |
     | tesora-guest-image-build     | 75                                       |
     | tesora-os-distro             | ubuntu                                   |
     | tesora-os-distro-version     | trusty                                   |
     | tesora-repository            | main                                     |
     | updated_at                   | 2016-11-01T15:11:18Z                     |
     | virtual_size                 | None                                     |
     | visibility                   | public                                   |
     +------------------------------+------------------------------------------+
     
     Guest 'tesora-ubuntu-trusty-mysql-5.6-EE-1.9-75 uploaded to Glance with ID '68ceb1df-f65e-4806-a4a4-0df38445f479'
     
     Creating datastore 'mysql'
     Datastore 'mysql' updated.
     
     Adding datastore version '5.6-75' to datastore 'mysql' with manager 'mysql'
     Datastore version '5.6-75' updated.
     
     Making '5.6-75' the default version for datastore 'mysql'
     Datastore 'mysql' updated.
     
     Loading validation rule file '/usr/lib/python2.7/dist-packages/trove/templates/mysql/validation-rules.json'.
     Loading config parameters for datastore (mysql) version (5.6-75)
     
     Add datastore complete...
     
     Guest image for 'mysql' '5.6' uploaded to glance as: tesora-ubuntu-trusty-mysql-5.6-EE-1.9-75
     Datastore 'mysql' created with version '5.6-75'

.. Note::
   If the download fails with a `Login incorrect` error then most likely the username or password entered in the setting screen were incorrect.
   After deployment the username and password are stored in openrc.sh and can be edited there.

How to view available datastores
--------------------------------

To view the installed and available datastores in horizon, follow these steps:

#. Login to the Horizon console.

#. Navigate to Project -> Database -> Datastores.

#. The table shows the installed and available datastores.

   .. image:: figures/horizon-datastores.png

How to create a database instance
---------------------------------

To create a database instance based off an available datastore, follow these steps:

#. Login to the Horizon console.

#. Navigate to Project -> Database -> Instances.

#. Select the `Launch Instance` button.

#. In the Launch Instance dialog enter Instance Name, Volume Size, Datastore and Flavor.

   .. image:: figures/horizon-launch1.png

#. In the `Networking` section, ensure you launch your instance on a valid network.

   .. image:: figures/horizon-launch2.png

#. It may take a few minutes for your database to launch. When complete you should see:

   .. image:: figures/trove-instances.png

Troubleshooting
---------------

If add-datastore.sh fails with a `Login incorrect` error then most likely the username or password entered in the setting screen were incorrect.

If trove instance fails to start, a common cause is using too small a flavor.  A flavor with at least 768M of RAM is required for mysql database.

Known issues
------------

Database Backup&Restore may not work with Ceph enabled object storage.
Database Backup&Restore may not work with self-signed TLS certificate, or with 'public.fuel.local' set for DNS hostname for public TLS endpoints.

Appendix
--------

+----+----------------------------+-------------------------------------------------------------------------------------------------------------------------+
| #  | Title of resource          | Link on resource                                                                                                        |
+====+============================+=========================================================================================================================+
| 1  | Tesora Download Free Trial | `Link <http://resources.tesora.com/download-free-trial-tesora-dbaas-platform-enterprise-edition/>`_                     |
+----+----------------------------+-------------------------------------------------------------------------------------------------------------------------+
| 2  | Tesora Certified Databases | `Link <http://www.tesora.com/openstack-trove-certified-databases/>`_                                                    |
+----+----------------------------+-------------------------------------------------------------------------------------------------------------------------+
| 3  | Tesora Inc.                | `Link <http://www.tesora.com/>`_                                                                                        |
+----+----------------------------+-------------------------------------------------------------------------------------------------------------------------+
| 4  | Mirantis                   | `Link <http://www.mirantis.com/>`_                                                                                      |
+----+----------------------------+-------------------------------------------------------------------------------------------------------------------------+
