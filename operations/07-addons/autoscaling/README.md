# Metrics Server와 Autoscaling

문서 이동: [확장 구성요소](../README.md) · [CNI](../cni/README.md) · [Ingress](../ingress/README.md) · [Storage](../storage/README.md) · [Operators](../operators/README.md)

Metrics Server는 Kubernetes API에 Pod와 Node의 CPU·메모리 사용량을 제공한다.
HPA는 이 메트릭을 사용해 Deployment의 Pod 수를 자동 조정한다.

## 설치와 운영 확인

Metrics Server는 기본 Kubernetes 설치와 별도로 준비한다.

```bash
ansible-playbook -i install/inventory/hosts.yml \
  install/playbooks/addons/metrics-server.yml
```

Metrics Server Addon을 설치한다.

```bash
bash ./operations/07-addons/autoscaling/check-metrics-server.sh
```

Metrics Server의 설치 상태와 API 응답을 점검한다.
```

설치 Playbook은 kubelet에 `serverTLSBootstrap: true`를 설정한다. Serving CSR을
검토·승인해 노드 인증서를 발급한 뒤 Metrics Server를 설치하면 인증서 검증이
활성화된다. `--kubelet-insecure-tls`는 기본으로 사용하지 않는다.

아직 Serving Certificate를 발급하지 않은 기존 실습 클러스터에서만 다음처럼
명시적으로 임시 사용한다.

```bash
METRICS_SERVER_INSECURE_TLS=true \
  ansible-playbook -i install/inventory/hosts.yml \
    install/playbooks/addons/metrics-server.yml
```

이 단계는 `practice-order/13-probe-scale`보다 먼저 운영 담당자가 완료한다.

## 확인 기준

```bash
kubectl get deployment metrics-server -n kube-system
```

Metrics Server Deployment가 원하는 replica와 Available 상태를 만족하는지
확인한다.

```bash
kubectl get apiservice v1beta1.metrics.k8s.io
```

Metrics APIService의 `AVAILABLE=True` 여부를 확인한다.

```bash
kubectl top nodes
```

노드 CPU·메모리 메트릭이 조회되는지 확인한다.

```bash
kubectl top pods -A
```

모든 Namespace의 Pod 메트릭이 조회되는지 확인한다.

`kubectl top`이 정상적으로 결과를 반환해야 HPA 메트릭을 사용할 수 있다.

문제가 발생하면 Metrics Server Pod 로그와 APIService 상태를 먼저 확인한다.

```bash
kubectl get pods -n kube-system -l k8s-app=metrics-server
```

Metrics Server Pod의 Ready 상태와 재시작 횟수를 확인한다.

```bash
kubectl describe apiservice v1beta1.metrics.k8s.io
```

Metrics APIService의 Endpoint, 인증서, 연결 오류를 상세 확인한다.

```bash
kubectl logs -n kube-system deploy/metrics-server
```

Metrics Server가 kubelet 메트릭을 수집하지 못한 원인을 로그에서 확인한다.

## 구성요소 구분

예시:

- Metrics Server
- Horizontal Pod Autoscaler
- Cluster Autoscaler

Metrics Server는 운영 Addon이고, HPA는 애플리케이션 운영 실습 리소스다.
