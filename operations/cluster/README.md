# 클러스터 운영

클러스터 전체 상태, Kubernetes 버전, API Server와 시스템 Pod 상태를 확인한다.

예정 명령:

```bash
kubectl cluster-info
kubectl version
kubectl get --raw='/readyz?verbose'
kubectl get pods -A
```
