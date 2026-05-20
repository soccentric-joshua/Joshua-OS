# Joshua Yocto BSP

Containerized Yocto/OpenEmbedded build system using `kas` + Docker.

Default target is now Joshua on TI Sitara AM62A (`SK-AM62A-LP` class board using machine `am62axx-evm`).

## Quick Start

```bash
# Build default board (Joshua / TI AM62A)
make image

# Explicit board selection
make image joshua-am62a
make image rpi5

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

Also supported (existing Raspberry Pi board configs):

- `rpi5`, `rpi4-64`, `rpi4`, `rpi3-64`, `rpi3`, `rpi2`
- `rpi0-2w-64`, `rpi0-2w`, `rpi0-wifi`, `rpi0`, `rpi1`
- `rpi-armv7`, `rpi-armv8`, `cm1`, `cm3`, `cm4`, `cm5`

## KAS Layout

- `kas/common.yaml`: shared distro/target/cache settings
- `kas/boards/*.yaml`: machine-specific board files
- `kas/repos/*.yaml`: external layer repository definitions

Layer repos now include both TI and Raspberry Pi BSP sources so the same workspace can build either family:

- `poky`
- `meta-openembedded`
- `meta-arm`
- `meta-ti`
- `meta-raspberrypi`
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

# Raspberry Pi remains available
make image rpi5
make shell cm5
```

## Notes For TI Sitara Port

- Default board switched from `rpi5` to `joshua-am62a`.
- Global KAS config was made platform-neutral to avoid Raspberry Pi-only `local.conf` assumptions on TI builds.
- TI support layers were added via `kas/repos/meta-ti.yaml` and `kas/repos/meta-arm.yaml`.
- New board manifest added at `kas/boards/joshua-am62a.yaml`.

## Troubleshooting

- Show board list and commands: `make help`
- If kas image is missing: `make kas-image`
- Rebuild from scratch: `make clean-all && make image joshua-am62a`
