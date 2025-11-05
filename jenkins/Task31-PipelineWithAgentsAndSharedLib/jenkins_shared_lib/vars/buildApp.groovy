def call() {
    echo "Building app"
    sh 'mvn clean package -f jenkins/Task31-PipelineWithAgentsAndSharedLib/Jenkins_App/pom.xml'
}
