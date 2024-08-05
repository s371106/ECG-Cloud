terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
  cloud = "openstack" # defined in ~/.config/openstack/clouds.yaml
}

variable "count_storage_instances" {
  type = string
}
variable "count_database_instances" {
  type = string
}
variable "count_worker_instances" {
  type = string
}

resource "openstack_compute_instance_v2" "count_instance" {
  count = var.count_worker_instances
  name = "WorkerNode-${count.index}"
  image_name = "Ubuntu-20.04.6-LTS"
  flavor_name = "css.2c4r.10g"
  key_pair = "MasterVMKey"

  network {
    name = "acit"
  }


 
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.access_ip_v4
      agent       = false  # Enable ssh-agent forwarding
      private_key = "${file("~/.ssh/id_rsa")}"  # Path to your private key file
#      host = openstack_compute_instance_v2.install_instance.access_ip_v4
    }
    
    provisioner "remote-exec" {
      inline = [
          "sleep 40",
          "sudo apt -y update",
          "sudo apt install -y python3 python3-pip",
      	  # Install Prometheus
          "wget https://github.com/prometheus/prometheus/releases/download/v2.27.1/prometheus-2.27.1.linux-amd64.tar.gz",
          "tar xvfz prometheus-2.27.1.linux-amd64.tar.gz",
          "sudo cp prometheus-2.27.1.linux-amd64/prometheus /usr/local/bin/",
          "sudo cp prometheus-2.27.1.linux-amd64/promtool /usr/local/bin/",
          "sudo mkdir -p /etc/prometheus",
          "sudo cp -r prometheus-2.27.1.linux-amd64/consoles /etc/prometheus",
          "sudo cp -r prometheus-2.27.1.linux-amd64/console_libraries /etc/prometheus",
          "sudo cp prometheus-2.27.1.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml",
          "sudo useradd --no-create-home --shell /bin/false prometheus",
          "sudo chown -R prometheus:prometheus /etc/prometheus",
          "sudo chmod -R 775 /etc/prometheus",
          "sudo mkdir -p /var/lib/prometheus",
          "sudo chown prometheus:prometheus /var/lib/prometheus",
          # Prometheus systemd service
          "echo '[Unit]' | sudo tee /etc/systemd/system/prometheus.service",
          "echo 'Description=Prometheus' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo '[Service]' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo 'User=prometheus' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo 'ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo '[Install]' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/prometheus.service",
          "sudo systemctl daemon-reload",
          "sudo systemctl start prometheus",
          "sudo systemctl enable prometheus",
          # Install Grafana
          "wget https://dl.grafana.com/oss/release/grafana_7.5.7_amd64.deb",
          "sudo apt-get install -y adduser libfontconfig1",
          "sudo dpkg -i grafana_7.5.7_amd64.deb || sudo apt-get -f install -y",  # Ensure dependencies are handled
          "sudo systemctl daemon-reload",
          "sudo systemctl start grafana-server",
          "sudo systemctl enable grafana-server"
  
    
      ]
    }
  }

resource "openstack_compute_instance_v2" "storage_instances" {
  count = var.count_storage_instances
  name = "Storage-${count.index}"
  image_name = "Ubuntu-20.04.6-LTS"
  flavor_name = "css.2c4r.10g"
  key_pair = "MasterVMKey"

  network {
    name = "acit"
  }


 
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.access_ip_v4
      agent       = false  # Enable ssh-agent forwarding
      private_key = "${file("~/.ssh/id_rsa")}"  # Path to your private key file
#      host = openstack_compute_instance_v2.install_instance.access_ip_v4
    }
    
    provisioner "remote-exec" {
      inline = [
          "sleep 40",
          "sudo apt -y update",
          "sudo apt install -y python3 python3-pip",
      	  # Install Prometheus
          "wget https://github.com/prometheus/prometheus/releases/download/v2.27.1/prometheus-2.27.1.linux-amd64.tar.gz",
          "tar xvfz prometheus-2.27.1.linux-amd64.tar.gz",
          "sudo cp prometheus-2.27.1.linux-amd64/prometheus /usr/local/bin/",
          "sudo cp prometheus-2.27.1.linux-amd64/promtool /usr/local/bin/",
          "sudo mkdir -p /etc/prometheus",
          "sudo cp -r prometheus-2.27.1.linux-amd64/consoles /etc/prometheus",
          "sudo cp -r prometheus-2.27.1.linux-amd64/console_libraries /etc/prometheus",
          "sudo cp prometheus-2.27.1.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml",
          "sudo useradd --no-create-home --shell /bin/false prometheus",
          "sudo chown -R prometheus:prometheus /etc/prometheus",
          "sudo chmod -R 775 /etc/prometheus",
          "sudo mkdir -p /var/lib/prometheus",
          "sudo chown prometheus:prometheus /var/lib/prometheus",
          # Prometheus systemd service
          "echo '[Unit]' | sudo tee /etc/systemd/system/prometheus.service",
          "echo 'Description=Prometheus' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo '[Service]' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo 'User=prometheus' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo 'ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo '[Install]' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/prometheus.service",
          "sudo systemctl daemon-reload",
          "sudo systemctl start prometheus",
          "sudo systemctl enable prometheus",
          # Install Grafana
          "wget https://dl.grafana.com/oss/release/grafana_7.5.7_amd64.deb",
          "sudo apt-get install -y adduser libfontconfig1",
          "sudo dpkg -i grafana_7.5.7_amd64.deb || sudo apt-get -f install -y",  # Ensure dependencies are handled
          "sudo systemctl daemon-reload",
          "sudo systemctl start grafana-server",
          "sudo systemctl enable grafana-server"
  
    
      ]
    }
  }

