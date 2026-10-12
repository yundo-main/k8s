# SSH 키 준비와 노드 등록

Ansible은 관리 호스트에서 SSH로 Control Plane과 Worker Node에 접속한다.
따라서 Kubernetes 설치 Playbook을 실행하기 전에 관리 호스트의 개인키와
각 노드의 공개키 등록을 완료해야 한다.

## 1. 관리 호스트에서 키 생성

개인키는 관리 호스트에만 보관하고 저장소에는 올리지 않는다.

```bash
export K8S_SSH_KEY="${K8S_SSH_KEY:-$HOME/.ssh/k8s_ed25519}"
export K8S_SSH_PUB_KEY="${K8S_SSH_KEY}.pub"

mkdir -p "$(dirname "$K8S_SSH_KEY")"
ssh-keygen -t ed25519 -f "$K8S_SSH_KEY" -C "k8s-ansible"
chmod 600 "$K8S_SSH_KEY"
chmod 644 "$K8S_SSH_PUB_KEY"
```

이미 키가 있다면 덮어쓰지 말고 다음처럼 존재 여부를 확인한다.

```bash
test -f "$K8S_SSH_KEY" && test -f "$K8S_SSH_PUB_KEY" \
  && echo "SSH 키가 준비되어 있습니다."
```

## 2. 노드에 공개키 등록

노드의 초기 사용자 비밀번호 또는 기존 SSH 키가 한 번은 필요하다. 다음 명령은
공개키만 노드의 `authorized_keys`에 등록한다. 개인키는 노드에 복사하지 않는다.

```bash
export K8S_SSH_USER="${K8S_SSH_USER:-groom}"
export K8S_NODE_IPS="10.10.10.150 10.10.10.151 10.10.10.152"

for node_ip in $K8S_NODE_IPS; do
  ssh-copy-id -i "$K8S_SSH_PUB_KEY" "$K8S_SSH_USER@$node_ip"
done
```

macOS에 `ssh-copy-id`가 없다면 공개키를 직접 추가한다.

```bash
for node_ip in $K8S_NODE_IPS; do
  cat "$K8S_SSH_PUB_KEY" | ssh "$K8S_SSH_USER@$node_ip" \
    'umask 077; mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; cat >> ~/.ssh/authorized_keys; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys'
done
```

동일한 공개키를 반복 등록하면 중복 줄이 생길 수 있으므로, 운영 환경에서는
`ssh-copy-id`를 사용하거나 등록 후 `authorized_keys`를 확인한다.

## 3. 키 기반 접속 확인

각 노드에 비밀번호 없이 접속되는지 확인한다.

```bash
for node_ip in $K8S_NODE_IPS; do
  ssh -i "$K8S_SSH_KEY" \
    -o IdentitiesOnly=yes \
    "$K8S_SSH_USER@$node_ip" 'hostname; python3 --version; sudo -n true'
done
```

`sudo -n true`가 실패하면 해당 원격 사용자의 sudo 권한 또는 sudo 비밀번호
정책을 확인한다. Playbook은 필요한 단계에서 `--ask-become-pass`를 사용하므로
SSH 로그인 비밀번호와 sudo 비밀번호가 다를 수 있다.

## 4. Ansible 변수 연결

`install/inventory/hosts.yml`은 다음 환경변수를 사용한다.

```bash
export K8S_SSH_USER="groom"
export K8S_SSH_KEY="$HOME/.ssh/k8s_ed25519"
```

설정한 같은 터미널에서 연결을 검증한다.

```bash
cd /path/to/project/k8s/install
ansible all -i inventory/hosts.yml -m ping
```

정상 결과는 각 노드에 대해 `SUCCESS`와 `"ping": "pong"`을 보여준다.

## 5. 보안 확인

- 개인키(`k8s_ed25519`)는 저장소·메신저·노드에 복사하지 않는다.
- 개인키 권한은 `600`으로 유지한다.
- `authorized_keys` 권한은 디렉터리 `700`, 파일 `600`을 사용한다.
- 노드의 호스트 키 변경 경고는 무시하지 말고 실제 노드인지 확인한다.
- 노드 IP와 SSH 사용자 변경 시 `inventory/hosts.yml`과 환경변수를 함께 확인한다.
