#!/bin/bash

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

#### Create server
kubectl apply -f Kubernetes/1-gitlab.yml

####  Create Runner
# Build image
docker build -t ahhatem/gitlabrunner .
# Get gitlab token
export gitlabPodName=`kubectl get pods | egrep -o  '(^gitlab[^ ]*) '`
until $(curl --output /dev/null --silent --head --fail http://localhost); do
  printf '.'
  sleep 5
done
export gitlabToken=`kubectl exec $gitlabPodName -- gitlab-rails runner -e production "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token"`
echo gitlabToken= $gitlabToken
# Create runner pod
cat Kubernetes/2-gitlabRunner.yml | envsubst | kubectl apply -f -

kubectl exec $gitlabPodName -- grep 'Password:' /etc/gitlab/initial_root_password
