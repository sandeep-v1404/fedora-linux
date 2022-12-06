#!/bin/bash

main(){
   run
}

run(){
    sudo dnf update
    prompt
}

banner() {
    printf "\n\n\n"
    msg="| $* |"
    edge=$(echo "$msg" | sed 's/./-/g')
    echo "$edge"
    echo "$msg"
    echo "$edge"
}

pause() {
    read -s -n 1 -p "Press any key to continue . . ."
    clear
}

ask_user() {
    msg="$*"
    edge="#~~~~~~~~~~~~#"
    # printf "\n${msg}\n"
    banner "${msg}"

    read -e -p "Press y for yes, n for no (or) q to Quit: " choice

    if [[ "$choice" == "Y" || "$choice" == "y" ]]; then
        printf "\n\n"
        return 0

    elif [[ "$choice" == "N" || "$choice" == "n" ]]; then
        printf "\n\n\n"
        return 1

    elif [[ "$choice" == "Q" || "$choice" == "q" ]]; then
        clear && exit 0

    else
        echo "Please select 1, 2, or 3." && sleep 3
        clear && ask_user ""
    fi
}


prompt(){
    if ask_user "Configure Important Utilities?"; then
        enable_xorg_windowing
        install_rpm_fusion_repo
        fastest_mirror_dnf
        install_google_chrome_stable
        install_brave
        install_applications
        configure_title_bar
        install_nvidia
        # enable_preload
        install_gnome_extensions
        install_vscode
        install_zoom
    else
        printf "\nSkipping...\n"
    fi
    if ask_user "Configure DNF Fastest Mirror?"; then
        fastest_mirror_dnf
    else
        printf "\nSkipping...\n"
    fi
    if ask_user "Configure Git?"; then
        gitsetup
    else
        printf "\nSkipping...\n"
    fi
    if ask_user "Configure ZSH and Theme?"; then
        zsh_config
    else
        printf "\nSkipping...\n"
    fi
}

enable_xorg_windowing() {
    # Find & Replace part contributed by: https://github.com/nanna7077
    clear
    banner "Enable Xorg, Disable Wayland"
    printf "\n\nThe script will change the gdm default file."
    printf "\n\nThe file is: /etc/gdm/custom.conf\n"
    printf "\nIn that file, there will be a line that looks like this:"
    printf "\n\n     #WaylandEnable=false\n\n"
    printf "\nThe script will uncomment that line\n"

    SUBJECT='/etc/gdm/custom.conf'
    SEARCH_FOR='#WaylandEnable=false'
    sudo sed -i "/^$SEARCH_FOR/c\WaylandEnable=false" $SUBJECT
    printf "\n/etc/gdm/custom.conf file changed.\n"

    printf "\n\nGDM config updated. It will be reflected in the next boot.\n\n"
}

install_rpm_fusion_repo(){
    banner "Installing RPM Fusion Repo"
    sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
}

configure_title_bar() {
    banner "Configure Title Bar"
    printf "\e[1;32m\n\nShowing Battery Percentage\e[0m"
    gsettings set org.gnome.desktop.interface show-battery-percentage true

    printf "\e[1;32m\nShow Time in 12 hour format\e[0m"
    gsettings set org.gnome.desktop.interface clock-format 12h

    printf "\e[1;32m\nShow the seconds in Clock\e[0m"
    gsettings set org.gnome.desktop.interface clock-show-seconds true

    printf "\e[1;32m\nShow the Weekday in Clock\n\n\e[0m"
    gsettings set org.gnome.desktop.interface clock-show-weekday true

    printf "\e[1;32m\nAdding Minimize and Maximize buttons on the right\n\n\e[0m"
    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

}

install_applications(){
    banner "Installing vlc, telegram, discord, qbittorrent, htop, obs-studio, xclip, neofetch"

    sudo dnf install vlc telegram-desktop discord qbittorrent htop obs-studio xclip neofetch -y
}

fastest_mirror_dnf(){
    check_dnf_config=`sudo grep fast /etc/dnf/dnf.conf -c`

    if [ $check_dnf_config -ge 1 ]; then
        printf "\n\nDNF Config already updated"
        return 0
    else
        printf "\n\nThis script adds lines to dnf.conf"
        printf "\n\nThe file is: /etc/dnf/dnf.conf\n"
        echo '#Added for speed' | sudo tee -a /etc/dnf/dnf.conf
        echo 'fastestmirror=1' | sudo tee -a /etc/dnf/dnf.conf
        echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
        echo 'defaultyes=True' | sudo tee -a /etc/dnf/dnf.conf
        echo 'keepcache=True' | sudo tee -a /etc/dnf/dnf.conf
    fi
}

install_nvidia(){
    banner "Installing Nvidia Drivers"
    sudo dnf install akmod-nvidia 
    # rhel/centos users can use kmod-nvidia instead
    sudo dnf install xorg-x11-drv-nvidia-cuda
    #optional for cuda/nvdec/nvenc support

    sudo dnf groupupdate core
}

enable_preload(){
    banner "Enabling Preload"
    sudo dnf copr enable elxreno/preload -y && sudo dnf install preload -y
}

install_gnome_extensions(){
    banner "Installing Gnome Extensions"
    sudo dnf install gnome-tweak-tool gnome-extensions-app
}

