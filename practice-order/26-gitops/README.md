# 26. GitOps 확장

CI는 이미지와 manifest를 검증하고, CD 또는 GitOps Controller가 클러스터
상태를 동기화하도록 확장한다.

권장 흐름:

```text
소스 변경 → CI 검증 → 이미지 Push → 배포 저장소의 이미지 태그 변경
→ GitOps Controller 동기화 → Rollout 확인
```

- [Kustomize 배포 정의](./kustomization.yaml)

이 단계에서는 기존 `10-3tier`, `11-ingress` manifest를 배포 저장소로 분리할
수 있다. Argo CD나 Flux를 도입할 때도 Secret과 kubeconfig는 저장소에
커밋하지 않는다.
