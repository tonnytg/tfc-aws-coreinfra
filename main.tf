provider "aws" {
  region = "us-east-1"
}

resource "aws_lightsail_instance" "main" {
  name              = "k8s-debian-instance"
  availability_zone = "us-east-1a"
  blueprint_id      = "debian_12"  # Confirme se este ID está correto via AWS CLI
  bundle_id         = "small_3_0"  # Confirme as specs: 2 vCPUs, 2GB RAM, 60GB SSD, 3TB
  key_pair_name     = "aws_key_pair_virginia"

  user_data = <<-EOF
              #!/bin/bash
              echo "[INFO] Atualizando pacotes..."
              sudo apt update

              echo "[INFO] Instalando pacotes essenciais..."
              sudo apt install -y vim curl htop apt-transport-https ca-certificates gnupg lsb-release

              echo "[INFO] Adicionando chave do repositório Kubernetes..."
              curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /etc/apt/trusted.gpg.d/kubernetes.asc

              echo "[INFO] Adicionando repositório Kubernetes..."
              echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
              
              echo "[INFO] Instalando kubeadm, kubelet e kubectl..."
              sudo apt update && sudo apt install -y kubelet kubeadm kubectl
              sudo systemctl enable kubelet

              echo "[INFO] Desativando swap (requerido pelo Kubernetes)..."
              sudo swapoff -a
              sudo sed -i '/swap/d' /etc/fstab

              echo "[INFO] Inicializando o cluster Kubernetes..."
              sudo kubeadm init --pod-network-cidr=192.168.0.0/16

              echo "[INFO] Configurando o acesso ao cluster..."
              mkdir -p $HOME/.kube
              sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
              sudo chown $(id -u):$(id -g) $HOME/.kube/config

              echo "[INFO] Aplicando o Calico CNI..."
              kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

              echo "[INFO] Kubernetes instalado com sucesso!"
              EOF

  tags = {
    Environment = "development"
  }
}

