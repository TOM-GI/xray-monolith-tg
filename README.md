# X-Ray Monolith (TG Fork)

A fork of [X-Ray Monolith](https://github.com/themrdemonized/xray-monolith) (modded exes for S.T.A.L.K.E.R. Anomaly) with custom modifications and improvements.

Based on the work of **themrdemonized** and the modding community — all original engine patches are preserved.

---

## Changes from upstream

### CMake Migration

The build system has been migrated from MSBuild / Visual Studio Solution to **CMake + Ninja**.

- Full project configuration through CMake — no need to manually open `.sln` files
- Ninja as the default build backend for faster builds
- Ability to generate projects for different IDEs (Visual Studio, CLion, etc.)
- Easier dependency and target management

### Shader Hot-Reload

Runtime shader reloading without restarting the game. Useful for shader development and debugging. Available on DX10/DX11 renderers (R3/R4).

Console commands:
- `reload_ps <name>` — reload a pixel shader by name (e.g. `reload_ps effects_rain`)
- `reload_vs <name>` — reload a vertex shader by name (e.g. `reload_vs effects_rain`)
- `shader_watch [0|1]` — toggle automatic file watcher that monitors the shader directory for changes and reloads modified shaders on the fly
