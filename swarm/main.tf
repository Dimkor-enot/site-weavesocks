terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "=0.165.0"
    }
  }
}

provider "yandex" {
  token     = "y0__xDFjNypBRjB3RMgiqHL4hNsV1G_B-LZXp4WeVSfuwKphg3UBQ"
  cloud_id  = "b1gr71vus3grjfptc5gc"
  folder_id = "b1gceku20i3recim5psu"
  zone      = "ru-central1-a"
}

module "vm-manager-1" {
  source = "./modules"
  vpc_subnet_id = yandex_vpc_subnet.subnet-1.id
  name_module = "vm-manager-1"
  
}

resource "null_resource" "provision_example" {
  depends_on = [
    module.vm-manager-1,
    module.vm-worker-1,
    module.vm-worker-2
  ]

  connection {
    type        = "ssh"
    user        = "debian" # Пользователь, с которым будет выполнено подключение
    private_key = file("~/.ssh/id_ed25519") # Путь к вашему приватному SSH-ключу
    host        = module.vm-manager-1.external_ip_address_vm
  }

  provisioner "file" {
    source = "~/.ssh/id_ed25519"
    destination = "/home/debian/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ~/.ssh/id_rsa",
      "token=$(sudo docker swarm init | grep 2377)",
      "ssh -o StrictHostKeyChecking=no ${module.vm-worker-1.internal_ip_address_vm} \"sudo $token\"",
      "ssh -o StrictHostKeyChecking=no ${module.vm-worker-2.internal_ip_address_vm} \"sudo $token\"",
      "apt install git",
      "git clone https://github.com/microservices-demo/microservices-demo.git",
      "sed -i '1 s/2/3/' ./microservices-demo/deploy/docker-compose/docker-compose.yml",
      "sudo docker stack deploy -c ./microservices-demo/deploy/docker-compose/docker-compose.yml site"
    ]
  }
}

module "vm-worker-1" {
  source = "./modules"
  vpc_subnet_id = yandex_vpc_subnet.subnet-1.id
  name_module = "vm-worker-1"
  depends_on = [
    module.vm-manager-1
  ]
}

module "vm-worker-2" {
  source = "./modules"
  vpc_subnet_id = yandex_vpc_subnet.subnet-1.id
  name_module = "vm-worker-2"
  depends_on = [
    module.vm-manager-1
  ]
}


resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name			= "subnet1"
  zone 			= "ru-central1-a"
  network_id 		= yandex_vpc_network.network-1.id
  v4_cidr_blocks 	= ["10.5.0.0/24"]
}