install_google_chrome_stable() {
    banner "Installing Google Chrome Stable"

    printf "\ninstall the Fedora's workstation repositories:\n"
    sudo dnf install fedora-workstation-repositories -y

    printf "\nEnabling the Google Chrome Repository..\n"
    sudo dnf config-manager --set-enabled google-chrome

    printf "\nDownloading and Installing Google Chrome"
    sudo dnf install google-chrome-stable -y
}

install_brave(){
    sudo dnf install dnf-plugins-core
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    sudo dnf install brave-browser
}

install_vscode(){
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    sudo dnf check-update
    sudo dnf install code
}

install_zoom(){
    check_zoom_installed=`sudo dnf list zoom | grep 'zoom.x86_64' | wc -l`

    if [ $check_zoom_installed -eq 1 ]; then
        printf "\n\nZoom Already Installed"
        return 0
    else
    printf "\n\nDownloading Zoom RPM"
    wget https://zoom.us/client/latest/zoom_x86_64.rpm

    printf "\n\Installing Zoom Application"

    sudo dnf install -y zoom_x86_64.rpm

    printf "\n\n Removing Zoom RPM"
    sudo rm -rf zoom_x86_64.rpm
    fi

  
}

gitsetup() {
    banner "Setting up SSH for git and GitHub"

    read -e -p "Enter your GitHub Username                 : " GITHUB_USERNAME
    read -e -p "Enter the GitHub Email Address             : " GITHUB_EMAIL_ID
    read -e -p "Enter the default git editor (vim / nano)  : " GIT_CLI_EDITOR

    if [[ $GITHUB_EMAIL_ID != "" && $GITHUB_USERNAME != "" && $GIT_CLI_EDITOR != "" ]]; then
        printf "\n - Configuring GitHub username as: ${GITHUB_USERNAME}"
        git config --global user.name "${GITHUB_USERNAME}"

        printf "\n - Configuring GitHub email address as: ${GITHUB_EMAIL_ID}"
        git config --global user.email "${GITHUB_EMAIL_ID}"

        printf "\n - Configuring Default git editor as: ${GIT_CLI_EDITOR}"
        git config --global core.editor "${GIT_CLI_EDITOR}"

        printf "\n - Fast Forwarding All the changes while git pull"
        git config --global pull.ff only

        printf "\n - Generating a new SSH key for ${GITHUB_EMAIL_ID}"
        printf "\n\nJust press Enter and add passphrase if you'd like to. \n\n"
        ssh-keygen -t ed25519 -C "${GITHUB_EMAIL_ID}"

        printf "\n\nAdding your SSH key to the ssh-agent..\n"

        printf "\n - Start the ssh-agent in the background..\n"
        eval "$(ssh-agent -s)"

        printf "\n\n - Adding your SSH private key to the ssh-agent\n\n"
        ssh-add ~/.ssh/id_ed25519

        printf "\n - Copying the SSH Key Content to the Clipboard..."

        printf "\n\nLog in into your GitHub account in the browser (if you have not)"
        printf "\nOpen this link https://github.com/settings/keys in the browser."
        printf "\nClik on New SSH key."
        xclip -selection clipboard <~/.ssh/id_ed25519.pub
        printf "\nGive a title for the SSH key."
        printf "\nPaste the clipboard content in the textarea box below the title."
        printf "\nClick on Add SSH key.\n\n"
        pause
    else
        printf "\nYou have not provided the details correctly for Git Setup."
        if ask_user "Want to try Again ?"; then
            gitsetup
        else
            printf "\nSkipping: Git and GitHub SSH setup..\n"
        fi
    fi
}

zsh_config() {
    if [ $SHELL == "/bin/bash" ]; then
        # option="USER INPUT"
        read -p "Press 1 to Install ZSH, 2 to Uninstall ZSH: " option
        if [ $option == 1 ]; then
            run_zsh
        else
            remove_zsh
        fi
    elif [ $SHELL == "/usr/bin/zsh" ]; then
        # option="USER INPUT"
        printf "\n1: Install ZSH Theme and Auto suggestions\n"
        printf "\n2: Uninstall ZSH\n"
        read -p "Choose 1 or 2: " themeOption
        if [ $themeOption == 1 ]; then
            install_theme
        else
            remove_zsh
        fi
    fi
}

run_zsh() {
    sudo rm -rf /root/.oh-my-zsh
    sudo dnf install zsh util-linux-user -y #zsh package installation
    sleep 2;
    chsh -s $(which zsh)
    sudo sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" # Installing Oh-My-Zsh for customizing ZSH Shell
    
    echo "Exit terminal & Logout of your system. Login Again and Open Terminal. Run the script Again."
}


remove_zsh() {
    sudo rm -rf /root/.oh-my-zsh
    sudo rm -rf "/home/$(id -un)/.oh-my-zsh"
    sudo dnf remove zsh util-linux-user #removing zsh package 
    chsh -s $(which bash)
    echo "Exit terminal nd Reopen it. You will be into default BASH terminal"
}

install_theme(){
    cd ~
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    sudo sed -i '/^ZSH_THEME="robbyrussell"/c\ZSH_THEME="powerlevel10k/powerlevel10k"' .zshrc
    sudo sed -i '/^plugins=(git)/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' .zshrc
}


main

