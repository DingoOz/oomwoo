# Sourced by pixi on environment activation (see [activation] in pixi.toml).
#
# Two jobs:
#   1. Strip host-ROS contamination from path-like env vars, so a system ROS
#      (e.g. sourced /opt/ros/<distro> in your ~/.bashrc) does not leak in and
#      mix incompatible Gazebo/ROS libraries with this pixi environment. This
#      keeps only entries under the pixi env or this project, WITHOUT touching
#      DISPLAY/XAUTHORITY -- so the Gazebo GUI still works. This replaces the
#      need for `pixi run --clean-env`.
#   2. Source the colcon overlay (built by `pixi run build`) so workspace
#      packages such as oomwoo_sim are on the ROS 2 package path. No-ops before
#      the first build, so a fresh `pixi install` / `pixi run build` still works.
#
# On a clean machine (no system ROS) this is a harmless no-op.

# Keep only colon-separated entries that live under the pixi env ($CONDA_PREFIX)
# or this project ($PIXI_PROJECT_ROOT); drop everything else (e.g. /opt/ros/...).
_oomwoo_filter_path() {
    _oomwoo_out=""
    _oomwoo_ifs="$IFS"
    IFS=":"
    for _oomwoo_p in $1; do
        [ -z "$_oomwoo_p" ] && continue
        case "$_oomwoo_p" in
            "${CONDA_PREFIX}"|"${CONDA_PREFIX}"/*|"${PIXI_PROJECT_ROOT}"|"${PIXI_PROJECT_ROOT}"/*)
                _oomwoo_out="${_oomwoo_out:+$_oomwoo_out:}$_oomwoo_p"
                ;;
        esac
    done
    IFS="$_oomwoo_ifs"
    printf '%s' "$_oomwoo_out"
}

# Rewrite each var to its pixi-only entries; unset it if nothing remains.
# LD_LIBRARY_PATH is the critical one (prevents loading a system Gazebo's .so);
# the ROS/GZ discovery vars are filtered so plugins/configs resolve to pixi.
if [ -n "${CONDA_PREFIX:-}" ]; then
    for _oomwoo_var in \
        LD_LIBRARY_PATH \
        AMENT_PREFIX_PATH \
        COLCON_PREFIX_PATH \
        CMAKE_PREFIX_PATH \
        PYTHONPATH \
        PKG_CONFIG_PATH \
        GZ_SIM_RESOURCE_PATH \
        GZ_SIM_SYSTEM_PLUGIN_PATH \
        GZ_GUI_PLUGIN_PATH \
        GZ_CONFIG_PATH \
        GAZEBO_MODEL_PATH
    do
        eval "_oomwoo_cur=\${$_oomwoo_var:-}"
        [ -z "$_oomwoo_cur" ] && continue
        _oomwoo_new="$(_oomwoo_filter_path "$_oomwoo_cur")"
        # Always export (even when empty) so a host value is overridden rather
        # than left to pass through -- `unset` does not propagate through pixi.
        export "$_oomwoo_var=$_oomwoo_new"
    done
    unset _oomwoo_var _oomwoo_cur _oomwoo_new

    # GZ_CONFIG_PATH must point at THIS env's gz config (it holds sim<N>.yaml,
    # which tells the `gz` dispatcher how to launch the right Gazebo version).
    # Emptying it makes `gz sim` fail with exit 255; a host value loads the wrong
    # Gazebo. Force it to the pixi env's config dir.
    if [ -d "${CONDA_PREFIX}/share/gz" ]; then
        export GZ_CONFIG_PATH="${CONDA_PREFIX}/share/gz"
    fi
fi
unset -f _oomwoo_filter_path 2>/dev/null || true

# Build the fontconfig cache once per solved env. pixi skips conda post-link
# scripts by default, so the fonts package's own fc-cache never runs; without a
# valid cache, Qt GUIs (the Gazebo GUI, RViz) segfault in fontconfig while
# laying out text. Stamped so this only runs once per environment.
if [ -n "${CONDA_PREFIX:-}" ] && [ ! -e "${CONDA_PREFIX}/.oomwoo-fc-cache" ] \
        && command -v fc-cache >/dev/null 2>&1; then
    fc-cache >/dev/null 2>&1 && : > "${CONDA_PREFIX}/.oomwoo-fc-cache" 2>/dev/null || true
fi

# 2. Source the colcon overlay if it has been built.
if [ -n "${PIXI_PROJECT_ROOT:-}" ] && [ -f "${PIXI_PROJECT_ROOT}/install/setup.sh" ]; then
    . "${PIXI_PROJECT_ROOT}/install/setup.sh"
fi
