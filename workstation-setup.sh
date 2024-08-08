#!/bin/bash

# This script is used to setup a workstation with the necessary tools and packages

# List of layered rpm-ostree packages to remove
declare -a rpm_ostree_packages_remove=(
    "gnome-software-rpm-ostree"
    "gnome-software" 
    "firefox"
    "firefox-langpacks"
)

declare -a rpm_ostree_packages_install=(
    "gnome-tweaks"
    "gnome-themes-extra"
    "papirus-icon-theme"
)

declare -a flatpak_packages_remove=(
    "org.gnome.Calendar"
    "org.gnome.Maps"
    "org.gnome.Weather"
)

declare -a flatpak_packages_install=(
    "com.discordapp.Discord"
    "com.getpostman.Postman"
    "com.mattjakeman.ExtensionManager"
    "com.slack.Slack"
    "com.spotify.Client"
    "com.visualstudio.code"
    "md.obsidian.Obsidian"
    "org.filezillaproject.Filezilla"
    "org.mozilla.Thunderbird"
    "org.signal.Signal"
    "org.videolan.VLC"
    "org.wireshark.Wireshark"
    "com.obsproject.Studio"
    "org.mozilla.firefox"
)

# Add Flathub Repo
echo "Adding Flathub Repo"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Remove Layered Packages
echo "Removing Layered Packages"
sudo rpm-ostree uninstall "${rpm_ostree_packages_remove[@]}"

# Install Layered Packages
echo "Installing Layered Packages"
sudo rpm-ostree install "${rpm_ostree_packages_install[@]}"

# Remove Flatpak Packages
echo "Removing Flatpak Packages"
flatpak uninstall "${flatpak_packages_remove[@]}" -y

# Install Flatpak Packages
echo "Installing Flatpak Packages"
flatpak install flathub "${flatpak_packages_install[@]}" -y

# Extract the flatpak runtime version so that we can install the correct VAAPI
flatpak_runtime=$(flatpak info org.mozilla.firefox --show-runtime | awk -F '/' '{print $NF}')

# Extract the flatpak runtime version so that we can install the correct Remote Podman version
vscode_runtime=$(flatpak info com.visualstudio.code --show-runtime | awk -F '/' '{print $NF}')

# Install the necessary Flatpak Runtimes
echo "Installing Flatpak Runtimes"
flatpak install flathub runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/"$flatpak_runtime" -y
flatpak install flathub runtime/com.visualstudio.code.tool.podman/x86_64/"$vscode_runtime" -y

# Set GNOME settings
echo "Setting GNOME Settings"
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Adwaita
gsettings set org.gnome.desktop.interface icon-theme Papirus
gsettings set org.gnome.desktop.interface cursor-theme Adwaita
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"

sudo rpm-ostree upgrade -y