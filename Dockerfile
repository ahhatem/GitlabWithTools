FROM centos
RUN yum install -y yum-utils vim
RUN yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
RUN yum -y install terraform
RUN yum -y install epel-release
RUN yum -y install ansible
RUN yum -y install openssh openssh-clients
RUN echo 'export PATH=$PATH:/usr/bin/' >> ~/.bashrc
RUN curl -LJO "https://gitlab-runner-downloads.s3.amazonaws.com/latest/rpm/gitlab-runner_amd64.rpm"
RUN yum -y install gitlab-runner_amd64.rpm
WORKDIR /src
RUN echo -e '#!/bin/bash\n\
    gitlab-runner register -n \
    --url $gitlabURL \
    --registration-token $gitlabToken \
    --executor shell \
    --description "My Runner"\n\
    \n\
    gitlab-runner start;\
    ' > /src/entrypoint.sh
RUN chmod 700 entrypoint.sh
CMD [ "/src/entrypoint.sh" ]