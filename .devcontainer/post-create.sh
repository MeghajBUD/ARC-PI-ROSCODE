#!/bin/bash
set -e

# Source ROS 2
source /opt/ros/humble/setup.bash

# Install workspace dependencies using rosdep
cd /workspaces/roboracer-purdue
rosdep install --from-paths src --ignore-src -r -y

# Build the workspace with colcon (ROS 2)
colcon build --symlink-install

# Source the workspace to verify
source install/setup.bash

echo "Workspace built successfully!"