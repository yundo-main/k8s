# 장애 분석

노드·Pod·네트워크 장애의 원인을 이벤트, 상태, 로그 순서로 확인한다.

```bash
kubectl get events -A --sort-by=.lastTimestamp
kubectl describe <resource> <name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```
