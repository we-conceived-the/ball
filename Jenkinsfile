node {
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
        sh "BUILD_NUMBER=${BUILD_NUMBER}"

        def env = [
          "BUILD_TARGET=${target}",
          "PULL_REQUEST=false",
          "JOB_NUMBER=${BUILD_NUMBER}",
        ]
        withEnv(env) {
          def builderImageName="dash-builder-${target}-${BUILD_NUMBER}"

          stage("${target}/checkout") {
            node {
              checkout scm
            }
          }

          def builderImage
          stage("${target}/builder-image") {
            builderImage = docker.build("${builderImageName}", "ci -f ci/Dockerfile.builder --build-arg USER_ID=${env.UID} --build-arg GROUP_ID=${env.UID}")
          }

          builderImage.inside("-u ${env.UID} -t -v $HOME/dash-ci-cache-${target}:/cache") {
            try {
              stage("${target}/depends") {
                sh 'pwd && ls -lah'
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
