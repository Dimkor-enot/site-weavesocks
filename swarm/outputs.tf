output "internal_ip_address_vm_1" {
  value = module.vm-manager-1.internal_ip_address_vm
}

output "external_ip_address_vm_1" {
  value = module.vm-manager-1.external_ip_address_vm
}

#output "internal_ip_address_vm_2" {
#  value = module.vm-worker-1.internal_ip_address_vm
#}

#output "external_ip_address_vm_2" {
#  value = module.vm-worker-1.external_ip_address_vm
#}

#output "internal_ip_address_vm_3" {
#  value = module.vm-worker-2.internal_ip_address_vm
#}

#output "external_ip_address_vm_3" {
#  value = module.vm-worker-2.external_ip_address_vm
#}