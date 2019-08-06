# Sitecorium.Docker.PublishingService
Host the Publishing Service in a Docker container!

To build the Docker image of the Sitecore Publishing Service:

1) Download the SPS service zip file and place in the assets folder 
2) Rename the zip to "Sitecore Publishing Service.zip"
3) Edit the Connection strings in the Docker-compose.yml file to a SQL Server instance the image can access. (It will install the SPS table schema in these DBs)
4) Edit the hostname in the Docker-compose.yml file to a hostname of your choice or leave the default
5) Open a command prompt
6) Type: docker-compose up --build -d. After some time the image should be built and the container will be started with the name publishingservice. 
7) Add the hostname sitecore.docker.pubsvc (or your custom host) to your hosts file
8) Ensure your "PublishingServiceUrlRoot" setting in "\App_Config\Include\Custom\Modules\PublishingService\Sitecore.Publishing.Service.config" points to the hostname in step 7
9) Try a publish! 

