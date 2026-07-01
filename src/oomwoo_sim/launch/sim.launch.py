"""Launch a drivable oomwoo robot in a walled room in Gazebo (gz-sim / Jetty).

Brings up:
  * gz-sim with the room world
  * robot_state_publisher (xacro -> /robot_description + link TF)
  * the robot, spawned from /robot_description
  * ros_gz_bridge (cmd_vel, odom, tf, scan, joint_states, clock) from the
    description package's config/gz_bridge.yaml
  * optionally rviz2

Drive it with:  ros2 run teleop_twist_keyboard teleop_twist_keyboard   (pixi run teleop)

Launch arguments:
  headless:=true    run gz-sim without its GUI (server only)
  rviz:=true        also start rviz2
  world:=<path>     override the world SDF
"""

import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import (
    AppendEnvironmentVariable,
    DeclareLaunchArgument,
    IncludeLaunchDescription,
    OpaqueFunction,
)
from launch.conditions import IfCondition
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node

import xacro

DESCRIPTION_PKG = "makerspet_mini"  # ROS package name inside src/oomwoo_urdf
BRINGUP_PKG = "oomwoo_sim"


def _setup(context, *args, **kwargs):
    description_share = get_package_share_directory(DESCRIPTION_PKG)
    bringup_share = get_package_share_directory(BRINGUP_PKG)

    headless = LaunchConfiguration("headless").perform(context)
    use_sim_time = LaunchConfiguration("use_sim_time").perform(context)

    world = LaunchConfiguration("world").perform(context)
    if not world:
        world = os.path.join(bringup_share, "worlds", "room.sdf")

    # Process the xacro robot description.
    xacro_file = os.path.join(description_share, "urdf", "robot.urdf.xacro")
    robot_description = xacro.process_file(xacro_file).toxml()

    # Let gz resolve `package://makerspet_mini/...` mesh URIs (the head hemisphere).
    resource_path = os.path.dirname(description_share)  # the `share` dir
    set_resource_path = AppendEnvironmentVariable(
        "GZ_SIM_RESOURCE_PATH", resource_path
    )

    # gz-sim: '-r' runs immediately; '-s' is server-only (headless).
    gz_args = world + " -r -v 3"
    if headless.lower() in ("1", "true", "yes"):
        gz_args += " -s"

    gz_sim = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(
                get_package_share_directory("ros_gz_sim"),
                "launch",
                "gz_sim.launch.py",
            )
        ),
        launch_arguments={"gz_args": gz_args}.items(),
    )

    robot_state_publisher = Node(
        package="robot_state_publisher",
        executable="robot_state_publisher",
        output="screen",
        parameters=[
            {
                "robot_description": robot_description,
                "use_sim_time": use_sim_time.lower() in ("1", "true", "yes"),
            }
        ],
    )

    spawn = Node(
        package="ros_gz_sim",
        executable="create",
        output="screen",
        arguments=[
            "-topic", "robot_description",
            "-name", "oomwoo",
            "-z", "0.02",
        ],
    )

    bridge = Node(
        package="ros_gz_bridge",
        executable="parameter_bridge",
        output="screen",
        parameters=[
            {
                "config_file": os.path.join(
                    description_share, "config", "gz_bridge.yaml"
                ),
                "use_sim_time": use_sim_time.lower() in ("1", "true", "yes"),
            }
        ],
    )

    rviz = Node(
        package="rviz2",
        executable="rviz2",
        output="screen",
        arguments=["-d", os.path.join(description_share, "rviz", "gazebo.rviz")],
        parameters=[{"use_sim_time": use_sim_time.lower() in ("1", "true", "yes")}],
        condition=IfCondition(LaunchConfiguration("rviz")),
    )

    return [set_resource_path, gz_sim, robot_state_publisher, spawn, bridge, rviz]


def generate_launch_description():
    return LaunchDescription(
        [
            DeclareLaunchArgument(
                "headless",
                default_value="false",
                description="Run gz-sim without its GUI (server only).",
            ),
            DeclareLaunchArgument(
                "rviz",
                default_value="false",
                description="Also start rviz2.",
            ),
            DeclareLaunchArgument(
                "use_sim_time",
                default_value="true",
                description="Use the simulation clock.",
            ),
            DeclareLaunchArgument(
                "world",
                default_value="",
                description="Path to a world SDF (defaults to the packaged room).",
            ),
            OpaqueFunction(function=_setup),
        ]
    )
