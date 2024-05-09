#!/usr/bin/env bash

if ! source functions.sh; then
  echo "Could not source functions.sh. Aborting..."
  exit 1
fi

function install_virt-manager() {
  log_info "Preparing installation of virt-manager"

  log_info "Installing libvirt"
  sudo pacman --sync --refresh --noconfirm libvirt

  log_info "Installing QEMU"
  sudo pacman --sync --refresh --noconfirm qemu-full

  log_info "Configuring libvirt"

  local CURRENT_USER="${USER}"
  log_info "Adding ${CURRENT_USER} to libvirt group"
  sudo usermod --append --groups libvirt "${CURRENT_USER}"

  log_info "Enabling libvirtd daemon"
  sudo systemc enable --now libvirtd.service

  log_info "Enabling libvirtd socket"
  sudo systemc enable --now libvirtd.socket

  log_info "Installing virt-manager"
  sudo pacman --sync --refresh --noconfirm virt-manager

  log_info "Set the UNIX domain socket ownership to libvirt"
  sudo sed -i 's/^#\(unix_sock_group.*\)/\1/' /etc/libvirt/libvirtd.conf

  log_info "Adding ${CURRENT_USER} to /etc/libvirt/qemu.conf"
  TEMP_FILE="$(mktemp)"
  awk -v USER="user = ${CURRENT_USER}" -v GROUP="group = ${CURRENT_USER}" '{
    sub(/^#user = .*/,USER)
    sub(/^#group = .*/,GROUP)
    print
  }' /etc/libvirt/qemu.conf > "${TEMP_FILE}"
  sudo sh -c "cat "${TEMP_FILE}" > /etc/libvirt/qemu.conf"

  log_info "System needs to be rebooted now"
  log_ok "Done"
}
