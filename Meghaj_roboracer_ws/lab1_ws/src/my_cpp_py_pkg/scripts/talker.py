#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from ackermann_msgs.msg import AckermannDriveStamped


class Talker(Node):
    def __init__(self):
        super().__init__('talker')
        self.declare_parameters(
            namespace='',
            parameters=[
                ('v', 0.0),
                ('d', 0.0)
            ]
        )
        self.publisher = self.create_publisher(AckermannDriveStamped, 'drive', 10)
        
    
def main(args=None):
    rclpy.init(args=args)
    talker= Talker()
    while rclpy.ok():
        rclpy.spin_once(talker, timeout_sec=0)
        v= talker.get_parameter('v').value
        d= talker.get_parameter('d').value
        msg = AckermannDriveStamped()
        msg.drive.speed = v
        msg.drive.steering_angle = d
        talker.publisher.publish(msg)
    rclpy.shutdown()

if __name__== '__main__':
    main()   
