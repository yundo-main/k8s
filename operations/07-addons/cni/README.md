# CNI 컨트롤러

문서 이동: [확장 구성요소](../README.md) · [Autoscaling](../autoscaling/README.md) · [Ingress](../ingress/README.md) · [Storage](../storage/README.md) · [Operators](../operators/README.md)

Pod 네트워크와 노드 간 통신을 구성한다.

현재 클러스터에는 Calico가 설치되어 있으며, 설치 플레이북은 다음 위치에 있다.

```text
k8s/install/playbooks/addons/cni-calico.yml
```

기본 설치에서는 Worker 조인 전에 다음 명령으로 설치한다.

```bash
ansible-playbook -i install/inventory/hosts.yml \
  install/playbooks/addons/cni-calico.yml --ask-become-pass
```

다른 Addon과 함께 재확인하려면 `install/playbooks/addons.yml`을 사용한다.
