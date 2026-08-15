# Use a valid ROS 2 Humble image
ARG ROS_DISTRO=humble
FROM ros:${ROS_DISTRO}-desktop   # <-- 'desktop' includes Gazebo and RViz

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies (common for simulation)
RUN apt-get update && apt-get install -y \
    git \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    wget \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep and update
RUN rosdep init && rosdep update

# Set up the workspace directory
ARG WORKSPACE=roboracer-purdue
ENV ROS_WS=/workspaces/$WORKSPACE

# Source ROS automatically in bash
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/ros/.bashrc
# For ROS2, we source the install folder (after building)
RUN echo "source ${ROS_WS}/install/setup.bash" >> /home/ros/.bashrc

# Switch to the 'ros' user (created by base image)
USER ros
WORKDIR $ROS_WS

ENV DEBIAN_FRONTEND=dialog