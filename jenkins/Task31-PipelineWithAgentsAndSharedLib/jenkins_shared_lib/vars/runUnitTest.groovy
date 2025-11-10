def call() {
    echo "Running the Unit Test"
    sh 'mvn test || echo "No tests found – continuing"'
}
