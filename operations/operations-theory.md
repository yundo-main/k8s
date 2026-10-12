# Kubernetes Operations 이론

문서 이동: [Operations 홈](./README.md) · [구조·리소스](./00-resources/README.md) · [운영 순서](./01-cluster/README.md)

![Kubernetes Operations 운영 범위](./operations-hierarchy.svg)

Operations는 설치된 Kubernetes 클러스터와 리소스의 상태를 관찰하고 관리하는
운영 영역이다. 클러스터·노드·워크로드·네트워크·스토리지 점검이 기본 흐름이며,
확장 구성요소는 필요할 때 이 흐름에 추가한다.

하위 디렉터리별 책임과 연결은 [Operations 하위 디렉터리 관계도](./operations-hierarchy.svg)에서
확인한다.

Kubernetes 클러스터를 이해할 때는 애플리케이션 리소스와 클러스터 운영
구성요소를 구분해야 한다. Operations는 선언된 리소스와 실제 상태의 차이를
확인하고 조치하는 활동이다.

## Operations의 기본 범위

| 영역 | 주요 관심사 |
| --- | --- |
| 클러스터 | Control Plane과 시스템 구성요소 상태 |
| 노드 | Ready 상태, 자원, 압박 상태, Taint |
| 워크로드 | Pod, Deployment, StatefulSet, Job의 상태 |
| 네트워크 | Service, Endpoint, Ingress, NetworkPolicy |
| 스토리지 | PV, PVC, StorageClass와 데이터 연결 |
| 장애 대응 | 이벤트, 로그, 원인 분석과 복구 |

## 선택 확장 구성요소

확장 구성요소는 기본 Kubernetes 기능을 보완하거나 특정 기능을 추가할 때
선택적으로 설치하는 클러스터 구성요소다. 보통 여러 Pod, Service, 권한, 설정으로
구성되며 클러스터 전체 또는 여러 Namespace에 영향을 줄 수 있다.

대표적인 확장 구성요소는 다음과 같다.

| 영역 | 예시 | 개념적 역할 |
| --- | --- | --- |
| 네트워크 | CNI·Calico | Pod 네트워크와 정책 제공 |
| 외부 연결 | Ingress Controller | 외부 요청을 Service로 전달 |
| 스토리지 | CSI·NFS | 저장소를 Kubernetes 리소스로 연결 |
| 메트릭 | Metrics Server | 리소스 사용량을 제공 |
| 자동화 | Operator | 특정 애플리케이션 운영을 자동화 |

이러한 구성요소는 Kubernetes의 기본 오브젝트라기보다, Kubernetes 위에서 동작하며 기능을
제공하는 확장 구성요소로 이해하는 것이 적절하다.

## 확장 구성요소와 Operations의 관계

확장 구성요소는 기능을 제공하고, Operations는 기본 운영 흐름 안에서 해당
기능의 상태를 확인하고 문제를 처리한다.

```text
필요한 확장 구성요소 설치·구성
      ↓
클러스터 기능 제공
      ↓
Operations 상태 관찰
      ↓
문제 분석·복구·변경 관리
```

예를 들어 Ingress Controller는 확장 구성요소이고, Controller Pod·Service·Ingress
라우팅 상태를 확인하는 것은 Operations다. NFS CSI는 저장소 확장 구성요소이고, PV·PVC가
정상적으로 연결되었는지 확인하는 것은 Storage Operations다.

## 애플리케이션 리소스와의 구분

`Deployment`, `Service`, `ConfigMap` 같은 리소스는 애플리케이션의 원하는 상태를
선언한다. 확장 구성요소는 이 선언을 실행할 수 있도록 클러스터 기능을 제공하고,
Operations는 선언된 상태와 실제 상태의 차이를 관리한다.

```text
애플리케이션 리소스
  원하는 상태 선언
        ↓
확장 구성요소
  네트워크·스토리지·외부 연결 기능 제공
        ↓
Operations
  실제 상태 확인·문제 해결·변경 관리
```

## 핵심 정리

- Operations는 클러스터·노드·워크로드·네트워크·스토리지를 점검하는 기본 운영 영역이다.
- 확장 구성요소는 필요한 기능을 추가할 때 선택적으로 설치한다.
- 확장 구성요소의 상태도 Operations의 기본 점검 흐름으로 확인한다.
- 확장 구성요소 설치는 `install/`, 운영 자료는 `operations/07-addons/`로 분리한다.

상세 운영 자료는 [operations](./README.md)에서 확인하고, 확장 구성요소가 필요할
때 [운영 자료](./07-addons/README.md)를 참고한다.
