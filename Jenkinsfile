// ::DEFINE 
def image_name          = "go-demo"
def service_name        = "go-demo"
def repo_name           = "efishery-skill-test"

// ::URL
def repo_url            = "https://github.com/greyhats13/${repo_name}.git"
def docker_username     = "greyhats13"

// ::INITIALIZATION
// def fullname            = "${service_name}-${env.BUILD_NUMBER}"
def version
podTemplate(
    label: fullname,
    containers: [
        //container template to perform docker build and docker push operation
        containerTemplate(name: 'docker', image: 'docker.io/docker', command: 'cat', ttyEnabled: true),

        //containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.3', command: 'cat', ttyEnabled: true)
    ],
    volumes: [
        //the mounting for container
        hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
    ]) 
{

    node(fullname) {
        stage("Checkout") {
            runPipeline = 'dev'
            //checkout process to Source Code Management
            def scm = checkout([$class: 'GitSCM', branches: [[name: runBranch]], userRemoteConfigs: [[credentialsId: 'github-auth-token', url: repo_url]]])
            echo "Running UAT Pipeline with ${scm.GIT_BRANCH} branch"
            //define version and helm directory
            version     = "debug"
        }
        //use container slave for docker to perform docker build and push
        stage('Build Container') {
            container('docker') {
                dockerBuild(image_name: image_name, image_version: "debug")
            }
        }

        stage('Push Container') {
            container('docker') {
                docker.withRegistry("https://${docker_username}", ecr_credentialsId) {
                    dockerPushTag(docker_username: docker_username, image_name: image_name, srcVersion: "debug", dstVersion: "latest")
                }
            }
        }
        // stage("Deployment") {
        //     container('docker') {
        //         deployKubernetes(docker_username: docker_username, image_name: image_name, image_version: version)
        //     }
        // }
}


//function to perform docker build that is defined in dockerfile
def dockerBuild(Map args) {
    sh "docker build -t ${args.image_name}:${args.image_version} ."
}

def dockerPushTag(Map args) {
    sh "docker tag ${args.image_name}:${args.srcVersion} ${args.docker_username}/${args.image_name}:${args.dstVersion}"
    sh "docker push ${args.image_name}:${args.dstVersion}"
}


//function to deploy helm chart to spinnaker by triggering the spinnaker pipeline via webhook, and wait for the spinnaker to trigger jenkins back when deployment is done.
// def deployKubernetes(Map args) {
//     def hook = registerWebhook()
//     echo "Hi Spinnaker!"
//     sh "curl ${args.spinnaker_webhook}-${args.version} -X POST -H 'content-type: application/json' -d '{ \"parameters\": { \"jenkins-url\": \"${hook.getURL()}\" }}'"
//     def data = waitForWebhook hook
//     echo "Webhook called with data: ${data}"
// }
