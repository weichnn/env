#!/bin/bash

echo "------------------------"
echo "./dev env init.sh"
echo "------------------------"

function cecho() {
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[1;33m"
    # ... ADD MORE COLORS
    NC="\033[0m" # No Color

    printf "${!1}${2} ${NC}\n"
}

# read -p "Do you want to use Mirror [yes/no]?: " useMirror
useMirror="no"
if [[ $useMirror == "yes" ]]; then
    sudo sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
fi

sudo add-apt-repository ppa:obsproject/obs-studio
sudo apt update
sudo apt install vim git openssh-server terminator ffmpeg obs-studio python3-pip mtr lm-sensors hddtemp libopencv-dev 

cecho YELLOW "installing vs-code"
sudo snap install --classic code

# cecho YELLOW "installing chrome"
# wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# sudo dpkg -i google-chrome-stable_current_amd64.deb

# cecho YELLOW "installing cloud music"
# http://d1.music.126.net/dmusic/netease-cloud-music_1.2.1_amd64_ubuntu_20190428.deb
# sudo dpkg -i netease-cloud-music_1.2.1_amd64_ubuntu_20190428.deb

if [[ ! -f "/home/$USER/.ssh/id_rsa" ]]; then
    cecho YELLOW "configing ssh key"
    read -p "input your email for ssh_key and git: " email
    ssh-keygen -t ed25519 -C $email
    cp ~/.ssh/id_ed25519.pub ~/
# ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

    cecho YELLOW "configure your git"
    read -p "input your name for git: " name
    git config --global user.name $name
    git config --global user.email $email
fi

read -p "Do you want to install ROS [yes/no]?: " InstallROS
read -p "the version of Ubuntu [16/18/20]?: " UbVer
if [[ $InstallROS == "yes" ]]; then
    cecho YELLOW "installing ROS"
    if [[ $useMirror == "yes" ]]; then
        sudo sh -c '. /etc/lsb-release && echo "deb http://mirrors.ustc.edu.cn/ros/ubuntu/ `lsb_release -cs` main" > /etc/apt/sources.list.d/ros-latest.list'
    else
        sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    fi

    sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
    sudo apt update

    if [[ $UbVer == "20" ]]; then
        sudo apt install ros-noetic-desktop-full
        echo "source /opt/ros/noetic/setup.bash" >>~/.bashrc
    fi

    if [[ $UbVer == "18" ]]; then
        sudo apt install ros-melodic-desktop-full
        echo "source /opt/ros/melodic/setup.bash" >>~/.bashrc
        sudo apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
        sudo apt install python-rosdep
        sudo rosdep init
        rosdep update
    fi

    if [[ $UbVer == "16" ]]; then
        sudo apt-get install ros-kinetic-desktop-full
        echo "source /opt/ros/kinetic/setup.bash" >>~/.bashrc
        sudo apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
        sudo apt install python-rosdep
        sudo rosdep init
        rosdep update
    fi

    source ~/.bashrc
fi

# read -p "Do you want to install Zsh [yes/no]?: " useZsh
useZsh="no"
if [[ $useZsh == "yes" ]]; then
    cecho YELLOW "installing Zsh"
    sudo apt install zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    if [[ $InstallROS == "yes" ]]; then

        if [[ $UbVer == "20" ]]; then
            echo "source /opt/ros/noetic/setup.zsh" >>~/.zshrc
        fi

        if [[ $UbVer == "18" ]]; then
            echo "source /opt/ros/melodic/setup.zsh" >>~/.zshrc
        fi

        if [[ $UbVer == "16" ]]; then
            echo "source /opt/ros/kinetic/setup.zsh" >>~/.zshrc
        fi
        source ~/.zshrc
    fi
fi
