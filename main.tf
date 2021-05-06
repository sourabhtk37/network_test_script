terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {

  credentials = file("credentials.json")

  project = "tsourab"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "random_id" "instance_id" {
  byte_length = 4
}

resource "google_compute_instance" "test" {
  name                      = "tks-test-net-${var.machine_type}-${var.zone1}-${var.zone2}"
  machine_type              = var.machine_type
  allow_stopping_for_update = "true"
  zone                      = var.zone1

  boot_disk {
    initialize_params {
      image = "rhel-cloud/rhel-8"
    }
  }
  tags = ["uperf"]

  network_interface {
    network = "default"
    access_config {
    }
  }
}


resource "google_compute_instance" "dut" {
  name         = "tks-dut-net-${var.machine_type}-${var.zone1}-${var.zone2}"
  machine_type = var.machine_type
  allow_stopping_for_update = "true"
  zone = var.zone2

  boot_disk {
    initialize_params {
      image = "rhel-cloud/rhel-8"
    }
  }
  tags = ["uperf"]

  network_interface {
    network = "default"
    access_config {
    }
  }
}

data "template_file" "hosts_tpl" {
  template = file("${path.module}/hosts.tpl")
  depends_on = [
    google_compute_instance.test,
    google_compute_instance.dut,
  ]
  vars = {
    test_ip = google_compute_instance.test.network_interface.0.access_config.0.nat_ip
    dut_ip  = google_compute_instance.dut.network_interface.0.access_config.0.nat_ip
  }
}

resource "null_resource" "host_inv" {
  triggers = {
    template_rendered = data.template_file.hosts_tpl.rendered
    always_run        = timestamp()
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.hosts_tpl.rendered}' > hosts-'${random_id.instance_id.hex}'.inv"
  }
}

resource "null_resource" "run-playbook" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts-'${random_id.instance_id.hex}'.inv pbench_agent_install.yml"
  }
  depends_on = [
    google_compute_instance.test,
    google_compute_instance.dut
  ]
}

