#include "my_cpp_py_pkg/cpp_header.hpp"

class MyNode : public rclcpp::Node
{
public:
    MyNode() : Node("my_node_name") {}

private:
};

int main(int argc, char **argv)
{
    rclcpp::init(argc, argv);
    auto node = std::make_shared<MyNode>();
    rclcpp::spin(node);
    rclcpp::shutdown();
}