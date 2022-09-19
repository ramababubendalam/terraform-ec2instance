# terraform-ec2instance
Create amazon-linux-2 ec2 instance using terraform and deploy minikube kubernetes cluster using docker as containerd

# Pre-requests
1.Create ssh pem key from aws console(region which you want to create ec2 instance) and download the key to your local mahine where terraform commands are run.
2.Install terraform >= 0.13.1.
3.Configure aws key secret.

# configuration variables
1.Under main.tf update  key_name to your ssh key name created in pre-requests step.
2.Under main.tf update ssh_key_file_location to your key location which is downloaded under pre-requests step.
3.Under main.tf/locals update region to the your desired region to create ec2-instance. If this is not change instance will be created in ireland region.

# Running terraform scripts
1. terraform init
2. terraform plan
3. terraform apply


# Post scripts
1. Login to the public ip of the host created using ssh key and run the following command

kubectl port-forward --address 0.0.0.0 svc/echo-service 8000:80

Api can be opened on

curl --request GET --url http://<public-ip-address-ec2-instance>:8000/healthcheck \
  --header 'Content-Type: application/json'

curl --request POST --url http://<public-ip-address-ec2-instance>:8000/echo \
  --header 'Content-Type: application/json' \
  --data '{
	"message": "welcome to k8s"
}'


# Config Files available under configFiles folder
1. Dockerfile to create excutable software
2. docker-compose.yml to build image
3. deployment.yml file to create pod/deployment on cluster
4. service.yml file to create loadbalancer service to expose service to external world