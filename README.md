fuel-plugin-tesora-dbaas
========================

This plugin installs Tesora DBaaS Platform within a Fuel 8.0 environment.
Tesora Database as a Service (DBaaS) platform is an enterprise-hardened version of OpenStack Trove, the native database service for OpenStack. 
This platform supports 13 popular databases.

Features
--------

Installs Trove services onto specified "DBaaS Controller" node(s)
Provides RabbitMQ cluster for Trove's use
Stores state in controller's mysql cluster
Provides highly available Trove services when using 3 or more DBaaS nodes
Provides Tesora DBaaS Horizon dashboard plugin that allows management of databases with a web browser. 

Building the plugin
-------------------

Building of this plugin is done by Tesora Inc.
Tesora adds proprietary Trove packages into the plugin's repositories, and explicitly adds Tesora's horizon plugin.

Current limitations
-------------------

Only Ubuntu Fuel environment is currently supported.
