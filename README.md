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
