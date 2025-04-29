
resource "yandex_loadtesting_agent" "my-agent" {
  name        = "my-agent"
  description = "2 core 4 GB RAM agent"
  folder_id   = var.folder_id
  labels = {
    jmeter = "5"
  }

  compute_instance {
    zone_id            = var.zone
    service_account_id = var.service_account_id
    resources {
      cores  = 2
      memory = 4
    }
    boot_disk {
      initialize_params {
        size = var.bootdisk_size
      }
      auto_delete = true
    }
    network_interface {
      subnet_id = var.subnet_id
      nat       = true
    }
  }
}

//----------------------------------------------------

resource "yandex_compute_instance" "vm-1" {
  name = "pg1"

  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id1
      size = var.bootdisk_size
    }
  }
  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }
  metadata = {
    user-data = "${file("metadata1.yaml")}"
  }
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("id_rsa")
    host        = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
  }
}

//----------------------------------------------------

resource "yandex_compute_instance" "vm-2" {
  name = "pg2"

  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id2
      size = var.bootdisk_size
    }
  }
  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }
  metadata = {
    user-data = "${file("metadata2.yaml")}"
  }
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("id_rsa")
    host        = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
  }
}
