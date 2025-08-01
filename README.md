# GKE CI/CD 예제

이 저장소는 Google Cloud Build, Google Cloud Deploy, Skaffold 및 Kustomize를 사용하여 Flask 애플리케이션을 Google Kubernetes Engine(GKE)에 배포하기 위한 CI/CD 파이프라인 예제를 포함합니다.

## 사용된 기술

*   **Google Kubernetes Engine (GKE)**: 컨테이너화된 애플리케이션을 배포하고 관리하기 위한 관리형 Kubernetes 서비스입니다.
*   **Google Cloud Build**: Google Cloud에서 빌드를 실행하는 서버리스 CI/CD 플랫폼입니다.
*   **Google Cloud Deploy**: GKE로의 지속적인 배포를 위한 관리형 서비스입니다.
*   **Skaffold**: Kubernetes 애플리케이션의 지속적인 개발을 용이하게 하는 명령줄 도구입니다.
*   **Kustomize**: Kubernetes 네이티브 구성 관리 도구입니다.
*   **Flask**: 경량 Python 웹 프레임워크입니다.
*   **Docker**: 컨테이너화 플랫폼입니다.

## 프로젝트 구조

이 프로젝트의 핵심은 `skaffold-sample` 디렉토리에 있습니다:

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

## 애플리케이션 (`app/`)

`app/` 디렉토리에는 간단한 Flask 애플리케이션이 포함되어 있습니다:

*   `main.py`: "Hello, World!!!"를 반환하는 기본적인 Flask 애플리케이션입니다.
*   `Dockerfile`: Flask 애플리케이션용 Docker 이미지를 빌드하는 방법을 정의합니다.
*   `requirements.txt`: Python 종속성(Flask)을 나열합니다.

## Kubernetes 구성 (`k8s/`)

이 디렉토리에는 Kustomize로 관리되는 Kubernetes 매니페스트가 있습니다:

*   `k8s/base/`: 기본 Kubernetes 배포 및 서비스 정의(`workload.yaml`)와 해당 `kustomization.yaml`을 포함합니다.
*   `k8s/overlays/`: 다양한 GKE 클러스터에 대한 환경별 오버레이를 포함합니다.
    *   `sinjoongk-gke-asia-northeast3/`: `asia-northeast3` 지역에 대한 오버레이로, 배포에 `region` 레이블을 적용합니다.
    *   `sinjoongk-gke-us-central1/`: `us-central1` 지역에 대한 오버레이로, 배포에 `region` 레이블을 적용합니다.

## CI/CD 파이프라인

이 프로젝트는 Google Cloud Build 및 Google Cloud Deploy를 CI/CD 파이프라인으로 활용합니다:

*   **`cloudbuild.yaml`**:
    *   `gcr.io/cloud-builders/docker`를 사용하여 Flask 애플리케이션의 Docker 이미지를 빌드합니다.
    *   커밋 SHA로 이미지에 태그를 지정합니다.
    *   Artifact Registry(`us-central1-docker.pkg.dev/$PROJECT_ID/k8s-skaffold/flask-sample`)로 이미지를 푸시합니다.
    *   `skaffold-sample/skaffold.yaml` 및 빌드된 이미지를 참조하여 Google Cloud Deploy에서 릴리스를 생성합니다.
*   **`clouddeploy.yaml`**:
    *   `skaffold-demo`라는 Google Cloud Deploy 전달 파이프라인을 정의합니다.
    *   `us-central1` 및 `asia-northeast3` 지역의 GKE 클러스터에 해당하는 두 가지 배포 대상(`sinjoongk-gke-us-central1` 및 `sinjoongk-gke-asia-northeast3`)을 구성합니다.
*   **`skaffold.yaml`**:
    *   애플리케이션 빌드 및 배포를 위해 Skaffold를 구성합니다.
    *   이미지 빌드를 위해 Google Cloud Build를 사용합니다.
    *   매니페스트 관리를 위해 Kustomize를 지정하고 `k8s/base`를 가리킵니다.
    *   각 Kustomize 오버레이를 적용하는 다양한 GKE 지역(`sinjoongk-gke-asia-northeast3`, `sinjoongk-gke-us-central1`)에 대한 프로필을 정의합니다.
*   **`create_release.sh`**: `gcloud deploy`를 사용하여 수동으로 릴리스를 생성하는 샘플 스크립트입니다.

## 사용 방법

1.  **Google Cloud 프로젝트 설정**: `us-central1` 및 `asia-northeast3`에 GKE 클러스터, Artifact Registry, Cloud Build 및 Cloud Deploy가 활성화된 Google Cloud 프로젝트가 구성되어 있는지 확인합니다.
2.  **`skaffold.yaml` 및 `cloudbuild.yaml` 구성**: `projectId` 및 이미지 경로를 Google Cloud 프로젝트 및 Artifact Registry 설정과 일치하도록 업데이트합니다.
3.  **빌드 및 배포**:
    *   **Cloud Build를 통한 CI/CD 트리거**: 저장소에 변경 사항을 푸시합니다. `cloudbuild.yaml`이 자동으로 트리거되어 이미지를 빌드하고 Cloud Deploy 릴리스를 생성합니다.
    *   **수동 (테스트용)**:
        *   Docker 이미지 빌드: `docker build -t us-central1-docker.pkg.dev/<YOUR_PROJECT_ID>/k8s-skaffold/flask-sample:<TAG> skaffold-sample/app`
        *   이미지 푸시: `docker push us-central1-docker.pkg.dev/<YOUR_PROJECT_ID>/k8s-skaffold/flask-sample:<TAG>`
        *   `create_release.sh` 스크립트를 사용하여 Cloud Deploy 릴리스를 생성합니다(먼저 스크립트에서 이미지 및 프로젝트 세부 정보를 업데이트).
4.  **배포 모니터링**: Google Cloud Console을 사용하여 Cloud Deploy에서 배포 진행 상황을 모니터링합니다.

이 설정은 여러 지역에 걸쳐 GKE에 애플리케이션을 배포하는 강력하고 자동화된 방법을 제공합니다.
