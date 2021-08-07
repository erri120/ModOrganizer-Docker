docker build -t erri120/modorganizer-base:latest --isolation=hyperv . -f .\Dockerfile.Base
docker build -t erri120/modorganizer-dev:latest --isolation=hyperv . -f .\Dockerfile.Dev