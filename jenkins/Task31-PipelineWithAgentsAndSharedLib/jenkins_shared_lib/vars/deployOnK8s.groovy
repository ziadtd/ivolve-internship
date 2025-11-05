def call() {
    echo "Deploying application on Kubernetes"
    sh '''
    kubectl apply -f jenkins/Task31-PipelineWithAgentsAndSharedLib/deployment.yaml
    kubectl get pods
    '''
}
