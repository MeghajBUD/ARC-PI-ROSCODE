FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal tools (curl is needed to add the ROS repo)
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg2 \
    lsb-release \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add ROS 2 repository (curl is now available)
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install all packages (ROS, VNC, dev tools)
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    vim \
    nano \
    git \
    xfce4 \
    xfce4-terminal \
    tightvncserver \
    novnc \
    websockify \
    supervisor \
    ros-humble-desktop \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init && rosdep update

# Set up workspace
ARG WORKSPACE=roboracer-purdue
ENV ROS_WS=/workspaces/$WORKSPACE
RUN mkdir -p $ROS_WS/src

# Source ROS automatically in bash
RUN echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc && \
    echo "source ${ROS_WS}/install/setup.bash" >> /etc/bash.bashrc

# VNC setup
COPY start-vnc.sh /usr/local/bin/start-vnc.sh
RUN chmod +x /usr/local/bin/start-vnc.sh && \
    mkdir -p /root/.vnc && echo "vscode" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

EXPOSE 6080
WORKDIR $ROS_WS
ENV DEBIAN_FRONTEND=dialog