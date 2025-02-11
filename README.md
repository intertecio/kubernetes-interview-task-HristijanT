# **Blue/Green Deployment with Jenkins on Minikube**

This project demonstrates a **Blue/Green Deployment** strategy using **Jenkins** on a local **Minikube Kubernetes cluster**.

## **Overview**
The project consists of:  

- A **sample Node.js application** deployed on Kubernetes  
- **Two Jenkins pipelines**:  
- - **Deploy Green Pipeline** → Deploys a new version (Green) while keeping the old version (Blue) running  
- - **Switch Traffic Pipeline** → Switches traffic to the Green version and a manual approval step for either finalizing the deployment or rolling back to the Blue version 

---

## **Pre-requisites**
Before you begin, ensure you have the following installed:

| Tool        | Installation Guide |
|------------|------------------|
| **Docker**  | [Install Docker](https://docs.docker.com/get-docker/) |
| **Minikube** | [Install Minikube](https://minikube.sigs.k8s.io/docs/start/) |
| **Helm** | [Install Helm](https://helm.sh/docs/intro/install/) |
| **Kubectl** | [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) |

### **🔹 Install Jenkins on Minikube**
Follow the **official Jenkins guide** for installing Jenkins on Kubernetes with Helm:  
🔗 [Jenkins on Kubernetes](https://www.jenkins.io/doc/book/installing/kubernetes/#install-jenkins-with-helm-v3)

## **Project Structure**
- The project structure can be found in the `project_structure.txt` file.

## 🛠️ Setup

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Deploy Jenkins**
   ```bash
   kubectl create namespace jenkins
   helm repo add jenkins https://charts.jenkins.io
   helm install jenkins jenkins/jenkins -n jenkins -f jenkins/jenkins-manifests/jenkins-values.yaml
   ```

3. **Configure Jenkins**
   - Install required plugins:
     - Kubernetes
     - Docker
     - Git
   - Configure Kubernetes cloud
   - Add Docker Hub credentials with id `dockerhub-credentials`
   - Add GitHub repository, credentials and the correct path to the Jenkinsfile for each pipeline.

4. **Run the initial deployment script**

    *Environment Variables:*
    - `DOCKERHUB_USERNAME`: Your Docker Hub username
    - `DOCKERHUB_PASSWORD`: Your Docker Hub password

   ```bash
   chmod +x initial-deployment.sh
   ./initial-deployment.sh
   ```

## Pipelines

### Deploy Green Pipeline
This pipeline deploys a new version of the application (Green) while keeping the old version (Blue) running. It also provides access URLs for both versions. The original plan was to implement a github webhook that triggers on push events to the main branch of the repository. However github webhooks cannot be implemented on a local minikube cluster. Therefore the pipeline is triggered manually.

### Switch Traffic Pipeline
This pipeline switches traffic to the Green version and includes a manual approval step for either finalizing the deployment (proceed) or rolling back to the Blue version (rollback). In both cases the unused environment is deleted. This pipeline is triggered manually.

## 🔍 Monitoring

- Monitor deployments: `kubectl get deployments`
- Check services: `kubectl get services`
- View pods: `kubectl get pods`
- Check logs: `kubectl logs <pod-name>`

## Possible improvements
- As previously mentioned the trigger for the **Deploy Green Pipeline** should be a github webhook. This would allow for automatic deployments on every push to the main branch.
- The **Switch Traffic Pipeline** could be improved by adding a health check to the green deployment before switching traffic to it. This would ensure that the green deployment is healthy before switching traffic to it.
- The project could be adapted to run on cloud providers like:
  - **AWS EKS (Elastic Kubernetes Service)**
    - Replace Minikube with EKS cluster
    - Use AWS Load Balancer instead of NodePort services
    - Integrate with AWS ECR instead of DockerHub
    - Utilize AWS Secrets Manager for credentials

  Key benefits of cloud deployment:
  - Better scalability and high availability
  - Built-in monitoring and logging
  - Managed Kubernetes service
  - Integration with cloud native services
  - Production-grade security features