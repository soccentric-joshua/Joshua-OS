# Joshua-OS

## Project Summary

Joshua-OS is Joshua’s containerized Yocto/OpenEmbedded build layer. It uses `kas` and Docker to
assemble a board image, SDK, or extensible SDK from shared configuration, board definitions, and
external layer manifests. The documented default is `joshua-am62a`, mapped to the TI Sitara AM62A
`am62axx-evm` machine for an SK-AM62A-LP-class board. Common settings live in `kas/common.yaml`,
board selections in `kas/boards/`, and external repositories in `kas/repos/`, including Poky,
meta-openembedded, meta-arm, meta-ti, meta-swupdate, and meta-joshua.

The Makefile is the operational entry point. It exposes image/build aliases, SDK and eSDK
generation, a build-container shell, flashing through bmaptool, help output, and cleanup. The
Docker-oriented structure keeps host requirements small and makes the expected kas environment
explicit. This is a build system rather than a runtime application: success depends on network
access to layer sources, Docker, kas-compatible metadata, board configuration, and, for flashing, a
correctly identified removable device. No automated test suite is identified, so command wiring and
checked-in configuration are implemented while image reproducibility, bootability, package contents,
and hardware flashing remain partial or unknown.

## Feature Inventory

| # | Name / Description | Implemented? | Test Coverage? | Manual Test |
| --- | --- | --- | --- | --- |
|   1 | kas/OpenEmbedded project configuration    | Implemented  | No automated tests identified | [ ] Manual verification required |
|   2 | Default Joshua AM62A board mapping        | Implemented  | Boot validation unknown       | [ ] Manual verification required |
|   3 | Shared distro/target/cache settings       | Implemented  | Unknown                       | [ ] Manual verification required |
|   4 | Board-specific kas YAML files             | Implemented  | Unknown                       | [ ] Manual verification required |
|   5 | External layer repository definitions     | Implemented  | Fetches environment-dependent | [ ] Manual verification required |
|   6 | Dockerized Yocto workflow                 | Implemented  | Unknown                       | [ ] Manual verification required |
|   7 | Image build via `make image`/`make build` | Implemented  | No automated test identified  | [ ] Manual verification required |
|   8 | SDK generation                            | Implemented  | No automated test identified  | [ ] Manual verification required |
|   9 | eSDK generation                           | Implemented  | No automated test identified  | [ ] Manual verification required |
|  10 | Interactive kas build shell               | Implemented  | No automated test identified  | [ ] Manual verification required |
|  11 | WIC flashing with bmaptool                | Implemented  | No automated test identified  | [ ] Manual verification required |
|  12 | Clean rebuild and help targets            | Implemented  | No automated test identified  | [ ] Manual verification required |
|  13 | Image boot/package verification           | Planned      | None identified               | [ ] Manual verification required |
|  14 | Offline/mirror-only build                 | Unknown      | None identified               | [ ] Manual verification required |

## Common Commands

````bash
make image joshua-am62a
make sdk joshua-am62a
make esdk joshua-am62a
make shell joshua-am62a
make flash joshua-am62a DEVICE=/dev/sdX
make clean-all && make image joshua-am62a
```

Containerized Yocto/OpenEmbedded build system using `kas` + Docker.

Default target is now Joshua on TI Sitara AM62A (`SK-AM62A-LP` class board using machine
`am62axx-evm`).

## Quick Start

```bash
# Build default board (Joshua / TI AM62A)
make image

# Explicit board selection
make image joshua-am62a

# Open shell in build container
make shell joshua-am62a

# Flash latest WIC image
make flash joshua-am62a DEVICE=/dev/sdX
```

## Prerequisites

- Docker 20.10+
- GNU Make 4.0+
- curl
- bmaptool (for `make flash`)

## Board Support

Default board:

- `joshua-am62a` -> `am62axx-evm` (TI Sitara AM62A / SK-AM62A-LP class)

## KAS Layout

- `kas/common.yaml`: shared distro/target/cache settings
- `kas/boards/*.yaml`: machine-specific board files
- `kas/repos/*.yaml`: external layer repository definitions

Layer repos:

- `poky`
- `meta-openembedded`
- `meta-arm`
- `meta-ti`
- `meta-swupdate`
- `meta-joshua`

## Common Targets

- `make build [board]` or `make image [board]`
- `make sdk [board]`
- `make esdk [board]`
- `make shell [board]`
- `make flash [board] DEVICE=/dev/sdX`
- `make help`

## Examples

```bash
# Joshua / TI AM62A
make image joshua-am62a
make sdk joshua-am62a
```

## Troubleshooting

- Show board list and commands: `make help`
- If kas image is missing: `make kas-image`
- Rebuild from scratch: `make clean-all && make image joshua-am62a`
