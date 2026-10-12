# 네트워크 운영

Service, Ingress, Endpoint와 Pod 간 통신 상태를 확인한다.

![네트워크 운영 점검 흐름](./network-operations.svg)

## Service 확인

```bash
kubectl get services -A
```

모든 Namespace의 Service, ClusterIP, 포트와 연결 selector를 확인한다.

## Ingress 확인

```bash
kubectl get ingress -A
```

Namespace별 Ingress 규칙과 외부 라우팅 대상을 확인한다.

## Endpoint 확인

```bash
kubectl get endpoints -A
```

Service selector에 의해 실제로 선택된 Pod IP와 포트를 확인한다.
