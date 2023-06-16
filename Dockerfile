# My unified Infrastructure as Code container image - a container which
# has Terraform, Packer & Ansible installed.

# Owes a debt to https://github.com/geektechdude/ansible_container/blob/master/Dockerfile

FROM ubuntu:kinetic

USER root

# Set some Ansible defaults

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING False
ENV ANSIBLE_RETRY_FILES_ENABLED False
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV ANSIBLE_STDOUT_CALLBACK debug

# Install Ansible, Terraform and Packer in the recommended ways

RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive \
                apt-get install -y \
                    apt-transport-https \
                    ca-certificates \
                    curl \
                    git \
                    gnupg \
                    lsb-release \
                    software-properties-common \
                    xorriso \
                    wget
ADD ansible.list /etc/apt/sources.list.d/ansible.list
RUN APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
    wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        tee /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt install -y ansible packer terraform && \
    apt-get clean all

# Add Ansible galaxy packages

ADD ansible.cfg /etc/ansible/ansible.cfg
RUN mkdir -p /ansible_collections && chmod 777 /ansible_collections
RUN ansible-galaxy collection install ansible.posix community.crypto community.general pfsensible.core
