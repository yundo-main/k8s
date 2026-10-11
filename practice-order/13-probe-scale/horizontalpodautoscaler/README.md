# HorizontalPodAutoscaler

CPU·메모리 또는 사용자 정의 메트릭에 따라 Deployment나 StatefulSet의
복제본 수를 자동 조정한다.

## 기존 3-Tier Backend 적용

기존 10단계 3-Tier의 `fastcgi-backend` Deployment를 대상으로 CPU 기반 HPA를
적용한다.

대상 파일:

- [`backend-hpa.yml`](./backend-hpa.yml)
- [`../backend-operational.yml`](../backend-operational.yml): CPU·메모리 requests/limits와 Probe 포함

먼저 Metrics Server가 동작하는지 확인한다.

```bash
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl top pods
```

Backend Deployment를 적용한 뒤 HPA를 적용한다.

```bash
kubectl apply -f ../backend-operational.yml
kubectl apply -f backend-hpa.yml
kubectl get hpa fastcgi-backend-hpa
kubectl describe hpa fastcgi-backend-hpa
```

HPA는 CPU 사용률이 60%를 넘으면 `fastcgi-backend` Pod를 최대 3개까지
확장한다. MariaDB StatefulSet은 데이터 일관성을 위해 이 기본 실습의 HPA
대상에서 제외한다.

> Backend 이미지는 Pod 시작 시 Python 패키지를 설치하므로 HPA로 새 Pod가
> 생성될 때 시작 시간이 길어질 수 있다. 운영 환경에서는 의존성이 포함된
> 이미지를 사용한다.
