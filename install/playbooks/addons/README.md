# Addon Playbook 실행

기본 Kubernetes 설치가 끝난 뒤 선택형 구성요소를 설치하는 Ansible 실행 진입점이다.
이 디렉터리의 Playbook은 실행 순서와 대상 노드를 정의하고, 필요한 경우
`install/addons/`의 실제 설치 스크립트를 호출한다.

```text
install/playbooks/addons/
├── all.yml              # 모든 선택 구성요소의 실행 순서만 조정
├── cni-calico.yml       # Control Plane에서 Calico 설치
├── metrics-server.yml   # install/addons/autoscaling 스크립트 호출
├── ingress-nginx.yml    # install/addons/ingress 스크립트 호출
└── nfs-csi.yml          # install/addons/storage 스크립트 호출
```

## 전체 Addon 설치

`install/playbooks` 디렉터리에서 실행한다.

```bash
ansible-playbook -i ../inventory/hosts.yml addons/all.yml --ask-become-pass
```

이 명령은 다음 Addon을 순서대로 설치한다.

- Calico CNI
- Metrics Server
- NGINX Ingress Controller
- NFS CSI Driver

Calico는 기본 설치 순서에서도 `addons/cni-calico.yml`로 설치한다. 기본 설치에서
이미 실행했다면 `addons/all.yml`에서 다시 적용해도 manifest apply와 rollout 확인만
수행되며, Calico 설치 상태는 유지된다.

## 개별 Addon 설치

```bash
ansible-playbook -i ../inventory/hosts.yml addons/cni-calico.yml
```

Calico CNI를 개별 설치한다.

```bash
ansible-playbook -i ../inventory/hosts.yml addons/metrics-server.yml
```

Metrics Server를 개별 설치한다.

```bash
ansible-playbook -i ../inventory/hosts.yml addons/ingress-nginx.yml
```

NGINX Ingress Controller를 개별 설치한다.

```bash
ansible-playbook -i ../inventory/hosts.yml addons/nfs-csi.yml
```

NFS CSI Driver를 개별 설치한다.

저장소 루트에서 실행하려면 경로를 다음처럼 작성한다.

```bash
ansible-playbook -i inventory/hosts.yml \
  install/playbooks/addons/cni-calico.yml --ask-become-pass
```

선택 구성요소는 기본 Kubernetes 설치와 별도의 단계다. 기본 설치 Playbook이
성공한 뒤 `addons/all.yml` 또는 필요한 개별 Playbook만 실행한다.
