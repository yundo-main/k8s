# Ingress

클러스터 외부 요청을 HTTP 경로에 따라 내부 Service로 전달한다.

이 실습은 [10-3tier](../10-3tier/README.md)에서 실행한 기존
`frontend`와 `fastcgi-backend` Service를 외부에 노출하는 단계다.

![Ingress 외부 노출과 3-Tier 라우팅](./ingress-overview.svg)

Controller가 설치되어 있지 않다면 먼저
[`install/playbooks/addons/ingress-nginx.yml`](../../install/playbooks/addons/ingress-nginx.yml)을
실행하고 [`operations/addons/ingress`](../../operations/addons/ingress/README.md)에서
운영 상태를 확인한다.
절차를 실행한다. Ingress YAML만 적용해서는 외부 요청을 받을 수 없다.

## 실습 설치 절차

### 1. 클러스터와 kubeconfig 확인

```bash
cd /Users/jarrod/project/code-test-check/k8s
export KUBECONFIG=/Users/jarrod/.kube/k8s-config
kubectl config current-context
kubectl get nodes
```

모든 노드가 `Ready`인지 확인한다.

### 2. NGINX Ingress Controller 설치

클라우드 LoadBalancer가 없는 실습 클러스터이므로 NodePort 방식으로 설치한다.

```bash
ansible-playbook -i install/inventory/hosts.yml \
  install/playbooks/addons/ingress-nginx.yml
```

이 명령은 다음 리소스를 생성한다.

- `ingress-nginx` Namespace
- NGINX Controller Deployment와 RBAC
- `IngressClass/nginx`
- `ingress-nginx-controller` NodePort Service

### 3. Controller 설치 검증

```bash
kubectl -n ingress-nginx wait \
  --for=condition=available deployment/ingress-nginx-controller \
  --timeout=180s
kubectl -n ingress-nginx get pods \
  -l app.kubernetes.io/component=controller
kubectl get ingressclass nginx
kubectl -n ingress-nginx get svc ingress-nginx-controller
```

정상 기준:

```text
Controller Pod: 1/1 Running
IngressClass:   nginx
HTTP NodePort:  30198
```

## Ingress Controller 확인

Ingress 리소스를 적용하기 전에 `ingress-nginx` Controller와 `nginx`
IngressClass가 설치되어 있는지 확인한다.

```bash
kubectl -n ingress-nginx get pods \
  -l app.kubernetes.io/component=controller
kubectl get ingressclass nginx
kubectl -n ingress-nginx get svc ingress-nginx-controller
```

현재 실습 클러스터의 Controller Service는 다음 NodePort를 사용한다.

```text
HTTP 80:30198/TCP
HTTPS 443:31476/TCP (TLS 설정 전)
```

현재 실습은 HTTP만 적용한다. HTTPS 포트는 Controller에 기본으로 존재하지만
인증서 Secret과 `spec.tls`를 구성하지 않았으므로 사용하지 않는다.

## 3-Tier용 Ingress 적용

10단계의 3-Tier 리소스를 먼저 배포한다.

```bash
kubectl apply -f practice-order/10-3tier/
kubectl get service frontend fastcgi-backend
```

그 다음 이 단계의 Ingress 리소스를 적용한다.

```bash
kubectl apply -f practice-order/11-ingress/ingress.yml
kubectl get ingress fastcgi-ingress
kubectl describe ingress fastcgi-ingress
```

라우팅:

- `/` → `frontend:80`
- `/api/` → `fastcgi-backend:8000`

### 4. 외부 HTTP 요청 검증

10단계 3-Tier 리소스가 실행된 뒤 다음 주소로 외부 접근한다.

```text
http://10.10.10.150:30198/login.html
http://10.10.10.151:30198/login.html
http://10.10.10.152:30198/login.html
```

명령줄에서는 다음처럼 확인할 수 있다.

```bash
curl -i http://10.10.10.150:30198/login.html
curl -i http://10.10.10.150:30198/api/
```

현재 `frontend-html` ConfigMap에는 `login.html`과 `register.html`만 있으므로
루트 경로(`/`)는 NGINX의 `index.html` 부재로 `403`이 반환될 수 있다. 이는
Ingress 라우팅 실패가 아니며, 다음 경로로 Frontend를 확인한다.

```text
/login.html
/register.html
```

`404` 또는 `503`이 나오면 다음 순서로 확인한다.

```bash
kubectl get ingress fastcgi-ingress
kubectl get service frontend fastcgi-backend
kubectl get endpoints frontend fastcgi-backend
kubectl -n ingress-nginx logs deployment/ingress-nginx-controller
```

현재 실습은 HTTP만 검증한다. HTTPS는 인증서 Secret과 `spec.tls`를 구성한 뒤
별도 실습으로 추가한다.

> Ingress는 대상 Service가 먼저 존재해야 실제 라우팅할 수 있다. 10단계에서
> Frontend·Backend Service를 먼저 생성한 뒤 11단계에서 적용한다.

## 삭제

```bash
kubectl delete -f practice-order/11-ingress/ingress.yml
```
