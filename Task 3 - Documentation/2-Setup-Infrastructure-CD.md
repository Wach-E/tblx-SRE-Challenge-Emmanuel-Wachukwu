# Infrastructure Continuous Deployment

 GitHub has been offering OpenID Connect (ODIC) to authenticate against AWS. OpenID solves the problem of permanently valid credentials or technical users used in pipelines. The setup requires a few setup on the AWS Management Console.

1. In the AWS Console, under Identity and Access Management (IAM), from the left pane select **Identity providers** 
- Click **Add provider** and select `OpenID Connect`.
    The provider URL is `https://token.actions.githubusercontent.com` and the Audience is `sts.amazonaws.com`. It is also necessary to get the thumbprint using the **Get thumbprint** button.
    Click **Add provider button**
    Once the provider is created, we can create the necessary IAM Role that will allow us to access AWS resources from the GitHub Action.
2. Select **Roles** from the left pane:
    Click **Create role**
    - Select **Trusted entity type** as `Web Identity`. The identity provider must be selected as `token.actions.githubusercontent.com` and for Audience, select `sts.amazonaws.com`.
    - Next step is to assign permissions. This can be very specific or full access. It is of course possible to create an exact policy. For this case, just to keep it a bit more open, the AdministratorAccess role is taken.
    - For **Role details**, give it the following:
        role name: `tblx-github-role`
        description: `OpenID Connect to authenticate with tblx sre-challenge Github repo`
    - Click **Create role**.
3. After creating the role, open it again to adjust the trust relationships by correcting the condition set for connection. The key `token.actions.githubusercontent.com:sub` must get the desired GitHub repository.
    - Search and click `tblx-github-role`
    - Select **Trusted relationships**
    - Replace the Trusted entities condition to look like this:
    ```
    "Condition": {
                    "StringLike": {
                        "token.actions.githubusercontent.com:sub": "repo:Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu:*",
                        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                    }
                }
    ```
    After that, the role is ready for use and can be used in the GitHub workflow.

4. To integrate the OpenID Connect, the `application.yml` workflow will need to be modified. Below the `on` parameter, add the following:
```
permissions:
  id-token: write
  contents: read
```

The new section permission is important. The `id-token: write` entry allows the OIDC JWT ID token to be requested. Without this setting, it is not possible to use the authentication method described in the previous step.
The `contents: read` permission is again necessary to use the “checkout” action.

For the deployment to succeed, some AWS credentials need to be setup. This will be added as secrets and called as pipeline environment variables. Add the following below `permissions`:
```
env:
  AWS_REGION: us-west-1
  ASSUME_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
  EKS_CLUSTER_NAME: ${{ secrets.EKS_CLUSTER_NAME }}
```
Add the following to the secrets:
- AWS_ROLE_ARN: role to assume by Github, `arn:aws:iam::<your-account-id>:role/tblx-github-role`.
- EKS_CLUSTER_NAME: name of eks cluster. `tblx-challenge-sre`

Setup the deployment job by adding the following

```
deploy_eks_infrastructure:
    needs: [build_deploy]
    runs-on: ubuntu-20.04
    steps:
      - name: Check Out
        uses: actions/checkout@v2
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          role-to-assume: ${{ env.ASSUME_ROLE_ARN }}
          aws-region: ${{ env.AWS_REGION }}
      - name: Deploy EKS Cluster
        env:
          new-tag: ${{ needs.build_deploy.outputs.IMAGE_TAG }}
        run: |
          cd infrastructure/

          # Install Kubectl
          cd setup_environment
          ./kubectl-setup.sh

          # Deploy EKS cluster with IaC
          cd ../terraform-kubernetes(EKS)
          terraform init -input=false
          terraform apply --auto-approve

          # Obtain kube config from cluster
          aws eks update-kubeconfig --name ${{ env.EKS_CLUSTER_NAME }} --region ${{ env.AWS_REGION }}

          # Deploy manifests files
          cd manifests
          
          # Change the image tag in the deployment.yaml
          # export new_tag=$new-tag
          # sed -i -E "s/sre-tblx:([a-zA-]*)/sre-tblx:$new_tag/g" deployment.yaml

          kubectl apply -f .
```
Here is what this job does:
- Checkout of the repository on the develop branch.
- Navigate to the infrastructure directory.
- Navigate to the setup_environment directory and install Kubectl using `kubectl-setup.sh`
- Navigate to the terraform-kubernetes(EKS) directory and deploy EKS Cluster using terraform.
- Obtain EKS cluster kubeconfig and configure the kubectl.
- Navigate to the manifest file directory and deploy kubernetes manifest files.

