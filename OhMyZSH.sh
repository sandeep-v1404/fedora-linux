#!/bin/sh

main() {
    run
}

run() {
    if [ $SHELL == "/bin/bash" ]; then
        # option="USER INPUT"
        printf "\n1: Install ZSH\n"
        printf "\n2: Uninstall ZSH\n"
        read -p "Choose 1 or 2: " option
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
    sudo dnf remove zsh util-linux-user #removing zsh package 
    chsh -s $(which bash)
    echo "Exit terminal nd Reopen it. You will be into default BASH"
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