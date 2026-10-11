# Kubernetes 운영

Addon과 Operations의 구분과 연결은 [Addon과 Operations 이론 페이지](./addons-operations.md)에서
먼저 확인한다.

설치가 완료된 클러스터를 조회·점검·문제 해결하는 운영 명령을 관리한다.

```text
k8s/operations/
├── cluster/          # 클러스터 전체 상태와 기본 정보
├── nodes/            # 노드 상태·자원·이벤트
├── workloads/        # Pod·Deployment·Job 상태
├── network/          # Service·Ingress·Endpoint 통신
├── storage/          # PV·PVC·StorageClass 상태
├── addons/           # 설치된 Addon 확인과 운영 참고
└── troubleshooting/  # 장애 분석과 이벤트 확인
```

`practice-order/`는 선언할 리소스 YAML을, `operations/`는 이미 설치된 클러스터와
Addon을 점검하는 명령과 참고 자료를 관리한다.
