// This Jenkinsfile will build a builder image and then run the actual build and tests inside this image
// It's very important to not execute any scripts outside of the builder container, as it's our protection against
// external developers bringing in harmful code into Jenkins.
// Jenkins will only run the build if this Jenkinsfile was not modified in an external pull request. Only branches
// which are part of the Dash repo will allow modification to the Jenkinsfile.

def targets = [
  'win32',
  'win64',
  //'linux32',
  //'linux64',
  //'linux64_nowallet',
  //'linux64_release',
  //'mac',
]

def tasks = [:]
for(int i = 0; i < targets.size(); i++) {
  def target = targets[i]

  tasks["${target}"] = {
    node {
      def BUILD_NUMBER = sh(returnStdout: true, script: 'echo $BUILD_NUMBER').trim()
      def UID = sh(returnStdout: true, script: 'id -u').trim()
      def HOME = sh(returnStdout: true, script: 'echo $HOME').trim()
      def pwd = sh(returnStdout: true, script: 'pwd').trim()

      checkout scm

      def hasCache = false
      try {
        copyArtifacts(projectName: "dashpay-dash/${BRANCH_NAME}", selector: lastSuccessful, filter: "ci-cache-${target}.tar.gz");
        hasCache = true
      } catch (Exception e) {
        try {
          copyArtifacts(projectName: 'dashpay-dash/develop', selector: lastSuccessful, filter: "ci-cache-${target}.tar.gz");
          hasCache = true
        } catch (Exception e2) {
        }
      }

      def env = [
        "BUILD_TARGET=${target}",
        "PULL_REQUEST=false",
        "JOB_NUMBER=${BUILD_NUMBER}",
      ]
      withEnv(env) {
        def builderImageName="dash-builder-${target}"

        def builderImage
        stage("${target}/builder-image") {
          builderImage = docker.build("${builderImageName}", "--build-arg BUILD_TARGET=${target} ci -f ci/Dockerfile.builder")
        }

        builderImage.inside("-u root -t -v \"${pwd}/ci-cache-${target}:/cache\"") {
          sh "chown dash:dash /cache"
        }

        builderImage.inside("-t -v \"${pwd}/ci-cache-${target}:/cache\"") {
          try {
            if (hasCache) {
              sh "tar xzfv ci-cache-${target}.tar.gz"
            }

            stage("${target}/depends") {
              sh './ci/build_depends.sh'
            }
            //stage("${target}/build") {
            //  sh './ci/build_src.sh'
            //}
            //stage("${target}/test") {
            //  sh './ci/test_unittests.sh'
            //}
            //stage("${target}/test") {
            //  sh './ci/test_integrationtests.sh'
            //}
            sh "tar czfv ci-cache-${target}.tar.gz ci-cache-${target}"
          } finally {
            // TODO cleanup
          }
        }
        archiveArtifacts artifacts: "ci-cache-${target}.tar.gz", fingerprint: true
      }
    }
  }
}
stage ("Matrix") {
  parallel tasks
}

