# Use an official ROS image. Choose the correct ROS distro!
# Common options: noetic (ROS1), foxy/humble (ROS2)
ARG ROS_DISTRO=humble
FROM ros:${ROS_DISTRO}-desktop-full

# Avoid interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies commonly needed for simulation
RUN apt-get update && apt-get install -y \
    git \
    python3-pip \
    python3-catkin-tools \
    python3-rosdep \
    python3-vcstool \
    wget \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep and update
RUN rosdep init && rosdep update

# Set up the workspace directory (this will be mounted from the repo)
ARG WORKSPACE=roboracer-purdue
ENV ROS_WS=/workspaces/$WORKSPACE

# (Optional) If you have additional dependencies in a .rosinstall file,
# you could use vcstool to import them here. But we'll do it in post-create.

# Set the entrypoint to source ROS automatically
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/ros/.bashrc
RUN echo "source ${ROS_WS}/devel/setup.bash" >> /home/ros/.bashrc   # For catkin
# If using colcon (ROS2): source install/setup.bash

# Switch to the 'ros' user (created by base image)
USER ros
WORKDIR $ROS_WS

# Set back to non-interactive
ENV DEBIAN_FRONTEND=dialog