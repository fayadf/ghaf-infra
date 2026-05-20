#!/usr/bin/env groovy

@Library('ghafInfra') _

def DEFAULT_REPO_URL = 'https://github.com/tiiuae/ghaf/'
def WORKDIR  = 'checkout'
def PIPELINE = [:]

properties([
  githubProjectProperty(displayName: ''),
  parameters([
    booleanParam(name: 'UEFISIGN', defaultValue: false, description: 'Enable secure boot signing (for supported targets)'),
    booleanParam(name: 'SECUREBOOT', defaultValue: false, description: 'Run tests also on secureboot enabled hardware, if available'),
    string(name: 'REPO_URL', defaultValue: DEFAULT_REPO_URL, description: 'Git repository URL'),
    string(name: 'GITREF', defaultValue: 'main', description: 'Ghaf git reference (Commit/Branch/Tag)'),
    string(name: 'TESTSET', defaultValue: null, description: 'By default tests are skipped. To run hw-tests, define the target testset here; e.g.: _relayboot_, _relayboot_bat_, _relayboot_pre-merge_, etc.)'),
    string(name: 'TESTAGENT_HOST', defaultValue: 'dev', description: 'Target testagent host, e.g.: dev, prod, release'),
    booleanParam(name: 'nvidia_jetson_orin_agx_debug', defaultValue: false, description: 'Build target packages.aarch64-linux.nvidia-jetson-orin-agx-debug'),
    booleanParam(name: 'nvidia_jetson_orin_nx_debug', defaultValue: false, description: 'Build target packages.aarch64-linux.nvidia-jetson-orin-nx-debug'),
 ])
])
pipeline {
  agent { label 'built-in' }
  options {
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }
  stages {
    stage('Reload only') {
      when { expression { params && params.RELOAD_ONLY } }
      steps {
        script {
          currentBuild.result = 'ABORTED'
          currentBuild.displayName = "Reloaded pipeline"
          error('Reloading pipeline - aborting other stages')
        }
      }
    }
    stage('Checkout') {
      steps {
        dir(WORKDIR) {
          deleteDir()
          checkout scmGit(
            branches: [[name: params.GITREF]],
            userRemoteConfigs: [[url: params.REPO_URL]]
          )
        }
      }
    }
    stage('Setup') {
      steps {
        dir(WORKDIR) {
          script {
            def TARGETS = []
            if (params.nvidia_jetson_orin_agx_debug) {
              TARGETS.push(
                [ target: "packages.aarch64-linux.nvidia-jetson-orin-agx-debug", uefisign: params.UEFISIGN, testset: params.TESTSET, testagent_host: "dev" ])
            }
            if (params.nvidia_jetson_orin_nx_debug) {
              TARGETS.push(
                [ target: "packages.aarch64-linux.nvidia-jetson-orin-nx-debug", uefisign: params.UEFISIGN, testset: params.TESTSET, testagent_host: "dev" ])
            }

            PIPELINE = utils.create_pipeline(TARGETS)
          }
        }
      }
    }
    stage('Build') {
      steps {
        dir(WORKDIR) {
          script {
            parallel PIPELINE
          }
        }
      }
    }
  }
}
