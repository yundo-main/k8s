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

## 3. Controller 설치 검증

Ingress 실습 전에 Controller와 `IngressClass/nginx`가 모두 있어야 한다.

### 1. Deployment 준비 상태 대기

```bash
kubectl -n ingress-nginx wait \
  --for=condition=available deployment/ingress-nginx-controller \
  --timeout=180s
```

- `-n ingress-nginx`: Ingress Controller Namespace를 지정한다.
- `wait`: 리소스가 특정 조건을 만족할 때까지 기다린다.
- `--for=condition=available`: Deployment가 사용 가능한 상태가 될 때까지
  기다린다.
- `--timeout=180s`: 최대 180초 동안 기다린다.

`deployment condition met` 메시지가 나오면 Controller Deployment가 Ready 상태다.

### 2. Controller Pod 확인

```bash
kubectl -n ingress-nginx get pods \
  -l app.kubernetes.io/component=controller
```

- `-n ingress-nginx`: Ingress Controller가 설치된 Namespace를 지정한다.
- `get pods`: Controller Pod의 생성·Ready·재시작 상태를 확인한다.
- `-l app.kubernetes.io/component=controller`: Pod 이름이 동적으로 바뀌어도
  Controller Label을 기준으로 조회한다.
- `READY`가 `1/1`, `STATUS`가 `Running`인지 확인한다.

### 3.1 Controller Pod 상세 정보 확인

```bash
kubectl -n ingress-nginx describe pod \
  -l app.kubernetes.io/component=controller
```

### 4. IngressClass 확인

```bash
kubectl get ingressclass nginx
```

- `IngressClass`는 클러스터 범위 리소스이므로 Namespace 옵션을 사용하지 않는다.
- `nginx`가 존재해야 `spec.ingressClassName: nginx`인 Ingress를 해당 Controller가
  처리한다.
- `CONTROLLER` 값은 보통 `k8s.io/ingress-nginx`로 표시된다.

### 5. NodePort Service 확인

```bash
kubectl -n ingress-nginx get svc ingress-nginx-controller
```

- Controller Pod로 전달하는 Service가 존재하는지 확인한다.
- `TYPE`이 `NodePort`인지 확인한다.
- HTTP 포트가 `80:30198/TCP`인지 확인한다.
- 현재 실습은 HTTPS를 사용하지 않으므로 `443:31476/TCP`가 있어도 TLS 검증은
  별도로 수행하지 않는다.

### 6. Service Endpoint 연결 확인

```bash
kubectl -n ingress-nginx get endpoints ingress-nginx-controller -o wide
```

Endpoint에 Controller Pod IP와 `80` 포트가 표시되어야 Service에서 Pod로
전달되는 경로가 연결된 상태다.

### 7. 외부 NodePort 확인

클러스터 노드에 네트워크로 접근할 수 있는 클라이언트에서 실행한다.

```bash
curl -v --connect-timeout 5 http://10.10.10.150:30198/
```

- TCP 연결 자체가 실패하면 노드 라우팅·방화벽·NodePort 접근을 확인한다.
- HTTP 응답이 반환되면 NodePort와 Controller까지 접근한 것이다.
- 이후 실제 Ingress 경로(`/`, `/api/`)는 `practice-order/11-ingress/`의 Ingress
  리소스와 Backend Service 상태를 별도로 확인한다.

`IngressClass/nginx`가 없거나 Controller Service가 없으면 Ingress 리소스만
생성되고 외부 라우팅은 동작하지 않는다. Controller 설치 방법은 사용하는
배포판과 설치 방식에 맞춰 선택하고, 설치 후 위 명령으로 확인한다.

설치 후 흐름은 [Ingress 설치·외부 라우팅 흐름도](../../../practice-order/11-ingress/ingress-overview.svg)에서 확인한다.

Ingress 오브젝트는 `practice-order/11-ingress/`에서 관리한다.
