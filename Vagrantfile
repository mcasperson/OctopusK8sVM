# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "generic/ubuntu2204"
  config.vm.box_version = "4.3.12"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Disable the default share of the current code directory. Doing this
  # provides improved isolation between the vagrant box and your host
  # by making sure your Vagrantfile isn't accessible to the vagrant box.
  # If you use this you may want to enable additional shared subfolders as
  # shown above.
  # config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", env: {"OCTOPUS_TEMPK8S_GRPC_HOSTNAME" => ENV['OCTOPUS_TEMPK8S_GRPC_HOSTNAME'], "OCTOPUS_TEMPK8S_POLLING_HOSTNAME" => ENV['OCTOPUS_TEMPK8S_POLLING_HOSTNAME'], "OCTOPUS_TEMPK8S_HOSTNAME" => ENV['OCTOPUS_TEMPK8S_HOSTNAME'], "OCTOPUS_TEMPK8S_SPACE" => ENV['OCTOPUS_TEMPK8S_SPACE'], "OCTOPUS_TEMPK8S_BEARER_TOKEN" => ENV['OCTOPUS_TEMPK8S_BEARER_TOKEN'], "OCTOPUS_TEMPK8S_ACCESS_TOKEN" => ENV['OCTOPUS_TEMPK8S_ACCESS_TOKEN'], "OCTOPUS_TEMPK8S_SPACE_ID" => ENV['OCTOPUS_TEMPK8S_SPACE_ID']}, inline: <<-SHELL
    apt-get update
    apt-get install -y docker.io

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
    chmod 700 get_helm.sh
    ./get_helm.sh

    # For AMD64 / x86_64
    [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind

    kind create cluster

    helm upgrade --install --atomic \
    --timeout 10m0s \
    --wait \
    --repo https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts \
    --namespace kube-system \
    --version "v4.*.*" \
    csi-driver-nfs \
    csi-driver-nfs

    helm upgrade --install --atomic \
    --timeout 20m0s \
    --wait \
    --create-namespace --namespace octopus-agent-kind \
    --version "2.*.*" \
    --set agent.acceptEula="Y" \
    --set agent.space="$OCTOPUS_TEMPK8S_SPACE" \
    --set agent.serverUrl="https://$OCTOPUS_TEMPK8S_HOSTNAME" \
    --set agent.serverCommsAddresses="{https://$OCTOPUS_TEMPK8S_POLLING_HOSTNAME/}" \
    --set agent.bearerToken="${OCTOPUS_TEMPK8S_BEARER_TOKEN}" \
    --set agent.name="Kind" \
    --set agent.deploymentTarget.initial.environments="{development,test,production}" \
    --set agent.deploymentTarget.initial.tags="{Kubernetes}" \
    --set agent.deploymentTarget.enabled="true" \
    --set kubernetesMonitor.enabled="true" \
    --set kubernetesMonitor.registration.serverApiUrl="https://$OCTOPUS_TEMPK8S_HOSTNAME/" \
    --set kubernetesMonitor.monitor.serverGrpcUrl="grpc://$OCTOPUS_TEMPK8S_GRPC_HOSTNAME" \
    --set kubernetesMonitor.registration.serverAccessToken="${OCTOPUS_TEMPK8S_ACCESS_TOKEN}" \
    --set kubernetesMonitor.registration.spaceId="${OCTOPUS_TEMPK8S_SPACE_ID}" \
    --set kubernetesMonitor.registration.machineName="Kind" \
    kind \
    oci://registry-1.docker.io/octopusdeploy/kubernetes-agent

    # Install Argo CD

    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64

    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

    echo "Argo CD initial admin password:"
    PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    echo "$PASSWORD"

    kubectl port-forward svc/argocd-server -n argocd 8080:443 &

    argocd login https://localhost:8080 --username admin --password $PASSWORD

    cat << EOF > argocduser.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
data:
# add an additional local user with apiKey and login capabilities
#   apiKey - allows generating API keys
  accounts.octopus: apiKey
  accounts.octopus.enabled: "true"
EOF

    kubectl apply -f argocduser.yml

    cat << EOF > argocdpolicies.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.csv: |
    p, octopus, applications, get, *, allow
    p, octopus, clusters, get, *, allow
    p, octopus, logs, get, */*, allow
EOF

    kubectl apply -f argocdpolicies.yml
  SHELL
end
