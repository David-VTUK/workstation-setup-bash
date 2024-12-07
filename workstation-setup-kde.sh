#!/bin/bash

# This script is used to setup a workstation with the necessary tools and packages

# List of layered rpm-ostree packages to remove
declare -a rpm_ostree_packages_remove=(
    "firefox"
    "firefox-langpacks"
)

declare -a rpm_ostree_packages_install=(
    "papirus-icon-theme"
    "libva-utils"
)

declare -a flatpak_packages_remove=(
    "org.kde.elisa"
    "org.kde.kmahjongg"
    "org.kde.kmines"
)

declare -a flatpak_packages_install=(
    "com.discordapp.Discord"
    "com.getpostman.Postman"
    "com.slack.Slack"
    "com.spotify.Client"
    "com.visualstudio.code"
    "org.filezillaproject.Filezilla"
    "org.signal.Signal"
    "org.videolan.VLC"
    "org.wireshark.Wireshark"
    "com.obsproject.Studio"
    "org.mozilla.firefox"
    "com.github.tchx84.Flatseal"
)

# Add Flathub Repo
echo "Adding Flathub Repo"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Remove Layered Packages
echo "Removing Layered Packages"
sudo rpm-ostree override remove "${rpm_ostree_packages_remove[@]}"

# Install Layered Packages
echo "Installing Layered Packages"
rpm-ostree install "${rpm_ostree_packages_install[@]}"

# Remove Flatpak Packages
echo "Removing Flatpak Packages"
flatpak uninstall "${flatpak_packages_remove[@]}" -y

# Install Flatpak Packages
echo "Installing Flatpak Packages"
flatpak install flathub "${flatpak_packages_install[@]}" -y

# Extract the Firefox runtime version so that we can install the correct FFmpeg runtime (to match)
flatpak_runtime=$(flatpak info org.mozilla.firefox --show-runtime | awk -F '/' '{print $NF}')

# Extract the VSCode runtime version so that we can install the correct Remote Podman runtime (to match)
vscode_runtime=$(flatpak info com.visualstudio.code --show-runtime | awk -F '/' '{print $NF}')

# Install the necessary Flatpak Runtimes
echo "Installing Flatpak Runtimes"
flatpak install flathub runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/"$flatpak_runtime" -y
flatpak install flathub runtime/com.visualstudio.code.tool.podman/x86_64/"$vscode_runtime" -y

# Set Update OS
sudo rpm-ostree upgrade

# Enable podman socket for vscode
systemctl --user enable podman.socket

# Reboot
systemctl reboot
