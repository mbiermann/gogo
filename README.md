# Chef cookbook for provisioning the Rocket API

Target platform: Ubuntu 

Deployment
==========

The deployment of the Rocket API is optimized for Chef Solo. The default deployment's provisioning installs the Rocket API server and a DataDog agent to capture, aggreate and push metrics about the host machine and the Rocket API server to the DataDog web services for performance and error monitoring.

The following workflow installs the Rocket API on a new host machine:

1. Install git using `sudo apt-get install git`.
2. Run `cd /opt; sudo git clone https://github.com/mbiermann/rocket-api.git` to download the Rocket API sources.
3. Run `sudo chmod +x rocket-api/deployment/provision.sh` to enable provision script execution.
4. Run `./provision.sh` to start provisioning.
