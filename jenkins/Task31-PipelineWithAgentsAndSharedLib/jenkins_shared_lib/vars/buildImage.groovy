def call() {
    echo "Building Docker image"
    sh 'docker build -t jenkins-app:latest jenkins/Task31-PipelineWithAgentsAndSharedLib/Jenkins_App'
}
