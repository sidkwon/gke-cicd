# GKE CI/CD Example

This repository contains an example of a CI/CD pipeline for deploying a Flask application to Google Kubernetes Engine (GKE) using Google Cloud Build, Google Cloud Deploy, Skaffold, and Kustomize.

## Technologies Used

*   **Google Kubernetes Engine (GKE)**: Managed Kubernetes service for deploying and managing containerized applications.
*   **Google Cloud Build**: Serverless CI/CD platform that executes your builds on Google Cloud.
*   **Google Cloud Deploy**: Managed service for continuous delivery to GKE.
*   **Skaffold**: Command-line tool that facilitates continuous development for Kubernetes applications.
*   **Kustomize**: Kubernetes native configuration management.
*   **Flask**: A lightweight Python web framework.
*   **Docker**: Containerization platform.

## Project Structure

The core of this project resides in the `skaffold-sample` directory:

```
skaffold-sample/
├── app/
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
├── cloudbuild.yaml
├── clouddeploy.yaml
├── create_release.sh
├── k8s/
│   ├── base/
│   │   ├── kustomization.yaml
│   │   └── workload.yaml
│   └── overlays/
│       ├── sinjoongk-gke-asia-northeast3/
│       │   ├── kustomization.yaml
│       │   └── workload.yaml
│       └── sinjoongk-gke-us-central1/
│           ├── kustomization.yaml
│           └── workload.yaml
└── skaffold.yaml
```

## Application (`app/`)

The `app/` directory contains a simple Flask application:

*   `main.py`: A basic Flask application that returns "Hello, World!!!".
*   `Dockerfile`: Defines how to build the Docker image for the Flask application.
*   `requirements.txt`: Lists Python dependencies (Flask).

## Kubernetes Configuration (`k8s/`)

This directory holds the Kubernetes manifests, managed with Kustomize:

*   `k8s/base/`: Contains the base Kubernetes deployment and service definitions (`workload.yaml`) and its `kustomization.yaml`.
*   `k8s/overlays/`: Contains environment-specific overlays for different GKE clusters.
    *   `sinjoongk-gke-asia-northeast3/`: Overlay for the `asia-northeast3` region, applying a `region` label to the deployment.
    *   `sinjoongk-gke-us-central1/`: Overlay for the `us-central1` region, applying a `region` label to the deployment.

## CI/CD Pipeline

This project leverages Google Cloud Build and Google Cloud Deploy for its CI/CD pipeline:

*   **`cloudbuild.yaml`**:
    *   Builds the Docker image of the Flask application using `gcr.io/cloud-builders/docker`.
    *   Tags the image with the commit SHA.
    *   Pushes the image to Artifact Registry (`us-central1-docker.pkg.dev/$PROJECT_ID/k8s-skaffold/flask-sample`).
    *   Creates a release in Google Cloud Deploy, referencing the `skaffold-sample/skaffold.yaml` and the built image.
*   **`clouddeploy.yaml`**:
    *   Defines a Google Cloud Deploy delivery pipeline named `skaffold-demo`.
    *   Configures two deployment targets: `sinjoongk-gke-us-central1` and `sinjoongk-gke-asia-northeast3`, corresponding to GKE clusters in `us-central1` and `asia-northeast3` regions respectively.
*   **`skaffold.yaml`**:
    *   Configures Skaffold for building and deploying the application.
    *   Uses Google Cloud Build for image building.
    *   Specifies Kustomize for manifest management, pointing to `k8s/base`.
    *   Defines profiles for different GKE regions (`sinjoongk-gke-asia-northeast3`, `sinjoongk-gke-us-central1`) that apply the respective Kustomize overlays.
*   **`create_release.sh`**: A sample script to manually create a release using `gcloud deploy`.

## How to Use

1.  **Set up your Google Cloud Project**: Ensure you have a Google Cloud project configured with GKE clusters in `us-central1` and `asia-northeast3`, Artifact Registry, Cloud Build, and Cloud Deploy enabled.
2.  **Configure `skaffold.yaml` and `cloudbuild.yaml`**: Update `projectId` and image paths to match your Google Cloud project and Artifact Registry setup.
3.  **Build and Deploy**:
    *   **Via Cloud Build (CI/CD Trigger)**: Push changes to your repository. `cloudbuild.yaml` will automatically trigger, build the image, and create a Cloud Deploy release.
    *   **Manually (for testing)**:
        *   Build the Docker image: `docker build -t us-central1-docker.pkg.dev/<YOUR_PROJECT_ID>/k8s-skaffold/flask-sample:<TAG> skaffold-sample/app`
        *   Push the image: `docker push us-central1-docker.pkg.dev/<YOUR_PROJECT_ID>/k8s-skaffold/flask-sample:<TAG>`
        *   Create a Cloud Deploy release using the `create_release.sh` script (update image and project details in the script first).
4.  **Monitor Deployment**: Use the Google Cloud Console to monitor the deployment progress in Cloud Deploy.

This setup provides a robust and automated way to deploy your applications to GKE across multiple regions.
