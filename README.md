# Docker and Github Action for Kubernetes CLI

This action provides `kubectl` for Github Actions.

## Usage

`.github/workflows/push.yml`

```yaml
on: push
name: deploy
jobs:
  deploy:
    name: deploy to cluster
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-1
   
    - name: deploy to cluster
      uses: bsormagec/kubectl-aws-eks-arm64@1.0.1
      env:
        KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA_STAGING }}
        ECR_REGISTRY: my-registry
        ECR_REPOSITORY: my-app
        IMAGE_TAG: ${{ github.sha }}
      with:
        args: kubectl set image deployment/$ECR_REPOSITORY $ECR_REPOSITORY=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        
# Or apply k8s manifests with envsubst:
    - name: apply with envsubst 
      uses: bsormagec/kubectl-aws-eks-arm64@1.0.1
      env:
        ENV_VAR: ${{ env.ENV_VAR }}
        KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA_STAGING }}
      with:
        args: envsubst < Deployment.yaml | kubectl apply -n app -f -
        
# Install a helm release:
    - name: Install release
      uses: bsormagec/kubectl-aws-eks-arm64@1.0.1
      env:
        KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA_STAGING }}
      with:
        args: helm install my-release charts/my-chart
        
    - name: verify deployment
      uses: kodermax/kubectl-aws-eks@master
      env:
        KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
      with:
        args: kubectl rollout status deployment/my-app
```

## Secrets

`KUBE_CONFIG_DATA` – **required**: A base64-encoded kubeconfig file with credentials for Kubernetes to access the cluster. You can get it by running the following command:

```bash
cat $HOME/.kube/config | base64
```
