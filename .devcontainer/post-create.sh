#!/bin/bash
set -e
source /opt/ros/humble/setup.bash
cd /workspaces/roboracer-purdue
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install
source install/setup.bash
echo "Workspace built successfully!"