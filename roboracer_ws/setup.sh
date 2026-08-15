#!/usr/bin/env bash
# =============================================================================
#  F1TENTH Sim Template — one-shot setup for Ubuntu 22.04 + ROS 2 Humble
#
#  Usage:
#     git clone <this-repo>
#     cd <this-repo>
#     ./setup.sh
#
#  Installs ROS 2 Humble, the sim dependencies, and the f1tenth_gym backend,
#  then builds the workspace. Assumes a fresh-ish Ubuntu 22.04 (Jammy) desktop.
# =============================================================================
set -euo pipefail

# --- where this script (and the workspace) lives ---
WS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GYM_DIR="${WS_DIR}/f1tenth_gym"          # backend gets cloned here (gitignored)

banner() { echo -e "\n\033[1;34m==> $1\033[0m"; }

# -----------------------------------------------------------------------------
banner "0. Pre-flight checks"
# -----------------------------------------------------------------------------
# must be Ubuntu 22.04
if ! grep -q "22.04" /etc/os-release; then
    echo "WARNING: this script targets Ubuntu 22.04. You appear to be on:"
    grep VERSION= /etc/os-release
    read -p "Continue anyway? [y/N] " ok; [[ "${ok:-N}" == "y" ]] || exit 1
fi
# must NOT be in a conda/venv (ROS uses system python)
if [[ -n "${VIRTUAL_ENV:-}" || -n "${CONDA_DEFAULT_ENV:-}" ]]; then
    echo "ERROR: a virtualenv/conda env is active (${VIRTUAL_ENV:-}${CONDA_DEFAULT_ENV:-})."
    echo "ROS 2 uses system Python. Run 'conda deactivate' / 'deactivate' and retry."
    exit 1
fi
# don't run as root
if [[ "${EUID}" -eq 0 ]]; then echo "ERROR: run as a normal user, not root/sudo."; exit 1; fi

# -----------------------------------------------------------------------------
banner "1. Locale (UTF-8)"
# -----------------------------------------------------------------------------
sudo apt update
sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# -----------------------------------------------------------------------------
banner "2. Add the ROS 2 apt repository (self-updating key package)"
# -----------------------------------------------------------------------------
sudo apt install -y software-properties-common curl
sudo add-apt-repository -y universe
# current official method: the ros2-apt-source deb manages the repo + keys
ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest \
    | grep -F "tag_name" | awk -F'"' '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb \
    "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb

# -----------------------------------------------------------------------------
banner "3. Install ROS 2 Humble + dev tools"
# -----------------------------------------------------------------------------
sudo apt update
sudo apt upgrade -y
sudo apt install -y ros-humble-desktop ros-dev-tools

# -----------------------------------------------------------------------------
banner "4. Install sim system dependencies"
# -----------------------------------------------------------------------------
sudo apt install -y \
    python3-pip git build-essential python3-dev \
    python3-colcon-common-extensions python3-rosdep \
    ros-humble-navigation2 ros-humble-nav2-bringup \
    ros-humble-ackermann-msgs ros-humble-xacro \
    ros-humble-teleop-twist-keyboard

# rosdep (init is one-time; ignore error if already initialized)
sudo rosdep init 2>/dev/null || true
rosdep update

# -----------------------------------------------------------------------------
banner "5. Install the f1tenth_gym Python backend (editable, system Python)"
# -----------------------------------------------------------------------------
if [[ ! -d "${GYM_DIR}" ]]; then
    git clone https://github.com/f1tenth/f1tenth_gym.git "${GYM_DIR}"
else
    echo "f1tenth_gym already present at ${GYM_DIR}, skipping clone."
fi
cd "${GYM_DIR}"
pip3 install -e .

# -----------------------------------------------------------------------------
banner "6. Python dependency fixes (transforms3d + numba/coverage)"
# -----------------------------------------------------------------------------
pip3 install transforms3d
pip3 install --upgrade coverage   # fixes 'module coverage has no attribute types'

# -----------------------------------------------------------------------------
banner "7. Resolve ROS deps + build the workspace"
# -----------------------------------------------------------------------------
cd "${WS_DIR}"
source /opt/ros/humble/setup.bash
rosdep install --from-paths src --ignore-src -r -y || true
rm -rf build install log
colcon build

# -----------------------------------------------------------------------------
banner "8. Persist environment in ~/.bashrc (idempotent)"
# -----------------------------------------------------------------------------
add_line() { grep -qxF "$1" ~/.bashrc || echo "$1" >> ~/.bashrc; }
add_line "source /opt/ros/humble/setup.bash"
add_line "source ${WS_DIR}/install/local_setup.bash"
# VM display fix (RViz hangs without these on most hypervisors)
add_line "export QT_QPA_PLATFORM=xcb"
add_line "export LIBGL_ALWAYS_SOFTWARE=1"

# -----------------------------------------------------------------------------
banner "DONE"
# -----------------------------------------------------------------------------
cat <<MSG

Setup complete. Open a NEW terminal (so ~/.bashrc reloads), then:

  # verify the backend registered on system Python:
  python3 -c "import f110_gym; print('gym OK:', f110_gym.__file__)"

  # launch the sim:
  ros2 launch f1tenth_gym_ros gym_bridge_launch.py

  # drive it (second terminal):
  python3 ${WS_DIR}/scripts/key_drive.py

See docs/ for the full setup guide and the run cheatsheet.
MSG
