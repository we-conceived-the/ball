// This Jenkinsfile will build a builder image and then run the actual build and tests inside this image
// It's very important to not execute any scripts outside of the builder container, as it's our protection against
// external developers bringing in harmful code into Jenkins.
// Jenkins will only run the build if this Jenkinsfile was not modified in an external pull request. Only branches
// which are part of the Dash repo will allow modification to the Jenkinsfile.

node {
  def targets = [
    'win32',
    'win64',
    'linux32',
    'linux64',
    'linux64_nowallet',
    'linux64_release',
    'mac',
  ]

  def tasks = [:]
  for(int i = 0; i < targets.size(); i++) {
    def target = targets[i]

    tasks["${target}"] = {
      node {
        checkout scm

        def BUILD_NUMBER = sh(returnStdout: true, script: 'echo $BUILD_NUMBER').trim()
        def UID = sh(returnStdout: true, script: 'id -u').trim()

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

          builderImage.inside("-u root -t -v \"$HOME/dash-ci-cache-${target}:/cache\"") {
            sh "chown dash:dash /cache"
          }

          builderImage.inside("-t -v \"$HOME/dash-ci-cache-${target}:/cache\"") {
            try {
              stage("${target}/depends") {
                sh './ci/build_depends_in_builder.sh'
              }
              stage("${target}/build") {
                sh './ci/build_src_in_builder.sh'
              }
              stage("${target}/test") {
                sh './ci/test_unittests_in_builder.sh'
              }
              stage("${target}/test") {
                sh './ci/test_integrationtests_in_builder.sh'
              }
            } finally {
              // TODO cleanup
            }
          }
        }
      }
    }
  }
  stage ("Matrix") {
    parallel tasks
  }
}
