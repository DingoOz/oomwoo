# URDF with Gazebo Simulation (ROS2 package)

URDF (robot definition file) - a simplified URDF with Gazebo simulation,
including a front bumper.

### Assembled vacuum, no top - back
![Teardown reference vacuum - no dock, front](../../assets/vacuum-no-dock-front.webp)

# Request for Contribution - Instructions

- review the [teardown master assembly](https://github.com/remakeai/vacuum_cleaner_teardown/blob/main/step/MASTER-ASSM.stp)
  - measure the robot's outer dimensions, track distance, wheels outer diameter, wheels coordinates, LiDAR coordinates and orientation and so on
- review the [template ROS2 package](https://github.com/makerspet/oomwoo_urdf)
  - I've cloned the template package
  - this package has been tested, should be reused to minimize development
  - modify URDF to match the reference vacuum cleaner
- add a **bumper** to the URDF and simulate it in Gazebo
  - model the conventional **front semi-circular bumper** with **left and right bumper switches**
  - use a Gazebo contact/bumper sensor to publish contact events to ROS2, distinguishing **left vs right** contact
  - keep the bumper geometry and mount consistent with the teardown reference
- review, reproduce [Gazebo Simulation Instructions](https://makerspet.com/blog/tutorial-map-navigate-ros2-robot-in-simulation/)
  - review [development environment setup instructions](https://makerspet.com/blog/build-arduino-self-driving-robot-video-instructions/)
  - use this [oomwoo ROS2 development](https://github.com/makerspet/oomwoo-install) to build oomwoo ROS2 Docker image(s) with your packages
  - or, as a lighter-weight alternative, use the repo's [pixi ROS2 environment](../../docs/pixi-environment.md), which already includes a **working drivable Gazebo sim** to build on: `pixi install && pixi run build`, then `pixi run sim` and `pixi run teleop` (see [docs/pixi-environment.md → Drive the robot](../../docs/pixi-environment.md#drive-the-robot-teleop-simulation)). The robot description and bringup live in `src/oomwoo_urdf` and `src/oomwoo_sim`.
- test it well
  - verify Nav2 SLAM works, does not get stuck in the Living Room world
- submit a PR (pull request) to `contributions/urdf-gazebo-sim/<your-github-username>/`
  - link to ROS2 package(s)
  - instructions, documentation - how to use, assemble, 3D print, troubleshoot, test results
  - photos, videos
  - announce your submission in [Project Discussions](https://github.com/makerspet/oomwoo/discussions?discussions_q=)
- iterate with review
- TBD, expect the RFC to evolve

## Acceptance criteria

Objective, measurable. Examples:
- URDF matches the teardown reference design
- Gazebo simulation works
  - Nav2 SLAM works reliably in the Living Room world
  - map gets saved successfully
  - Nav2 navigation works using a saved map
- bumper works in simulation
  - front semi-circular bumper with left and right switches
  - contact events are published to ROS2 and distinguish left vs right contact
- Documented and reliably reproducible by someone else
- TBD, expect criteria to evolve

The maintainer selects among compliant candidates using these criteria. Multiple
attempts are welcome and useful even if not selected — modules are swappable, and
a non-selected design is still a valid learning exercise and a fallback.
