#!/usr/bin/env bash

SCRIPT_NAME="arch-functions"
DATE="$(date +%Y-%m-%d_%H-%M)"
LOG_FILE="logs/${SCRIPT_NAME}_${DATE}.log"

# Logging the entire script and also outputing to terminal
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3 RETURN
exec 1>"${LOG_FILE}" 2>&1

if ! source functions.sh; then
  echo "Could not source functions.sh. Aborting..."
  return 1
fi

function install_virt-manager() {
  local RETURN_VALUE=0
  log_info "Preparing installation of virt-manager"

  log_info "Installing libvirt"
  sudo pacman --sync --refresh --noconfirm libvirt || RETURN_VALUE=1

  log_info "Installing QEMU"
  sudo pacman --sync --refresh --noconfirm qemu-full || RETURN_VALUE=1

  log_info "Installing tools for networking"
  sudo pacman --remove iptables || RETURN_VALUE=1
  sudo pacman --sync --refresh --noconfirm dnsmasq iptables-nft dmidecode || RETURN_VALUE=1

  log_info "Configuring libvirt"

  local CURRENT_USER="${USER}"
  log_info "Adding ${CURRENT_USER} to libvirt group"
  sudo usermod --append --groups libvirt "${CURRENT_USER}" || RETURN_VALUE=1

  log_info "Enabling libvirtd daemon"
  sudo systemc enable --now libvirtd.service || RETURN_VALUE=1

  log_info "Enabling libvirtd socket"
  sudo systemc enable --now libvirtd.socket || RETURN_VALUE=1

  log_info "Installing virt-manager"
  sudo pacman --sync --refresh --noconfirm virt-manager || RETURN_VALUE=1

  log_info "Set the UNIX domain socket ownership to libvirt"
  sudo sed -i 's/^#\(unix_sock_group.*\)/\1/' /etc/libvirt/libvirtd.conf || RETURN_VALUE=1

  log_info "Adding ${CURRENT_USER} to /etc/libvirt/qemu.conf"
  TEMP_FILE="$(mktemp)"
  awk -v USER="user = \"${CURRENT_USER}\"" -v GROUP="group = \"${CURRENT_USER}\"" '{
    sub(/^#user = .*/,USER)
    sub(/^#group = .*/,GROUP)
    print
  }' /etc/libvirt/qemu.conf > "${TEMP_FILE}"
  sudo sh -c "cat ${TEMP_FILE} > /etc/libvirt/qemu.conf"

  log_info "System needs to be rebooted now"
  log_ok "Done"

  return RETURN_VALUE
}
