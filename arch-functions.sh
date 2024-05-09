#!/usr/bin/env bash

SCRIPT_NAME="bash-functions"
DATE="$(date +%Y-%m-%d_%H-%M)"
LOG_FILE="logs/${SCRIPT_NAME}_${DATE}.log"

# Logging the entire script and also outputing to terminal
exec 2>&1 >(tee --append "${LOG_FILE}")

if ! source functions.sh; then
  echo "Could not source functions.sh. Aborting..."
  exit 1
fi

function install_virt-manager() {
  log_info "Preparing installation of virt-manager"

  log_info "Installing libvirt"
  exit_on_error sudo pacman --sync --refresh --noconfirm libvirt

  log_info "Installing QEMU"
  exit_on_error sudo pacman --sync --refresh --noconfirm qemu-full

  log_info "Installing tools for networking"
  exit_on_error sudo pacman --remove iptables
  exit_on_error sudo pacman --sync --refresh --noconfirm dnsmasq iptables-nft dmidecode

  log_info "Configuring libvirt"

  local CURRENT_USER="${USER}"
  log_info "Adding ${CURRENT_USER} to libvirt group"
  exit_on_error sudo usermod --append --groups libvirt "${CURRENT_USER}"

  log_info "Enabling libvirtd daemon"
  exit_on_error sudo systemc enable --now libvirtd.service

  log_info "Enabling libvirtd socket"
  exit_on_error sudo systemc enable --now libvirtd.socket

  log_info "Installing virt-manager"
  exit_on_error sudo pacman --sync --refresh --noconfirm virt-manager

  log_info "Set the UNIX domain socket ownership to libvirt"
  exit_on_error sudo sed -i 's/^#\(unix_sock_group.*\)/\1/' /etc/libvirt/libvirtd.conf

  log_info "Adding ${CURRENT_USER} to /etc/libvirt/qemu.conf"
  TEMP_FILE="$(mktemp)"
  awk -v USER="user = \"${CURRENT_USER}\"" -v GROUP="group = \"${CURRENT_USER}\"" '{
    sub(/^#user = .*/,USER)
    sub(/^#group = .*/,GROUP)
    print
  }' /etc/libvirt/qemu.conf > "${TEMP_FILE}"
  sudo sh -c "cat "${TEMP_FILE}" > /etc/libvirt/qemu.conf"

  log_info "System needs to be rebooted now"
  log_ok "Done"
}
