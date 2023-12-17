gcloud deploy releases create test-release-001 \
  --project=dm-project-391900 \
  --region=us-central1 \
  --delivery-pipeline=skaffold-demo \
  --images=my-app-image=gcr.io/google-containers/nginx@sha256:f49a843c290594dcf4d193535d1f4ba8af7d56cea2cf79d1e9554f077f1e7aaa