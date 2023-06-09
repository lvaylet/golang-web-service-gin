# Developing a RESTful API with Go and Gin

## Usage

### From Cloud Shell

Run locally with:

```sh
go get .
go run .
curl http://localhost:8080/albums
```

Build and run with:

```sh
go build .
./golang-web-service-gin
curl http://localhost:8080/albums
```

Containerize and run locally with:

```sh
docker build -t golang-web-service-gin:latest .
docker run --rm -p 8080:8080 golang-web-service-gin:latest
curl http://localhost:8080/albums
```

Containerize, push image to GCR and deploy to Cloud Run with authentication with:

```sh
PROJECT_ID=<YOUR-PROJECT-ID>
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
gcloud builds submit --tag gcr.io/${PROJECT_ID}/golang-web-service-gin:latest
gcloud run deploy golang-web-service-gin \
    --image=gcr.io/${PROJECT_ID}/golang-web-service-gin:latest \
    --no-allow-unauthenticated \
    --service-account=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com \
    --max-instances=5 \
    --region=europe-west1 \
    --project=${PROJECT_ID}
SERVICE_URL=$(gcloud run services describe golang-web-service-gin --platform managed --region europe-west1 --format 'value(status.url)')
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" ${SERVICE_URL}/albums
```

## References

- [Download and install Go](https://go.dev/doc/install)
- [Tutorial: Developing a RESTful API with Go and Gin](https://go.dev/doc/tutorial/web-service-gin)
- [How To Upgrade Golang Dependencies](https://golang.cafe/blog/how-to-upgrade-golang-dependencies.html)
- [Create the smallest and secured golang docker image based on scratch](https://chemidy.medium.com/create-the-smallest-and-secured-golang-docker-image-based-on-scratch-4752223b7324)
