output "ip_test" {
  value = google_compute_instance.test.network_interface.0.access_config.0.nat_ip
}

output "ip_dut" {
  value = google_compute_instance.dut.network_interface.0.access_config.0.nat_ip
}