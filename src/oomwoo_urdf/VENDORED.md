# Vendored: makerspet/oomwoo_urdf

This directory is a **vendored copy** of the upstream robot description package, committed
here so the pixi simulation is reproducible and buildable offline (consistent with committing
`pixi.lock`).

- **Upstream:** https://github.com/makerspet/oomwoo_urdf
- **Commit:** `6ededc2f28fd1a86ecf26da2dd3a58d6fcfc2004` (main, 2026-06-13)
- **License:** Apache-2.0 (see `LICENSE`) — © makerspet.com / Ilia O.
- **ROS 2 package name:** `makerspet_mini` (the folder is `oomwoo_urdf`, but `package.xml`
  and the installed share directory are `makerspet_mini`).

The `oomwoo_sim` package (`../oomwoo_sim`) adds the launch files and a Gazebo world that this
description package does not ship, without modifying the description itself.

## Re-syncing with upstream

Re-clone at the desired commit and copy the tree (minus `.git`) over this directory, then
rebuild with `pixi run build`. Keep this `VENDORED.md` and record the new commit hash above.

If a future change requires editing the description (e.g. gz↔ROS topic reconciliation), note
the local modification here so it isn't lost on the next sync.
