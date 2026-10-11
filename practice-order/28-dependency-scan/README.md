# 28. 의존성 취약점 검사

Python 패키지에 알려진 취약점이 있는지 검사한다.

```bash
python3 -m pip install --upgrade pip-audit
python3 -m pip_audit \
  -r k8s/practice-order/22-image-build/backend/requirements.txt
```

CI에서는 검사 결과가 실패하면 이미지 빌드 단계로 넘어가지 않도록 구성한다.

