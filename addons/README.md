# Kubernetes 컨트롤러

Addon과 운영 영역의 관계는 [Addon과 Operations 이론 페이지](../theory/addons-operations.md)에서
먼저 확인한다.

컨트롤러는 Kubernetes 오브젝트를 감시하고 선언된 원하는 상태가 실제 상태가
되도록 조정하는 구성 요소다.

```text
k8s/addons/
├── cni/
├── ingress/
├── storage/
├── autoscaling/
└── operators/
```

## 관리 기준

- `practice-order/`: `Deployment`, `Service` 등 원하는 상태를 선언하는 YAML
- `addons/`: 선언된 상태를 실제로 유지하거나 클러스터 기능을 확장하는 구성
- `install/`: 노드와 Kubernetes 기본 구성 설치
- `operations/`: 설치 후 상태 확인과 운영 명령

Kubernetes 기본 컨트롤러(`Deployment Controller`, `Node Controller` 등)는
Control Plane 내부에서 실행되므로 이 디렉터리에 별도 설치 YAML을 두지 않는다.
