# Kubernetes Operations 이론

![Operations와 Addon 하위 영역](./addons/addon-operations-boundary.svg)

Operations는 설치된 Kubernetes 클러스터와 그 하위 구성요소를 관찰하고
관리하는 상위 운영 영역이다. Addon은 클러스터 기능을 확장하면서 Operations가
관리하고 검증하는 하위 영역으로 분류한다.

하위 디렉터리별 책임과 연결은 [Operations 하위 디렉터리 관계도](./operations-hierarchy.svg)에서
확인한다.

Kubernetes 클러스터를 이해할 때는 애플리케이션 리소스와 클러스터 운영
구성요소를 구분해야 한다. Addon은 클러스터의 기능을 확장하고, Operations는
그 클러스터와 구성요소의 상태를 관리하는 활동이다.

## Operations의 하위 영역: Addon

Addon은 Operations가 관리하는 구성요소 중 Kubernetes 기본 기능을 보완하거나 특정 기능을 추가하는 클러스터
구성요소다. 보통 여러 Pod, Service, 권한, 설정으로 구성되며 클러스터 전체 또는
여러 Namespace에 영향을 준다.

대표적인 Addon은 다음과 같다.

| 영역 | 예시 | 개념적 역할 |
| --- | --- | --- |
| 네트워크 | CNI·Calico | Pod 네트워크와 정책 제공 |
| 외부 연결 | Ingress Controller | 외부 요청을 Service로 전달 |
| 스토리지 | CSI·NFS | 저장소를 Kubernetes 리소스로 연결 |
| 메트릭 | Metrics Server | 리소스 사용량을 제공 |
| 자동화 | Operator | 특정 애플리케이션 운영을 자동화 |

Addon은 Kubernetes의 기본 오브젝트라기보다, Kubernetes 위에서 동작하며 기능을
제공하는 확장 구성요소로 이해하는 것이 적절하다.

## Operations의 범위

Operations는 설치된 클러스터가 의도한 상태를 유지하도록 관찰하고 관리하는
활동이다. 특정 리소스 하나를 생성하는 작업보다 클러스터 상태, 성능, 네트워크,
스토리지, 장애와 변경 이력을 종합적으로 다룬다.

Operations의 주요 영역은 다음과 같다.

| 영역 | 주요 관심사 |
| --- | --- |
| 클러스터 | Control Plane과 시스템 구성요소 상태 |
| 노드 | Ready 상태, 자원, 압박 상태 |
| 워크로드 | Pod, Deployment, Job의 desired state와 실제 상태 |
| 네트워크 | Service, Endpoint, Ingress, NetworkPolicy |
| 스토리지 | PV, PVC, StorageClass와 데이터 연결 |
| 장애 대응 | 이벤트, 로그, 원인 분석과 복구 |

## Addon과 Operations의 관계

Addon은 기능을 제공하고, Operations는 그 기능이 정상적으로 동작하는지
확인하고 문제를 처리한다.

```text
Addon 설치·구성
      ↓
클러스터 기능 제공
      ↓
Operations 상태 관찰
      ↓
문제 분석·복구·변경 관리
```

예를 들어 Ingress Controller는 Addon이고, Controller Pod·Service·Ingress
라우팅 상태를 확인하는 것은 Operations다. NFS CSI는 저장소 Addon이고, PV·PVC가
정상적으로 연결되었는지 확인하는 것은 Storage Operations다.

## 애플리케이션 리소스와의 구분

`Deployment`, `Service`, `ConfigMap` 같은 리소스는 애플리케이션의 원하는 상태를
선언한다. Addon은 이 선언을 실행할 수 있도록 클러스터 기능을 제공하고,
Operations는 선언된 상태와 실제 상태의 차이를 관리한다.

```text
애플리케이션 리소스
  원하는 상태 선언
        ↓
Addon
  네트워크·스토리지·외부 연결 기능 제공
        ↓
Operations
  실제 상태 확인·문제 해결·변경 관리
```

## 핵심 정리

- Operations는 클러스터 운영을 담당하는 상위 영역이다.
- Addon은 Operations에서 관리하는 클러스터 확장 구성요소다.
- Addon은 기능을 제공하고, Operations는 그 기능의 상태를 관리한다.
- Addon 설치는 `install/`, Addon 운영 자료는 `operations/addons/`로 분리한다.

상세 자료는 [운영 Addon 자료](./addons/README.md)와
[operations](./README.md)에서 확인한다.
