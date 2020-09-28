def image_name          = "go-demo"
def service_name        = "go-demo"
def repo_name           = "efishery-skill-test"
def repo_url            = "https://github.com/greyhats13/${repo_name}.git"
def docker_username     = "greyhats13"
def docker_creds        = "docker_creds"
def fullname            = "${service_name}-${env.BUILD_NUMBER}"
def version             = "alpha"
podTemplate(
    label: fullname , 
    serviceAccount: "jenkins",
    containers: [
        //container template to perform docker build and docker push operation
        containerTemplate(name: 'docker', image: 'docker.io/docker', command: 'cat', ttyEnabled: true, alwaysPullImage: true),
        containerTemplate(name: 'helm', image: 'alpine/helm:3.3.4', command: 'cat', ttyEnabled: true)
    ],
    volumes: [
        //the mounting for container
        hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
    ]) 
{

    node(fullname) {
        stage("Checkout") {
            echo "${service_name}-${env.BUILD_NUMBER}"
            runBranch = '*/master'
            def scm = checkout([$class: 'GitSCM', branches: [[name: runBranch]], userRemoteConfigs: [[credentialsId: 'git_creds', url: repo_url]]])
        }

        //use container slave for docker to perform docker build and push
        stage('Build Container') {
            container('docker') {
                dockerBuild(image_name: image_name, image_version: version)
            }
        }

        stage('Push Container') {
            container('docker') {
                docker.withRegistry("", docker_creds) {
                    dockerPush(docker_username: docker_username, image_name: image_name, srcVersion: "latest")
                    dockerPushTag(docker_username: docker_username, image_name: image_name, srcVersion: "latest", dstVersion: "${version}-${BUILD_NUMBER}")
                }
            }
        }

        stage('Helm Deploy') {
            container('helm') {
               sh "helm lint ."
               sh "helm -n sit install ${service_name} . --dry-run --debug"
               sh "helm -n sit upgrade --install ${service_name} ."
            }
        }
    }
}

//function to perform docker build that is defined in dockerfile
def dockerBuild(Map args) {
    sh "docker build -t ${args.image_name}:${args.image_version} ."
}

def dockerPush(Map args) {
    sh "docker push ${args.docker_username}/${args.image_name}"
}

def dockerPushTag(Map args) {
    sh "docker tag ${args.docker_username}/${args.image_name}:${args.srcVersion} ${args.docker_username}/${args.image_name}:${args.dstVersion}"
    sh "docker push ${args.docker_username}/${args.image_name}:${args.dstVersion}"
}
