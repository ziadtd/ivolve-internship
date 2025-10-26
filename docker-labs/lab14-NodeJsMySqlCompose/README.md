Lab 14: Containerized Node.js and MySQL Stack Using Docker Compose
This lab demonstrates how to containerize a Node.js application with MySQL database using Docker Compose, including health checks, logging, and publishing to DockerHub.
Prerequisites

Docker and Docker Compose installed
Git
DockerHub account

Project Structure
.
├── docker-compose.yml
├── Dockerfile
├── README.md
└── app/
    ├── server.js
    ├── package.json
    └── logs/
Setup Instructions
1. Clone the Application
bashgit clone https://github.com/Ibrahim-Adel15/kubernets-app.git
cd kubernets-app
2. Create Dockerfile
Create a Dockerfile in the project root:
dockerfileFROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Create logs directory
RUN mkdir -p /app/logs

# Expose application port
EXPOSE 3000

# Start the application
CMD ["node", "server.js"]
3. Create Docker Compose File
Create a docker-compose.yml file:
yamlversion: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: nodejs-app
    ports:
      - "3000:3000"
    environment:
      - DB_HOST=db
      - DB_USER=root
      - DB_PASSWORD=rootpassword
      - DB_NAME=ivolve
    volumes:
      - ./app/logs:/app/logs
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    networks:
      - app-network

  db:
    image: mysql:8.0
    container_name: mysql-db
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=ivolve
    volumes:
      - db_data:/var/lib/mysql
    ports:
      - "3306:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-prootpassword"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    networks:
      - app-network

volumes:
  db_data:
    driver: local

networks:
  app-network:
    driver: bridge
4. Build and Run the Stack
bash# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Check running containers
docker-compose ps
Verification Steps
1. Verify Application is Working
bash# Check if containers are running
docker-compose ps

# Should show both 'app' and 'db' services as 'Up'
2. Verify Health Endpoint
bash# Test health endpoint
curl http://localhost:3000/health

# Expected output: {"status":"healthy"}
3. Verify Ready Endpoint
bash# Test ready endpoint
curl http://localhost:3000/ready

# Expected output: {"status":"ready","database":"connected"}
4. Verify Application Logs
bash# Check logs directory
ls -la ./app/logs/

# View application logs
cat ./app/logs/app.log

# Or tail logs in real-time
tail -f ./app/logs/app.log
5. Test Database Connection
bash# Execute SQL query inside MySQL container
docker exec -it mysql-db mysql -uroot -prootpassword -e "SHOW DATABASES;"

# Verify 'ivolve' database exists
docker exec -it mysql-db mysql -uroot -prootpassword -e "USE ivolve; SHOW TABLES;"
Push Docker Image to DockerHub
1. Login to DockerHub
bashdocker login
# Enter your DockerHub username and password
2. Tag the Image
bash# Tag your image (replace 'yourusername' with your DockerHub username)
docker tag kubernets-app_app:latest yourusername/nodejs-mysql-app:latest
docker tag kubernets-app_app:latest yourusername/nodejs-mysql-app:v1.0
3. Push to DockerHub
bash# Push the images
docker push yourusername/nodejs-mysql-app:latest
docker push yourusername/nodejs-mysql-app:v1.0
4. Verify on DockerHub
Visit https://hub.docker.com/r/yourusername/nodejs-mysql-app to verify your image is published.
Using the Published Image
To use the published image instead of building locally, update docker-compose.yml:
yamlservices:
  app:
    image: yourusername/nodejs-mysql-app:latest
    # Remove 'build' section
    container_name: nodejs-app
    # ... rest of the configuration
Then run:
bashdocker-compose pull
docker-compose up -d
Useful Commands
bash# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Rebuild services
docker-compose up -d --build

# View logs for specific service
docker-compose logs app
docker-compose logs db

# Execute commands in running container
docker exec -it nodejs-app sh
docker exec -it mysql-db bash

# Check resource usage
docker stats

# Inspect volumes
docker volume ls
docker volume inspect kubernets-app_db_data
Troubleshooting
Application won't start
bash# Check logs
docker-compose logs app

# Common issues:
# - Database not ready: Wait for MySQL healthcheck to pass
# - Port already in use: Change port mapping in docker-compose.yml
# - Missing dependencies: Rebuild with --no-cache
docker-compose build --no-cache
Database connection failed
bash# Verify database is healthy
docker-compose ps

# Check MySQL logs
docker-compose logs db

# Test connection manually
docker exec -it mysql-db mysql -uroot -prootpassword -e "SELECT 1;"
Logs not appearing
bash# Ensure logs directory exists and has correct permissions
mkdir -p ./app/logs
chmod 777 ./app/logs

# Restart the application
docker-compose restart app
Environment Variables
VariableDescriptionDefaultDB_HOSTMySQL hostnamedbDB_USERDatabase userrootDB_PASSWORDDatabase passwordrootpasswordDB_NAMEDatabase nameivolveMYSQL_ROOT_PASSWORDMySQL root passwordrootpasswordMYSQL_DATABASEInitial database to createivolve
Security Notes
⚠️ Important: The passwords in this lab are for demonstration purposes only. In production:

Use strong, unique passwords
Store secrets in environment files (.env) and add to .gitignore
Use Docker secrets or external secret management
Never commit passwords to version control

Create a .env file:
bashDB_PASSWORD=your_secure_password
MYSQL_ROOT_PASSWORD=your_secure_password
Update docker-compose.yml to use environment file:
yamlservices:
  app:
    env_file:
      - .env
Cleanup
bash# Stop and remove all containers, networks, and volumes
docker-compose down -v

# Remove images
docker rmi kubernets-app_app:latest
docker rmi yourusername/nodejs-mysql-app:latest

# Clean up unused Docker resources
docker system prune -a
```

## Architecture Diagram
```
┌─────────────────────────────────────────┐
│           Docker Compose Stack          │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐    ┌──────────────┐  │
│  │   Node.js    │    │    MySQL     │  │
│  │     App      │───▶│      DB      │  │
│  │  (Port 3000) │    │  (Port 3306) │  │
│  └──────────────┘    └──────────────┘  │
│         │                    │          │
│         │                    │          │
│    ┌────▼────┐         ┌────▼────┐     │
│    │  Logs   │         │ db_data │     │
│    │ Volume  │         │ Volume  │     │
│    └─────────┘         └─────────┘     │
│                                         │
└─────────────────────────────────────────┘
Additional Resources

Docker Compose Documentation
Node.js Docker Best Practices
MySQL Docker Hub

License
MIT License
Author
iVolve Training Lab - Infrastructure Management

Last Updated: October 2025
