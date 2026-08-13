from launch import LaunchDescription
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory
import os

def generate_launch_description():
    config = os.path.join(
        get_package_share_directory('my_cpp_py_pkg'),
        'config',
        'params.yaml'
    )

    talker_node = Node (
        package= 'my_cpp_py_pkg',
        executable= 'talker.py',
        name='talker',
        parameters=[config]
    ) 

    relay_node = Node (
        package= 'my_cpp_py_pkg',
        executable= 'relay.py',
        name='relay'
    ) 

    return LaunchDescription([     
        talker_node,
        relay_node
    ])
