# Ingress Controller

Ingress 오브젝트의 라우팅 규칙을 실제 프록시·로드밸런서 동작으로 구현한다.

예시:

- NGINX Ingress Controller
- Traefik
- HAProxy Ingress

## 설치

이 클러스터는 클라우드 LoadBalancer가 없는 Ubuntu 기반 베어메탈 환경이므로
NGINX Ingress Controller를 NodePort 방식으로 설치한다.

```bash
cd /Users/jarrod/project/code-test-check/k8s
KUBECONFIG=/Users/jarrod/.kube/k8s-config \
  ansible-playbook -i install/inventory/hosts.yml \
    install/playbooks/addons/ingress-nginx.yml
```

`KUBECONFIG`를 이미 셸 환경 변수로 설정했다면 앞부분은 생략할 수 있다.

기본 설치 버전은 `v1.15.1`이며, 다음 포트를 사용한다.

```text
HTTP  80:30198/TCP
HTTPS 443:31476/TCP (Controller 기본 포트만 노출, TLS 미적용)
```

현재 11번 실습은 HTTP만 사용한다. HTTPS를 실제로 사용하려면 인증서 Secret과
`Ingress.spec.tls` 설정이 추가로 필요하므로, 현재는 `https://` 주소로 접속하지
않는다.

버전을 바꾸려면 다음처럼 실행한다.

```bash
INGRESS_NGINX_VERSION=v1.15.1 \
  ansible-playbook -i install/inventory/hosts.yml \
    install/playbooks/addons/ingress-nginx.yml
```

## 설치 후 확인

Ingress 실습 전에 Controller와 `IngressClass/nginx`가 모두 있어야 한다.

```bash
kubectl -n ingress-nginx get pods \
  -l app.kubernetes.io/component=controller
kubectl get ingressclass nginx
kubectl -n ingress-nginx get svc ingress-nginx-controller
```

`IngressClass/nginx`가 없거나 Controller Service가 없으면 Ingress 리소스만
생성되고 외부 라우팅은 동작하지 않는다. Controller 설치 방법은 사용하는
배포판과 설치 방식에 맞춰 선택하고, 설치 후 위 명령으로 확인한다.

설치 후 흐름은 [Ingress 설치·외부 라우팅 흐름도](../../../practice-order/11-ingress/ingress-overview.svg)에서 확인한다.

Ingress 오브젝트는 `practice-order/11-ingress/`에서 관리한다.
