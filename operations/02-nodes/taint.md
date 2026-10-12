# Node Taint 운영

문서 이동: [노드 운영](./README.md) · [노드 목록 조회](./get-nodes.md) · [노드 상세 확인](./describe-node.md) · [다음: 워크로드 운영](../03-workloads/README.md)

Taint는 Node에 배치 제한을 선언한다. Taint가 있는 Node에는 해당 효과를
허용하는 `toleration`이 Pod에 있어야 스케줄링할 수 있다.

```text
Node Taint       → Pod가 해당 Node에 배치될 수 있는 조건
Pod Toleration   → 특정 Taint를 허용하는 Pod 설정
```

Taint는 Pod를 즉시 삭제하는 기능이 아니라, 새 배치와 기존 Pod 처리 방식을
제어하는 기능이다.

## Taint 효과

| 효과 | 의미 |
| --- | --- |
| `NoSchedule` | Toleration이 없는 새 Pod를 배치하지 않음 |
| `PreferNoSchedule` | 가능하면 Toleration 없는 Pod를 피함 |
| `NoExecute` | 새 배치를 막고 기존 Pod도 퇴출할 수 있음 |

## 1. 현재 Taint 확인

```bash
kubectl get nodes
```

클러스터의 Node 이름과 Ready 상태를 확인한다.

```bash
kubectl describe node <node-name>
```

`Taints` 항목에서 해당 Node의 Taint와 효과를 확인한다.

```bash
kubectl get node <node-name> -o jsonpath='{.spec.taints}{"\n"}'
```

Node에 선언된 Taint를 JSON 형태로 간단히 확인한다.

## 2. 테스트용 Taint 추가

운영 중인 Node에 적용하기 전에 테스트 Node와 영향 범위를 확인한다.

```bash
kubectl taint nodes <node-name> dedicated=practice:NoSchedule
```

`dedicated=practice` Taint를 추가해 toleration이 없는 새 Pod의 배치를 막는다.

```bash
kubectl describe node <node-name>
```

Taint가 Node에 추가되었는지 확인한다.

```bash
kubectl get pods -A -o wide
```

새로 생성된 Pod가 해당 Node에 배치되지 않는지 확인한다. 기존 Pod는
`NoSchedule`만으로 자동 퇴출되지 않는다.

## 3. Toleration을 가진 Pod 예시

다음 설정을 가진 Pod는 `dedicated=practice:NoSchedule` Taint를 허용한다.

```yaml
spec:
  tolerations:
    - key: dedicated
      operator: Equal
      value: practice
      effect: NoSchedule
```

Toleration은 배치를 허용할 뿐이며, 해당 Node에 반드시 배치한다는 의미는 아니다.
특정 Node에만 배치하려면 `nodeSelector` 또는 `nodeAffinity`를 함께 사용한다.

## 4. Taint 제거

Taint의 key와 effect 뒤에 `-`를 붙여 제거한다.

```bash
kubectl taint nodes <node-name> dedicated=practice:NoSchedule-
```

테스트용 `dedicated=practice:NoSchedule` Taint를 제거한다.

```bash
kubectl describe node <node-name>
```

Taint가 제거되었는지 확인한다.

## 5. `NoExecute` 주의

`NoExecute`는 기존 Pod에도 영향을 줄 수 있으므로 운영 Node에 즉시 적용하지
않는다.

```bash
kubectl taint nodes <node-name> maintenance=true:NoExecute
```

Toleration이 없는 기존 Pod가 퇴출될 수 있는 유지보수 Taint 예시다. 테스트가
끝나면 반드시 제거한다.

```bash
kubectl taint nodes <node-name> maintenance=true:NoExecute-
```

유지보수 Taint를 제거한다.

## 점검 순서

1. Node의 현재 Taint와 Pod 배치 상태를 확인한다.
2. `NoSchedule`부터 테스트해 신규 Pod 배치 변화를 관찰한다.
3. 필요한 Pod에만 Toleration을 추가한다.
4. Taint와 Toleration만으로 부족하면 `nodeSelector` 또는 Affinity를 검토한다.
5. `NoExecute`는 Pod 퇴출 가능성을 확인한 뒤 적용한다.

관련 문서: [노드 운영 README](./README.md), [워크로드 운영](../03-workloads/README.md)
