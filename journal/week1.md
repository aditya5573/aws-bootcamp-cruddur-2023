# Week 1 — App Containerization

## **Security on Container**

This week the team will be talking about docker containers and the best practice.
I will write the 10 best practices that you need to know.


### **What is container Security?**
Container Security is the practice of protecting your application hosted on compute service like  containers.

### **Why container is popular?**
It is a angnostic way to run application.
Most people started developing apps on container due to the simplicity to pass the package without considering requirements.


**Managed Vs Unmanaged Container**

Managed Containers means that the Provider (AWS) managed the underlying service for the container (ECS or EKS). In this case Cloud provider will be managing the security prospective .

Unmanaged Containers means you are running your container on your servers and you have to manage all the system (for example you will be in charged to apply security patches).

(Please refer to the Share responsability diagram on the journal Week0.md).




### **Docker Components**
![Docker Component](https://docs.docker.com/engine/images/architecture.svg)

- Client is basically is installed your docker locally (build, pull, run features)
- Server is the location where is running the container

Registry is a location of the images available on internet (an exampple is docker hub). you could have a private registry inside of your organisation.

#### **Security Best Practice**
- Keep Host & Docker Updated to latest security patches.
- Docker Deamon & containers should run in non root user mode
- Image Vulnerability Scanning
- Trust a Private vs Public Image Registry
- No Sensitive Data in Docker Files or Images
- Use Secret Management Services to share secrets.
- Read only file system and volume for dockers
- Separate databases for long term storage
- Use DevSecOps pratices while building application security
- Ensure all code is tested for vulnerabilities before production use


#### **Docker Compose** 
It is a tool for defining and running multi container Docker Applications (It uses yml file).

### Tool to indefity vulnerability on your Docker Compose
Snyk OpenSource Security

### Tools to Store and Manage Secrets
- Aws Secret Manager
- Hashicorp Vault

### Tools to scan Image Vulnerability
- AWS Inspector
- Clair
- Snyk COntainer Security

### Running Containers in AWS
Problem with docker compose and Docker Containers: If you need to change, you need to stop the machine update the file and restart.

For the Managed Containers you can use the following AWS service
- AWS ECS
- AWS EKS
- AWS Fargate

Reason to run containers on the cloud
- Integration with AWS Services
- Using automation to provision containers at sale with speed and security



## Pricing Consideration for CDE

### Gitpod
- Up To 50 Hours of Usage/Month
- Standard: 4 Cores, 8GB Ram and 30GB Storage
- Avoid spinning multiple enviroment at the time as it consume your 50Hours free tier quicker.

To check the remain credit, click to your Icon > billing
 
 ### Github Codespaces
 2 flavours:
 - Up to 60 Hours of usage with 2 core 4GB RAM and 15GB of Storage
- Up to 30 Hours of usage with 4 core 8GB RAM and 15GB of Storage

### AWS Cloud9
- Covered under free tier if you use the T2.micro instance'
- Avoid using Cloud9 in case of free tier instance in use for other purpose.



## Docker

## Containerize Backend

### Run Python

```sh
cd backend-flask
export FRONTEND_URL="*"
export BACKEND_URL="*"
python3 -m flask run --host=0.0.0.0 --port=4567
cd ..
```

- make sure to unlock the port on the port tab
- open the link for 4567 in your browser
- append to the url to `/api/activities/home`
- you should get back json



### Add Dockerfile

Create a file here: `backend-flask/Dockerfile`

```dockerfile
FROM python:3.10-slim-buster
WORKDIR /backend-flask
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY . .
ENV FLASK_ENV=development
EXPOSE ${PORT}
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
```

### Build Container

```sh
docker build -t  backend-flask ./backend-flask
```
![Screenshot 1b](https://user-images.githubusercontent.com/81632787/221946397-1c101ff0-ee6b-4436-9484-5b96d36a3353.png)

### Run Container

Run 
```sh
docker run --rm -p 4567:4567 -it backend-flask
FRONTEND_URL="*" BACKEND_URL="*" docker run --rm -p 4567:4567 -it backend-flask
export FRONTEND_URL="*"
export BACKEND_URL="*"
docker run --rm -p 4567:4567 -it -e FRONTEND_URL='*' -e BACKEND_URL='*' backend-flask
docker run --rm -p 4567:4567 -it  -e FRONTEND_URL -e BACKEND_URL backend-flask
unset FRONTEND_URL="*"
unset BACKEND_URL="*"
```
![Screenshot 1f](https://user-images.githubusercontent.com/81632787/221946956-84077605-8749-42f9-930f-d2c4b93a257d.png)
Run in background

```sh
docker container run --rm -p 4567:4567 -d backend-flask
```

Return the container id into an Env Vat
```sh
CONTAINER_ID=$(docker run --rm -p 4567:4567 -d backend-flask)
```

> docker container run is idiomatic, docker run is legacy syntax but is commonly used.
### Get Container Images or Running Container Ids

```
docker ps
docker images
```
![Screenshot 1g](https://user-images.githubusercontent.com/81632787/221947080-3e9b1fbe-ffd1-47f8-8d8b-793134fdf90a.png)

### Send Curl to Test Server

```sh
curl -X GET http://localhost:4567/api/activities/home -H "Accept: application/json" -H "Content-Type: application/json"
```

### Check Container Logs

```sh
docker logs CONTAINER_ID -f
docker logs backend-flask -f
docker logs $CONTAINER_ID -f
```

###  Debugging  adjacent containers with other containers

```sh
docker run --rm -it curlimages/curl "-X GET http://localhost:4567/api/activities/home -H \"Accept: application/json\" -H \"Content-Type: application/json\""
```

busybosy is often used for debugging since it install a bunch of thing

```sh
docker run --rm -it busybosy
```

### Gain Access to a Container

```sh
docker exec CONTAINER_ID -it /bin/bash
```

> You can just right click a container and see logs in VSCode with Docker extension
### Delete an Image

```sh
docker image rm backend-flask --force
```

> docker rmi backend-flask is the legacy syntax, you might see this is old docker tutorials and articles.
> There are some cases where you need to use the --force
### Overriding Ports

```sh
FLASK_ENV=production PORT=8080 docker run -p 4567:4567 -it backend-flask
```

> Look at Dockerfile to see how ${PORT} is interpolated
## Containerize Frontend

## Run NPM Install

We have to run NPM Install before building the container since it needs to copy the contents of node_modules

```
cd frontend-react-js
npm i
```

### Create Docker File

Create a file here: `frontend-react-js/Dockerfile`

```dockerfile
FROM node:16.18
ENV PORT=3000
COPY . /frontend-react-js
WORKDIR /frontend-react-js
RUN npm install
EXPOSE ${PORT}
CMD ["npm", "start"]
```

### Build Container

```sh
docker build -t frontend-react-js ./frontend-react-js
```

### Run Container

```sh
docker run -p 3000:3000 -d frontend-react-js
```

## Multiple Containers

### Create a docker-compose file

Create `docker-compose.yml` at the root of your project.

```yaml
version: "3.8"
services:
  backend-flask:
    environment:
      FRONTEND_URL: "https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./backend-flask
    ports:
      - "4567:4567"
    volumes:
      - ./backend-flask:/backend-flask
  frontend-react-js:
    environment:
      REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./frontend-react-js
    ports:
      - "3000:3000"
    volumes:
      - ./frontend-react-js:/frontend-react-js
# the name flag is a hack to change the default prepend folder
# name when outputting the image names
networks: 
  internal-network:
    driver: bridge
    name: cruddur
```
![Screenshot 1k](https://user-images.githubusercontent.com/81632787/221953030-0038bb58-0685-40a2-9f3c-191d4cbcd1bb.png)

## Containerize Application (Dockerfiles, Docker Compose)
Created both containers
- Backend 
- Frontend

Worked on running the both contaienrs on Local environment 

Run the both Containers locally using Gitpod. 

Finally got the Containers running together using docker-copose.yml` 
Proof of the Backend Container running 
## Verificaton Image
![Screenshot 1i](https://user-images.githubusercontent.com/81632787/221941839-a94688ed-341b-4f17-b2d7-9c711b9b5249.png)
![Screenshot 1k](https://user-images.githubusercontent.com/81632787/221941875-40a78320-a198-4547-b1c6-4a57095b41dd.png)
![Screenshot 1l](https://user-images.githubusercontent.com/81632787/221955950-418258c7-d212-4a91-a80b-1a1d0fedecf2.png)

## Write a Flask Backend Endpoint for Notifications 
## Verificaton Image
![Screenshot 1p](https://user-images.githubusercontent.com/81632787/221958668-030a6ca6-3f98-4e9d-890a-259438df685e.png)

![Screenshot 1q](https://user-images.githubusercontent.com/81632787/221958834-a575e4b5-d9df-4eb4-89a4-823e7ab8160e.png)

<hr>
## Write a React Page for Notifications
Finished bare minimum to start for Week 2 :) 
## Verificaton Image

![Screenshot 1o](https://user-images.githubusercontent.com/81632787/221959022-7f7c7e2e-3bfe-4fb4-893e-0b76468c8e5a.png)

<hr>

## Run DynamoDB Local Container and ensure it works
## Verificaton Image

![Screenshot 1s](https://user-images.githubusercontent.com/81632787/221962005-11bb2b6a-bb2d-4612-96f6-e7124715ad99.png)

## Adding DynamoDB Local and Postgres

We are going to use Postgres and DynamoDB local in future labs
We can bring them in as containers and reference them externally

Lets integrate the following into our existing docker compose file:

### Postgres

```yaml
services:
  db:
    image: postgres:13-alpine
    restart: always
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - '5432:5432'
    volumes: 
      - db:/var/lib/postgresql/data
volumes:
  db:
    driver: local
```

To install the postgres client into Gitpod

```sh
  - name: postgres
    init: |
      curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
      echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
      sudo apt update
      sudo apt install -y postgresql-client-13 libpq-dev
```

### DynamoDB Local

```yaml
services:
  dynamodb-local:
    # https://stackoverflow.com/questions/67533058/persist-local-dynamodb-data-in-volumes-lack-permission-unable-to-open-databa
    # We needed to add user:root to get this working.
    user: root
    command: "-jar DynamoDBLocal.jar -sharedDb -dbPath ./data"
    image: "amazon/dynamodb-local:latest"
    container_name: dynamodb-local
    ports:
      - "8000:8000"
    volumes:
      - "./docker/dynamodb:/home/dynamodblocal/data"
    working_dir: /home/dynamodblocal
```

Example of using DynamoDB local
https://github.com/100DaysOfCloud/challenge-dynamodb-local

## Volumes

directory volume mapping

```yaml
volumes: 
- "./docker/dynamodb:/home/dynamodblocal/data"
```

named volume mapping

```yaml
volumes: 
  - db:/var/lib/postgresql/data
volumes:
  db:
    driver: local
```
![Screenshot 1r aws not create dynamodb (2)](https://user-images.githubusercontent.com/81632787/221962896-260232ae-1e44-435e-8893-66bb9be70522.png)
![Screenshot connect to database server](https://user-images.githubusercontent.com/81632787/221962964-23d18933-03b7-4c59-8bc5-95e877fad582.png)

