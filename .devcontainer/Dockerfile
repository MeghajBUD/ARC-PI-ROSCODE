# Use a stable Ubuntu base (official, always available)
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools and ROS 2 Humble dependencies
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
    && rm -rf /var/lib/apt/lists/*

# Add the ROS 2 apt repository and install the desktop packages
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt-get update && apt-get install -y \
    ros-humble-desktop \    # This includes Gazebo, RViz, and all core tools
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init && rosdep update

# Set up the workspace directory (mounted from the repo)
ARG WORKSPACE=roboracer-purdue
ENV ROS_WS=/workspaces/$WORKSPACE

# Source ROS automatically for the default 'vscode' user (Codespaces user)
RUN echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc \
    && echo "source ${ROS_WS}/install/setup.bash" >> /etc/bash.bashrc

# Create the workspace directory (will be mounted, but ensure it exists)
RUN mkdir -p $ROS_WS/src

# Set the working directory
WORKDIR $ROS_WS

# Reset the frontend to default
ENV DEBIAN_FRONTEND=dialog