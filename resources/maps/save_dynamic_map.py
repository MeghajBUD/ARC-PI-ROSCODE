#!/usr/bin/env python3
import os
import yaml
import math
import rclpy
from rclpy.node import Node

from nav_msgs.srv import GetMap  # service type for /slam_toolbox/dynamic_map


def quat_to_yaw(qx, qy, qz, qw) -> float:
    # yaw from quaternion (assuming planar motion)
    siny_cosp = 2.0 * (qw * qz + qx * qy)
    cosy_cosp = 1.0 - 2.0 * (qy * qy + qz * qz)
    return math.atan2(siny_cosp, cosy_cosp)


class DynamicMapSaver(Node):
    def __init__(self, out_prefix: str, service_name: str):
        super().__init__("dynamic_map_saver")
        self.out_prefix = out_prefix
        self.cli = self.create_client(GetMap, service_name)
        self.service_name = service_name

    def run(self):
        if not self.cli.wait_for_service(timeout_sec=5.0):
            raise RuntimeError(f"Service not available: {self.service_name}")

        req = GetMap.Request()
        future = self.cli.call_async(req)
        rclpy.spin_until_future_complete(self, future, timeout_sec=10.0)
        if not future.done() or future.result() is None:
            raise RuntimeError("Failed to get map from service (timeout or no result)")

        occ = future.result().map  # nav_msgs/OccupancyGrid
        self.save_occ_grid(occ)

    def save_occ_grid(self, occ):
        # Save PGM (P5) + YAML compatible with map_server
        info = occ.info
        w, h = info.width, info.height
        data = list(occ.data)  # int8 [-1,100]

        pgm_path = f"{self.out_prefix}.pgm"
        yaml_path = f"{self.out_prefix}.yaml"

        # Map convention: 0=free (white), 100=occupied (black), -1=unknown (gray)
        # Common pgm mapping:
        #   occupied -> 0
        #   free -> 254/255
        #   unknown -> 205
        def to_pixel(v):
            if v < 0:
                return 205
            # clamp 0..100 then invert
            v = max(0, min(100, v))
            return int(round(254 * (100 - v) / 100.0))

        pixels = bytes([to_pixel(v) for v in data])

        # Write PGM
        with open(pgm_path, "wb") as f:
            f.write(f"P5\n{w} {h}\n255\n".encode("ascii"))
            f.write(pixels)

        yaw = quat_to_yaw(
            info.origin.orientation.x,
            info.origin.orientation.y,
            info.origin.orientation.z,
            info.origin.orientation.w,
        )

        meta = {
            "image": os.path.basename(pgm_path),
            "mode": "trinary",
            "resolution": float(info.resolution),
            "origin": [float(info.origin.position.x), float(info.origin.position.y), float(yaw)],
            "negate": 0,
            "occupied_thresh": 0.65,
            "free_thresh": 0.25,
        }

        with open(yaml_path, "w") as f:
            yaml.safe_dump(meta, f, default_flow_style=False)

        self.get_logger().info(f"Saved: {pgm_path}")
        self.get_logger().info(f"Saved: {yaml_path}")


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", default="hallway_map", help="Output prefix (no extension)")
    parser.add_argument("--service", default="/slam_toolbox/dynamic_map", help="GetMap service name")
    args = parser.parse_args()

    rclpy.init()
    node = DynamicMapSaver(args.out, args.service)
    try:
        node.run()
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()