resource "openstack_compute_instance_v2" "database_instances" {
  count = var.count_database_instances
  name = "database-${count.index}"
  image_name = "Ubuntu-20.04.6-LTS"
  flavor_name = "css.2c4r.10g"
  key_pair = "MasterVMKey"

  network {
    name = "acit"
  }


 
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.access_ip_v4
      agent       = false  # Enable ssh-agent forwarding
      private_key = "${file("~/.ssh/id_rsa")}"  # Path to your private key file
#      host = openstack_compute_instance_v2.install_instance.access_ip_v4
    }
    
    provisioner "remote-exec" {
      inline = [
          "sleep 40",
          "sudo apt -y update",
          "sudo apt install -y python3 python3-pip",
      	  # Install Prometheus
          "wget https://github.com/prometheus/prometheus/releases/download/v2.27.1/prometheus-2.27.1.linux-amd64.tar.gz",
          "tar xvfz prometheus-2.27.1.linux-amd64.tar.gz",
          "sudo cp prometheus-2.27.1.linux-amd64/prometheus /usr/local/bin/",
          "sudo cp prometheus-2.27.1.linux-amd64/promtool /usr/local/bin/",
          "sudo mkdir -p /etc/prometheus",
          "sudo cp -r prometheus-2.27.1.linux-amd64/consoles /etc/prometheus",
          "sudo cp -r prometheus-2.27.1.linux-amd64/console_libraries /etc/prometheus",
          "sudo cp prometheus-2.27.1.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml",
          "sudo useradd --no-create-home --shell /bin/false prometheus",
          "sudo chown -R prometheus:prometheus /etc/prometheus",
          "sudo chmod -R 775 /etc/prometheus",
          "sudo mkdir -p /var/lib/prometheus",
          "sudo chown prometheus:prometheus /var/lib/prometheus",
          # Prometheus systemd service
          "echo '[Unit]' | sudo tee /etc/systemd/system/prometheus.service",
          "echo 'Description=Prometheus' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo '[Service]' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo 'User=prometheus' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo 'ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo '[Install]' | sudo tee -a /etc/systemd/system/prometheus.service",
          "echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/prometheus.service",
          "sudo systemctl daemon-reload",
          "sudo systemctl start prometheus",
          "sudo systemctl enable prometheus",
          # Install Grafana
          "wget https://dl.grafana.com/oss/release/grafana_7.5.7_amd64.deb",
          "sudo apt-get install -y adduser libfontconfig1",
          "sudo dpkg -i grafana_7.5.7_amd64.deb || sudo apt-get -f install -y",  # Ensure dependencies are handled
          "sudo systemctl daemon-reload",
          "sudo systemctl start grafana-server",
          "sudo systemctl enable grafana-server"
  
    
      ]
    }
  }

resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/inventory.txt"
  content = <<-EOT
    [common]
    %{ for index, ip in openstack_compute_instance_v2.storage_instances.*.access_ip_v4 ~}
    storage-target-${index} ansible_host=${ip} ansible_connection=ssh ansible_user=ubuntu
    %{ endfor ~}
    %{ for index, ip in openstack_compute_instance_v2.database_instances.*.access_ip_v4 ~}
    database-target-${index} ansible_host=${ip} ansible_connection=ssh ansible_user=ubuntu
    %{ endfor ~}
    %{ for index, ip in openstack_compute_instance_v2.count_instance.*.access_ip_v4 ~}
    worker-target-${index} ansible_host=${ip} ansible_connection=ssh ansible_user=ubuntu
    %{endfor ~}

    [storage]
    %{ for index, ip in openstack_compute_instance_v2.storage_instances.*.access_ip_v4 ~}
    storage-target-${index} ansible_host=${ip} ansible_connection=ssh ansible_user=ubuntu
    %{ endfor ~}

    [database]
    %{ for index, ip in openstack_compute_instance_v2.database_instances.*.access_ip_v4 ~}
    database-target-${index} ansible_host=${ip} ansible_connection=ssh ansible_user=ubuntu
    %{ endfor ~}

    [worker]
    %{ for index, ip in openstack_compute_instance_v2.count_instance.*.access_ip_v4 ~}
    worker-target-${index} ansible_host=${ip} ansible_connection=ssh ansible_user=ubuntu
    %{endfor ~}
  EOT
}


output "Storage_IPv4" {
  value = openstack_compute_instance_v2.storage_instances.*.access_ip_v4
}
output "Database_IPv4" {
  value = openstack_compute_instance_v2.database_instances.*.access_ip_v4
}
output "Worker_IPv4" {
  value = openstack_compute_instance_v2.count_instance.*.access_ip_v4
}
