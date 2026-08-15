#!/bin/bash
set -e

# Source ROS setup
source /opt/ros/${ROS_DISTRO:-noetic}/setup.bash

# Install workspace dependencies using rosdep
cd /workspaces/roboracer-purdue
rosdep install --from-paths src --ignore-src -r -y

# Build the workspace (choose the appropriate build tool)
# For catkin (ROS1):
catkin_make
# For catkin_tools:
# catkin build
# For colcon (ROS2):
# colcon build

# Source the workspace to verify
source devel/setup.bash   # for catkin
# source install/setup.bash   for colcon

echo "Workspace built successfully!"