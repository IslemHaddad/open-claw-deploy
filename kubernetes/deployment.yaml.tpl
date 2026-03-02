apiVersion: apps/v1
kind: Deployment
metadata:
  name: openclaw
  namespace: ${K8S_NAMESPACE}
spec:
  replicas: ${REPLICAS}
  selector:
    matchLabels:
      app: openclaw
  template:
    metadata:
      labels:
        app: openclaw
    spec:
      containers:
        - name: openclaw
          image: ${OPENCLAW_IMAGE}
          ports:
            - containerPort: 3000
          env:
            - name: PORT
              value: "${OPENCLAW_PORT}"
---
apiVersion: v1
kind: Service
metadata:
  name: openclaw
  namespace: ${K8S_NAMESPACE}
spec:
  selector:
    app: openclaw
  ports:
    - name: http
      port: ${OPENCLAW_PORT}
      targetPort: 3000
  type: ClusterIP
