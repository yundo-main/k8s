# Kubernetes 학습 및 운영 문서

이 디렉터리는 Kubernetes 설치, 학습 실습, 클러스터 확장, 운영 명령을 역할별로
분리해 관리한다.

- [Kubernetes 실습 순서](./practice-order/README.md)

## 디렉터리 구조

```text
k8s/
├── install/       # Ansible 기반 Kubernetes 설치와 단계별 SVG
├── practice-order/ # 학습 순서별 실제 실습 파일
├── addons/        # CNI·Ingress·Storage 등 컨트롤러와 확장 구성
├── operations/    # 설치 후 클러스터 운영·점검·장애 분석
└── examples/      # 실습 파일 생성을 위한 내부 기반 예제, 학습자 비노출
```

## 영역별 문서

`examples/`는 실습 파일을 만들기 위한 원본·참조용 예제다. 학습자는 직접
접근하지 않고 `practice-order/`의 실습 파일만 사용한다.

### 설치

- [Kubernetes 설치 계획](./install/plan.md)
- [Playbook 실행 순서](./install/playbooks/README.md)
- [전체 설치 단계 SVG](./install/installation-flow.svg)
- [단계별 SVG](./install/stages/)

### 실습

Kubernetes 오브젝트와 YAML은 학습 순서에 맞춰 [practice-order](./practice-order/README.md)에
배치한다. 학습자는 이 경로의 단계별 파일을 사용한다.

### 컨트롤러

컨트롤러는 오브젝트를 감시하고 선언된 상태가 실제로 유지되도록 조정한다.

- [컨트롤러 분류](./addons/README.md)
- `cni/`: Pod 네트워크와 노드 간 통신
- `ingress/`: 외부 HTTP/HTTPS 라우팅
- `storage/`: CSI Driver와 StorageClass
- `autoscaling/`: 메트릭과 자동 확장
- `operators/`: 애플리케이션 운영 자동화

### 운영

설치가 완료된 클러스터를 조회하고 상태를 점검한다.

- [운영 디렉터리](./operations/README.md)
- `cluster/`: 클러스터 전체 상태
- `nodes/`: 노드 상태와 자원
- `workloads/`: Pod와 배포 상태
- `network/`: Service, Ingress, Endpoint
- `storage/`: PV, PVC, StorageClass
- `troubleshooting/`: 이벤트, 로그, 장애 분석

## 관리 기준

```text
install/        어떻게 구성하는가 — 설치 자동화
practice-order/ 어떤 순서로 학습하는가 — 실제 실습 YAML
addons/         어떻게 확장하는가 — CNI·Ingress·Storage·Operator 구성
operations/     현재 어떤 상태인가 — 조회·점검·장애 대응
examples/       실습 파일을 만들기 위한 내부 기반 예제
```

## 기본 확인 명령

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl get events -A --sort-by=.lastTimestamp
```

`kubectl`은 Mac 관리 호스트에 설치하고, Control Plane에서 복사한 kubeconfig를
사용한다. kubeconfig에는 관리자 권한이 포함될 수 있으므로 파일 권한을 `600`으로
유지하고 저장소에 커밋하지 않는다.
