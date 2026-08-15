# Base on Ubuntu 22.04 (official, always available)
FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system basics, ROS 2 Humble, and VNC components
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    wget \
    vim \
    nano \
    git \
    # VNC and desktop components
    xfce4 \
    xfce4-terminal \
    tightvncserver \
    novnc \
    websockify \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Add ROS 2 apt repository and install the desktop packages
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt-get update && apt-get install -y \
    ros-humble-desktop \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init && rosdep update

# Set up the workspace directory (mounted from the repo)
ARG WORKSPACE=roboracer-purdue
ENV ROS_WS=/workspaces/$WORKSPACE

# Source ROS automatically for all users
RUN echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc \
    && echo "source ${ROS_WS}/install/setup.bash" >> /etc/bash.bashrc

# Create workspace directory (will be mounted)
RUN mkdir -p $ROS_WS/src

# ---- VNC setup ----
# Set VNC password (change if you like)
RUN mkdir -p /root/.vnc && echo "vscode" | vncpasswd -f > /root/.vnc/passwd \
    && chmod 600 /root/.vnc/passwd

# Create a startup script for VNC + noVNC
COPY start-vnc.sh /usr/local/bin/start-vnc.sh
RUN chmod +x /usr/local/bin/start-vnc.sh

# Expose VNC web port
EXPOSE 6080

# Set the working directory
WORKDIR $ROS_WS

ENV DEBIAN_FRONTEND=dialog