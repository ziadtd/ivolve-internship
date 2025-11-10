def call() {
    echo "Deploying application on Kubernetes"
                withCredentials([file(credentialsId: 'kube-config', variable: 'KUBECONFIG')]) {
                    sh '''
                    kubectl apply -f jenkins/Task31-PipelineWithAgentsAndSharedLib/Jdeployment.yaml --kubeconfig=$KUBECONFIG
                    kubectl rollout status deployment/myapp --kubeconfig=$KUBECONFIG
                    '''
                }            
}