The complete `application.yml` looks like this:
```
# CI/CD Pipeline for Task 3

name: Daimler-Truck WebApp CI/CD

# Controls when the workflow will run.
on:
  # Triggers the workflow on push events only for the main branch.
  push:
    branches: [develop]
  pull_request:
    branches: [develop]

permissions:
  # Allow the OIDC JWT ID token to be requested
  id-token: write
  # Allow OIDC use the “checkout” action
  contents: read

env:
  AWS_REGION: us-west-1
  ASSUME_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
  EKS_CLUSTER_NAME: ${{ secrets.EKS_CLUSTER_NAME }}

jobs:
  test:
    ## Configure the operating system the workflow should run on.
    runs-on: ubuntu-20.04
    ## Define a sequence of steps to be executed
    steps:
      ## Use the public `checkout` action  in version v2
      ## to checkout the existing code in the repository
      - uses: actions/checkout@v2
        ## Use the public `setup-python` actoin  in version v2
        ## to install python on the Ubuntu based environment.
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.8
      ## Install all necessary dependecies within the requirements.txt file.
      - name: Install dependencies
        run: |
          cd app
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      ## Run all pytests by inovking the `pytest command`
      - name: Test with pytest
        run: |
          pytest

  build_deploy:
    needs: [test]
    runs-on: ubuntu-20.04
    outputs:
      IMAGE_TAG: ${{ steps.docker-build.outputs.image-tag }}
    steps:
      - name: checkout
        uses: actions/checkout@v2
      - name: Build and push
        id: docker-build
        env:
          USER: ${{ secrets.DOCKERHUB_USERNAME }}
        run: |
          cd app
          export IMAGE_TAG=$(git rev-parse --short HEAD)
          echo "${{ secrets.DOCKERHUB_PASSWORD }}" | docker login -u ${{ secrets.DOCKERHUB_USERNAME }} --password-stdin

          docker build --platform linux/amd64 -t sre-tblx .
          docker tag sre-tblx ${USER}/sre-tblx:${IMAGE_TAG}
          docker push ${USER}/sre-tblx:${IMAGE_TAG}
          echo "::set-output name=image-tag::$IMAGE_TAG"

  deploy_eks_infrastructure:
    needs: [build_deploy]
    runs-on: ubuntu-20.04
    steps:
      - name: Check Out
        uses: actions/checkout@v2
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          role-to-assume: ${{ env.ASSUME_ROLE_ARN }}
          aws-region: ${{ env.AWS_REGION }}
      - name: Deploy EKS Cluster
        id: deploy-eks
        env:
          new-tag: ${{ needs.build_deploy.outputs.IMAGE_TAG }}
        run: |
          cd infrastructure/

          # Install Kubectl
          cd setup_environment
          ./kubectl-setup.sh

          # Deploy EKS cluster with IaC
          cd ../terraform-kubernetes(EKS)
          terraform init -input=false
          terraform apply --auto-approve

          # Obtain kube config from cluster
          aws eks update-kubeconfig --name ${{ env.EKS_CLUSTER_NAME }} --region ${{ env.AWS_REGION }}

          # Deploy manifests files
          cd manifests

          # Change the image tag in the deployment.yaml
          # export new_tag=$new-tag
          # sed -i -E "s/sre-tblx:([a-zA-]*)/sre-tblx:$new_tag/g" deployment.yaml

          kubectl apply -f .

```

As the next step, this deployment.yaml file would need to change according to the docker image tag.
          
