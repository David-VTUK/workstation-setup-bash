#!/bin/bash

# This script is used to setup a workstation with the necessary tools and packages

# List of layered rpm-ostree packages to remove
declare -a rpm-ostree-packages-remove=(
    "gnome-software" 
    "gnome-software-rpm-ostree" 
    "firefox"
    "firefox-langpacks"
)

declare -a rpm-ostree-packages-install=(
    "gnome-tweaks"
    "gnome-themes-extra"
    "papirus-icon-theme"
)

declare -a flatpak-packages-remove=(
    "org.gnome.Calendar"
    "org.gnome.Maps"
    "org.gnome.Weather"
)

declare -a flatpak-packages-install=(
    "com.discordapp.Discord"
    "com.getpostman.Postman"
    "com.mattjakeman.ExtensionManager"
    "org.gnome.Extensions"
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

# Remove Layered Packages
echo "Removing Layered Packages"
rpm-ostree uninstall "${rpm-ostree-packages-remove[@]}"

# Install Layered Packages
echo "Installing Layered Packages"
rpm-ostree install "${rpm-ostree-packages-install[@]}"

# Remove Flatpak Packages
echo "Removing Flatpak Packages"
flatpak uninstall "${flatpak-packages-remove[@]}" -y

# Add Flathub Repo
echo "Adding Flathub Repo"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Flatpak Packages
echo "Installing Flatpak Packages"
flatpak install flathub "${flatpak-packages-install[@]}" -y

# Extract the flatpak runtime version so that we can install the correct VAAPI
flatpak_runtime=$(flatpak info org.mozilla.firefox --show-runtime | awk -F '/' '{print $NF}')

# Extract the flatpak runtime version so that we can install the correct Remote Podman version
vscode_runtime=$(flatpak info com.visualstudio.code --show-runtime | awk -F '/' '{print $NF}')

# Install the necessary Flatpak Runtimes
echo "Installing Flatpak Runtimes"
flatpak install flathub org.freedesktop.Platform.ffmpeg-full/"$flatpak_runtime" runtime/com.visualstudio.code.tool.podman/x86_64/"$vscode_runtime" -y

# Set GNOME settings
echo "Setting GNOME Settings"
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Adwaita
gsettings set org.gnome.desktop.interface icon-theme Papirus
gsettings set org.gnome.desktop.interface cursor-theme Adwaita
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"