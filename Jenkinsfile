def image_name          = "go-demo"
def service_name        = "go-demo"
def repo_name           = "efishery-skill-test"
def repo_url            = "https://github.com/greyhats13/${repo_name}.git"
def docker_username     = "greyhats13"
def docker_creds        = "docker_creds"
def fullname            = "${service_name}"
podTemplate(
    label: "slave",
    containers: [
        //container template to perform docker build and docker push operation
        containerTemplate(name: 'docker', image: 'docker.io/docker', command: 'cat', ttyEnabled: true, alwaysPullImage: false, workingDir: '/home/jenkins/agent', resourceRequestCpu: '50m',
        resourceLimitCpu: '100m',
        resourceRequestMemory: '100Mi',
        resourceLimitMemory: '200Mi',),
        containerTemplate(name: 'helm', image: 'docker.io/alpine/helm', command: 'cat', ttyEnabled: true, alwaysPullImage: false, workingDir: '/home/jenkins/agent', resourceRequestCpu: '50m',
        resourceLimitCpu: '100m',
        resourceRequestMemory: '100Mi',
        resourceLimitMemory: '200Mi',)
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
        container('docker') {
            docker.withRegistry("", docker_creds) {
                stage('Build Container') {
                    dockerBuild(image_name: image_name, image_version: "debug")
                }
                stage('Push Container') {
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
               sh "helm lint ."
               sh "helm install --dry-run --debug go-demo go-demo -n sit"
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
