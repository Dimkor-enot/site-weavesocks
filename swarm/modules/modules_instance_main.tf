terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "=0.165.0"
    }
  }
}
data "yandex_compute_image" "my_image" {
  family = var.instance_family_image
}

resource "yandex_compute_instance" "vm" {
  name = "terraform-${var.name_module}"
  hostname = "${var.name_module}"
  resources {
    core_fraction = 20
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_image.id
    }
  }

  network_interface {
    subnet_id = var.vpc_subnet_id
    nat = true
  }

  metadata = {
    ssh-keys = "debian:${file("~/.ssh/id_ed25519.pub")}"
  }

  # Настройки подключения по SSH (пример)
  connection {
    type        = "ssh"
    user        = "debian" # Пользователь, с которым будет выполнено подключение
    private_key = file("~/.ssh/id_ed25519") # Путь к вашему приватному SSH-ключу
    host        = self.network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y docker-compose"
    ]

    
  }
  
}