Docker Build:
docker build --platform linux/amd64 --tag docker-github-runner .

Docker Run:
docker run -e GH_TOKEN='PAT' -e GH_OWNER='nihalm97' -e GH_REPOSITORY='terraform' -d docker-github-runner:latest