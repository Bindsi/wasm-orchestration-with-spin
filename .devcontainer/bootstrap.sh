# Installs latest stable toolchain for Rust and clippy/fmt for this toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
PATHRUSTUP=$HOME/.cargo/bin
$PATHRUSTUP/rustup update stable && $PATHRUSTUP/rustup default stable && $PATHRUSTUP/rustup component add clippy rustfmt

# Installs wasm32 compiler targets
$PATHRUSTUP/rustup target add wasm32-wasi wasm32-unknown-unknown

# export path to cargo bin
export PATH="$HOME/.cargo/bin:$PATH"

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install Kubectl
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo mkdir "/etc/apt/keyrings"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Spin
if [ -d "spininstall" ]
then
    echo "Deleting existing spininstall directory..." 
    rm -fr spininstall
fi

mkdir spininstall && cd spininstall
curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash
sudo mv spin /usr/local/bin/
spin plugin install -u https://raw.githubusercontent.com/chrismatteson/spin-plugin-k8s/main/k8s.json --yes
cd ../ && rm -fr spininstall

# Install pip, jg, yq
sudo apt-get install -y pip
sudo apt-get install -y jq
pip install yq

# Install pkg-config
sudo apt-get install -y pkg-config

# Install AKS wasm extensions
az extension add --name aks-preview
az extension update --name aks-preview

# for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
# sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
# curl -fsSL https://get.docker.com -o get-docker.sh
# sudo CHANNEL=test sh get-docker.sh --channel test
# sudo chmod -R 777 /etc/docker
# sudo echo '{"features":{"containerd-snapshotter": true}}' >> /etc/docker/daemon.json
# Install Redis on Local Docker
# docker run -d --name redis-stack -p 6379:6379 -p 8001:8001 redis/redis-stack:latest

# TODO: Move this to workload cluster creation script
# az login
# az feature register --namespace "Microsoft.ContainerService" --name "WasmNodePoolPreview"
# provider_state="unknown"
# while [[ "$provider_state" != "Registered" ]]
# do
#     provider_state=$(az feature show --namespace "Microsoft.ContainerService" --name "WasmNodePoolPreview" --query "properties.state")
#     echo "Provider state: $provider_state"
#     # Todo: exit immediately if provider_state is "Registered"
#     sleep 3
# done
# # Refresh RP registration
# az provider register --namespace Microsoft.ContainerService
