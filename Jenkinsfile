def image_name          = "go-demo"
def service_name        = "go-demo"
def repo_name           = "efishery-skill-test"
def repo_url            = "https://github.com/greyhats13/${repo_name}.git"
def docker_username     = "greyhats13"
def docker_creds        = "docker_creds"
def fullname            = "${service_name}"
podTemplate(
    label: fullname,
    containers: [
        //container template to perform docker build and docker push operation
        containerTemplate(name: 'docker', image: 'docker.io/docker', command: 'cat', ttyEnabled: true),

        containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.19.2', command: 'cat', ttyEnabled: true),
        
        containerTemplate(name: 'helm', image: 'docker.io/alpine/helm:3.3.4', command: 'cat', ttyEnabled: true)
    ],
    volumes: [
        //the mounting for container
        hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
    ]) 
{

    node(fullname) {
        stage("Checkout") {
            runBranch = '*/master'
            //checkout process to Source Code Management
            def scm = checkout([$class: 'GitSCM', branches: [[name: runBranch]], userRemoteConfigs: [[credentialsId: 'git_creds', url: repo_url]]])
            echo "Running Dev Pipeline with ${scm.GIT_BRANCH} branch"
            //define version and helm directory
        }
        //use container slave for docker to perform docker build and push
        stage('Build Container') {
            container('docker') {
                dockerBuild(image_name: image_name, image_version: "debug")
            }
        }

        stage('Push Container') {
            container('docker') {
                docker.withRegistry("", docker_creds) {
                    dockerPushTag(docker_username: docker_username, image_name: image_name, srcVersion: "debug", dstVersion: "latest")
                }
            }
        }

        stage('Deploy') {
            // container('kubectl') {
            //         sh "kubectl apply -f k8s-deployment/deployment.yaml -n sit --validate=false"
            //         sh "kubectl apply -f k8s-deployment/service.yaml -n sit --validate=false"
            //         sh "kubectl apply -f k8s-deployment/ingress.yaml -n sit --validate=false"
            // }
            container('helm') {
                sh "helm version"
            }
        }
    }
}


//function to perform docker build that is defined in dockerfile
def dockerBuild(Map args) {
    sh "docker build -t ${args.image_name}:${args.image_version} ."
}

def dockerPushTag(Map args) {
    sh "docker tag ${args.image_name}:${args.srcVersion} ${args.docker_username}/${args.image_name}:${args.dstVersion}"
    sh "docker push ${args.docker_username}/${args.image_name}:${args.dstVersion}"
}
