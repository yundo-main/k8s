# 워크로드 운영

Pod, Deployment, StatefulSet, DaemonSet, Job, CronJob의 배포 상태와 로그를
확인한다.

![워크로드 운영 점검 흐름](./workload-operations.svg)

예정 명령:

```bash
kubectl get pods -A
kubectl get deployments -A
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```
