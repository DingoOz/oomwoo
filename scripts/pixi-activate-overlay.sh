# Sourced by pixi on environment activation (see [activation] in pixi.toml).
#
# Sources the colcon overlay (built by `pixi run build`) so that `ros2 launch
# oomwoo_sim ...` and other workspace packages are on the ROS 2 package path.
# No-ops before the first build, so `pixi install` / `pixi run build` on a fresh
# clone still activate cleanly.
if [ -n "${PIXI_PROJECT_ROOT:-}" ] && [ -f "${PIXI_PROJECT_ROOT}/install/setup.sh" ]; then
    . "${PIXI_PROJECT_ROOT}/install/setup.sh"
fi
