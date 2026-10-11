# Kubernetes 설치 Playbook 실행 순서

모든 명령은 `k8s/install` 디렉터리에서 실행한다.

## 실행 전 SSH 변수 설정

관리 호스트의 사용자명과 개인키 경로를 환경변수로 지정할 수 있다. 지정하지
않으면 `K8S_SSH_USER`는 `groom`, `K8S_SSH_KEY`는 현재 사용자의
`$HOME/.ssh/k8s_ed25519`를 사용한다.

```bash
export K8S_SSH_USER="${K8S_SSH_USER:-groom}"
export K8S_SSH_KEY="${K8S_SSH_KEY:-$HOME/.ssh/k8s_ed25519}"
```

`install/inventory/hosts.yml`은 같은 변수를 사용하므로, 환경변수를 설정한
터미널에서 Ansible 명령을 실행해야 한다.

## 01. 사전 점검

변경 없이 OS, 자원, Python, swap, hostname, NTP, sudo를 확인한다.

```bash
ansible-playbook -i inventory/hosts.yml playbooks/preflight.yml --ask-become-pass
```

## 02. 노드 기본 설정

swap, fstab, 커널 모듈, Kubernetes 네트워크 sysctl을 적용한다.

```bash
ansible-playbook -i inventory/hosts.yml playbooks/bootstrap.yml --ask-become-pass
```

재부팅까지 적용하려면 다음 옵션을 추가한다.

```bash
ansible-playbook -i inventory/hosts.yml playbooks/bootstrap.yml --ask-become-pass -e bootstrap_reboot=true
```

## 03. 사전 점검 재검증

bootstrap 적용 후 swap과 시스템 상태를 다시 확인한다.

```bash
ansible-playbook -i inventory/hosts.yml playbooks/preflight.yml --ask-become-pass
```

## 04. containerd 설치

containerd를 설치하고 systemd cgroup을 활성화한다.

```bash
ansible-playbook -i inventory/hosts.yml playbooks/containerd.yml --ask-become-pass
```

## 05. Kubernetes 패키지 설치

Kubernetes 저장소를 등록하고 `kubeadm`, `kubelet`, `kubectl`을 설치한 뒤
패키지 버전을 고정한다.

```bash
ansible-playbook -i inventory/hosts.yml playbooks/kubernetes-packages.yml --ask-become-pass
```

실행 전 `kubernetes-packages.yml`의 `kubernetes_minor_version`이 사용할
Kubernetes minor 버전과 일치하는지 확인한다.

## 06. Control Plane 초기화

`cp-01`에서만 `kubeadm init`을 실행하고, 관리 사용자용 kubeconfig를 구성한다.
`--pod-network-cidr`는 이후 설치할 CNI 설정과 일치해야 한다.

```bash
ansible-playbook -i inventory/hosts.yml playbooks/control-plane.yml --ask-become-pass
```

이 단계는 실제 클러스터를 생성한다. `control_plane_advertise_address`와
`pod_network_cidr`를 확인한 뒤 실행한다.

## 07. Calico CNI 설치

Control Plane에서 Calico CNI manifest를 적용하고 Calico DaemonSet과 노드 상태를
확인한다. Calico manifest는 `control-plane.yml`에서 지정한
`192.168.0.0/16` Pod CIDR을 기준으로 사용한다.

```bash
ansible-playbook -i inventory/hosts.yml \
  playbooks/addons/cni-calico.yml --ask-become-pass
```

Calico는 Worker 조인 전에 필요한 기본 CNI이므로 기본 설치에서는 이 단계에서
실행한다. 기본 설치가 이미 끝난 클러스터에서 다른 Addon과 함께 다시 확인하려면
`playbooks/addons.yml`을 사용할 수 있다.

## 08. Worker 노드 조인

Control Plane에서 join 명령을 생성해 Worker 노드에 실행하고, 마지막에 전체 노드
상태를 확인한다. join 토큰은 Ansible 로그에 출력하지 않는다.

```bash
ansible-playbook -i inventory/hosts.yml playbooks/workers.yml --ask-become-pass
```

Control Plane 초기화와 Worker 조인 후에는 설치 Playbook이 모든 노드의 kubelet에
`serverTLSBootstrap: true`를 설정한다. kubelet Serving Certificate는 노드의
HTTPS `10250` 포트에 사용된다.

Serving CSR을 확인한다.

```bash
kubectl get csr
```

`kubernetes.io/kubelet-serving` 서명 요청만 요청자·노드 IP/DNS SAN·사용 목적을
검토한 뒤 승인한다.

```bash
kubectl describe csr <serving-csr-name>
kubectl certificate approve <serving-csr-name>
```

기본 Kubernetes CSR 승인 컨트롤러는 kubelet Serving Certificate를 보안상
자동 승인하지 않으므로, 승인 기준을 확인하는 운영 절차가 필요하다. 모든
노드의 Serving Certificate가 발급된 뒤 Metrics Server를 설치한다.

## 09. Mac 관리 호스트에서 kubectl 사용

Python 가상환경은 `kubectl`을 설치하지 않으므로 Mac에 별도로 설치해야 한다.

```bash
brew install kubectl
kubectl version --client
```

Control Plane에서 관리 사용자용 kubeconfig를 복사한다.

```bash
mkdir -p ~/.kube

scp -i "$K8S_SSH_KEY" \
  "$K8S_SSH_USER@10.10.10.150:/home/$K8S_SSH_USER/.kube/config" \
  ~/.kube/k8s-config

chmod 600 ~/.kube/k8s-config
export KUBECONFIG=$HOME/.kube/k8s-config
```

클러스터 연결을 확인한다.

```bash
kubectl get nodes -o wide
kubectl get pods -A
```

매번 환경 변수를 입력하지 않으려면 zsh 설정에 등록한다.

```bash
echo 'export KUBECONFIG=$HOME/.kube/k8s-config' >> ~/.zshrc
source ~/.zshrc
```

`~/.kube/k8s-config`는 관리자 권한이 포함된 kubeconfig이므로 파일 권한을
`600`으로 유지하고 저장소에 커밋하지 않는다.

## 다음 단계

Mac에서 kubeconfig 설정을 완료한 뒤 CoreDNS, Calico, kube-system Pod 상태와
Pod 간 통신을 검증한다.

## 다음 단계: Addon 별도 관리

기본 Kubernetes 설치와 Addon 설치는 별도 작업으로 관리한다. 설치 Playbook은
노드·containerd·kubeadm·CNI·kubeconfig 준비까지만 담당한다.

클러스터 설치가 끝나면 다음 문서에서 실습에 필요한 Addon을 선택해 설치하고
검증한다.

- [Addon 설치 순서](../addons/README.md)
- [Addon Playbook 실행](./addons/README.md)
- [운영 Addon 자료](../../operations/addons/README.md)
- [클러스터 아키텍처 점검](../../operations/cluster/README.md#이미지-아키텍처-사전-점검)

Addon이 필요한 실습은 해당 Addon의 설치·확인 완료 후 시작한다.
