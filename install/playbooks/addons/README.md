# Addon Playbook

기본 Kubernetes 설치가 끝난 뒤 선택형 Addon을 설치하는 Ansible 진입점이다.
실제 클러스터 변경은 이 디렉터리의 Playbook을 명시적으로 실행할 때만
발생한다.

## 전체 Addon 설치

`install/playbooks` 디렉터리에서 실행한다.

```bash
ansible-playbook -i ../inventory/hosts.yml addons.yml --ask-become-pass
```

이 명령은 다음 Addon을 순서대로 설치한다.

- Calico CNI
- Metrics Server
- NGINX Ingress Controller
- NFS CSI Driver

Calico는 기본 설치 순서에서도 `addons/cni-calico.yml`로 설치한다. 기본 설치에서
이미 실행했다면 `addons.yml`에서 다시 적용해도 manifest apply와 rollout 확인만
수행되며, Calico 설치 상태는 유지된다.

## 개별 Addon 설치

```bash
ansible-playbook -i ../inventory/hosts.yml cni-calico.yml
ansible-playbook -i ../inventory/hosts.yml addons/metrics-server.yml
ansible-playbook -i ../inventory/hosts.yml addons/ingress-nginx.yml
ansible-playbook -i ../inventory/hosts.yml addons/nfs-csi.yml
```

Calico 개별 설치 명령은 `install/playbooks` 디렉터리에서 다음처럼 실행해도
된다.

```bash
ansible-playbook -i inventory/hosts.yml \
  playbooks/addons/cni-calico.yml --ask-become-pass
```

Addon은 기본 Kubernetes 설치와 별도의 선택 단계다. 기본 설치 Playbook이
성공한 뒤 필요한 Addon만 실행한다.
