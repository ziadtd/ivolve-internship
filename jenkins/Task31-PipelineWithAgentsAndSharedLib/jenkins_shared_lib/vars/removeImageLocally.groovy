def call() {
    echo "Removing local image"
    sh 'docker rmi jenkins-app:latest || true'
}
