#!/bin/bash
set -e

# Source ROS 2 (if not already sourced)
source /opt/ros/humble/setup.bash

# Go to the workspace
cd /workspaces/roboracer-purdue

# Install any dependencies declared in your package.xml files
rosdep install --from-paths src --ignore-src -r -y

# Build the workspace with colcon (ROS 2)
colcon build --symlink-install

# Source the workspace to verify
source install/setup.bash

echo "Workspace built successfully!"