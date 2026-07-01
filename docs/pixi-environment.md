# Reproducible ROS2 dev environment with pixi

This repo ships a [pixi](https://pixi.sh) manifest (`pixi.toml` at the repo root) that
gives you a fully reproducible **ROS2 Lyrical Luth** + **Gazebo** toolchain, pinned by
`pixi.lock`. Everyone who runs `pixi install` gets the byte-for-byte same environment —
no system ROS install, no `apt`, no Docker.

> **This is an alternative, not a replacement.** The Docker-based setup in the separate
> [`makerspet/oomwoo-install`](https://github.com/makerspet/oomwoo-install) repo still works
> and remains the reference path (and is what the `urdf-gazebo-sim` RFC points to). Pixi is a
> lighter-weight local option — pick whichever suits you.

The ROS2 packages come from [RoboStack](https://robostack.github.io), which repackages ROS2
for the conda ecosystem.

## Supported platforms

The lockfile resolves for:

| Platform        | Target                                  |
|-----------------|-----------------------------------------|
| `linux-64`      | Standard x86_64 Linux dev machines      |
| `linux-aarch64` | 64-bit ARM — the Raspberry Pi 5 (MVP compute board) |
| `osx-arm64`     | Apple Silicon macOS                     |

> Note: some ROS/Gazebo packages have gaps on macOS; Linux is the most complete target.
> On a Raspberry Pi 5, use a 64-bit OS (`linux-aarch64`).

## Quick start

1. **Install pixi** (once, per machine):
   ```
   curl -fsSL https://pixi.sh/install.sh | bash
   ```
2. **Install the environment** from the repo root (downloads ROS2 + Gazebo, ~several GB the
   first time; subsequent installs are cached):
   ```
   pixi install
   ```
3. **Drop into a shell** with ROS2 on your `PATH`:
   ```
   pixi shell
   ros2 --help
   ```
   or run a single command without entering the shell:
   ```
   pixi run ros2 topic list
   ```

## Already have a system ROS installed?

If your shell sources a system ROS (e.g. `source /opt/ros/<distro>/setup.bash` in your
`~/.bashrc`), its environment variables (`GZ_CONFIG_PATH`, `LD_LIBRARY_PATH`,
`AMENT_PREFIX_PATH`, `PYTHONPATH`, …) would otherwise **leak into the pixi environment and mix
incompatible libraries** — Gazebo especially would load the system's version and crash.

This is handled automatically: on activation, `scripts/pixi-activate-overlay.sh` strips those
leaked entries so each path variable points only at the pixi environment (and pins
`GZ_CONFIG_PATH` to this env's Gazebo). So plain `pixi run <task>` just works, and the Gazebo
GUI still opens (your `DISPLAY` is left untouched). No `--clean-env` needed.

> If you ever want a hard guarantee of isolation you can still use `pixi run --clean-env <task>`,
> but note it also strips `DISPLAY`, so the Gazebo GUI won't open under it — use `headless:=true`
> in that case.

## Tasks

Defined in `pixi.toml`, run with `pixi run <task>`:

| Task        | What it does                                                              |
|-------------|--------------------------------------------------------------------------|
| `build`     | `colcon build` (Ninja) — builds the ROS2 packages under `src/`           |
| `test`      | `colcon test` (depends on `build`)                                       |
| `sim`       | Launches the robot in a walled room in Gazebo (drive it with `teleop`)   |
| `teleop`    | Keyboard teleop — publishes `geometry_msgs/Twist` on `/cmd_vel`          |
| `rviz`      | The sim plus RViz (LiDAR + TF view)                                      |
| `sim-empty` | Bare empty-world smoke test of the raw Gazebo stack (no robot)           |

## Drive the robot (teleop simulation)

The workspace ships a ready-to-drive simulation: the oomwoo robot description
(`src/oomwoo_urdf`, vendored from [`makerspet/oomwoo_urdf`](https://github.com/makerspet/oomwoo_urdf))
plus a bringup package (`src/oomwoo_sim`) with a launch file and a walled-room world.

```
pixi run build                       # once (and after editing src/)
pixi run sim                         # terminal 1: Gazebo + robot + LiDAR + bridge
pixi run teleop                      # terminal 2: drive with the i/j/k/l keys
```

- A system ROS on your machine is handled automatically (see the section above). The robot
  driving and the 2D LiDAR (`/scan`) work **headless** — no display required.
- The **Gazebo GUI and RViz** need a display (`DISPLAY`). For the full visual experience run
  `pixi run rviz` (or `sim`) on a machine with a screen; on a Raspberry Pi use its desktop session.
- Extra launch args: `pixi run sim headless:=true` (server only),
  `pixi run sim rviz:=true`, or `pixi run sim world:=/path/to/your.sdf`.

Bridged topics: `/cmd_vel` (in), `/odom`, `/tf`, `/scan`, `/joint_states`, `/clock`.

### Adding your own ROS2 packages

`src/` is the colcon overlay workspace. Drop additional packages there (or clone one, e.g.
`git clone https://github.com/makerspet/oomwoo_urdf src/…`) and `pixi run build`. The overlay is
sourced automatically on pixi activation (via `scripts/pixi-activate-overlay.sh`), so
`pixi run <task>` sees your packages without a manual `source install/setup.bash`.

## Reproducibility & version control

- **Commit `pixi.lock`.** It pins every (transitive) dependency for all three platforms and is
  what makes the environment repeatable across machines and CI.
- **Do not commit `.pixi/`** — it is the solved, machine-local environment and is git-ignored.
- To update to newer package versions deliberately, run `pixi update` and commit the changed
  `pixi.lock`.

## Which ROS2 distro?

The manifest pins **Lyrical Luth** (ROS2's L-release). This gives contributors a concrete,
working environment today; the project's formal distro decision is still an open question in
[ARCHITECTURE.md §10](ARCHITECTURE.md).
