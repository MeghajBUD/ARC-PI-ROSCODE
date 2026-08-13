#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from ackermann_msgs.msg import AckermannDriveStamped


class Relay(Node):
    def __init__(self):
        super().__init__('relay')
        self.subscription = self.create_subscription(AckermannDriveStamped, 'drive', self.relay_callback,10)
        self.publisher = self.create_publisher(AckermannDriveStamped, 'drive_relay', 10)

    def relay_callback(self, msg):
        new_msg = AckermannDriveStamped()
        new_msg.drive.speed = msg.drive.speed * 3 
        new_msg.drive.steering_angle = msg.drive.steering_angle * 3
        self.publisher.publish(new_msg)

    
def main(args=None):
    rclpy.init(args=args)
    relay= Relay()
    rclpy.spin(relay)
    rclpy.shutdown()

if __name__== '__main__':
    main()   
