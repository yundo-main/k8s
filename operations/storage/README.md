# 스토리지 운영

PersistentVolume, PersistentVolumeClaim, StorageClass의 바인딩과 상태를
확인한다.

![스토리지 운영 점검 흐름](./storage-operations.svg)

예정 명령:

```bash
kubectl get pv
kubectl get pvc -A
kubectl get storageclass
```
