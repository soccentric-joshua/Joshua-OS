# Joshua-OS Build and Deployment

## Purpose and scope

Joshua-OS is the Yocto/KAS image build system for the Joshua embedded target. The root Makefile drives Dockerized kas, the default board `joshua-am62a`, image and SDK generation, OTA packaging, SD flashing, artifact staging, and cleanup.

## 1. Prerequisites

- GNU Make, Docker, curl, `grep`, `awk`, `find`, `gzip`, `cpio`, and `openssl` for the relevant workflows.
- A board manifest at `kas/boards/$(BOARD).yaml`; the declared board is `joshua-am62a` and `MACHINE` is derived from that YAML.
- Network access to download kas-container version `4.5`, Yocto layers, and source dependencies. Docker storage, significant disk space, and time are required for Yocto builds.
- `bmaptool` and permission to access a block device only for flashing. An RSA private key is required for signed SWU output; otherwise `make swu` explicitly creates an unsigned package.

## 2. Setup

Run `make kas-container-script` to download and cache the pinned kas-container helper, or let build targets do it. `make kas-image` builds the KAS image from `docker/yocto/`. Build/cache directories default to `build`, `downloads`, `sstate-cache`, and `deploy`; override `BOARD`, `BUILD_DIR`, `DL_DIR`, `SSTATE_DIR`, `DEPLOY_DIR`, or image variables as needed.

Use board syntax exactly as supported: `make image joshua-am62a`, `make sdk joshua-am62a`, or `make shell joshua-am62a`. `BOARD=...` is also supported. The only board printed by the Makefile help is `joshua-am62a`.

## 3. Build and compile

- `make build` or `make image joshua-am62a` - build the Yocto image through kas and stage image artifacts.
- `make rebuild-image joshua-am62a` - run `bitbake -c cleansstate $(IMAGE_TARGET)` then rebuild.
- `make shell joshua-am62a` - open an interactive kas shell.
- `make sdk joshua-am62a` - build `populate_sdk` and stage the SDK installer.
- `make esdk joshua-am62a` - build `populate_sdk_ext` and stage the extensible SDK installer.
- `make sdk-image joshua-am62a` / `make esdk-image joshua-am62a` - build the SDK/eSDK, stage its installer into Docker context, build the corresponding Docker image, and deploy the staged artifacts.

The KAS image defaults to `joshua-kas:latest`; SDK/eSDK images default to `joshua-sdk:latest` and `joshua-esdk:latest`. `IMAGE_TARGET` defaults to `joshua-image`.

## 4. Test and lint

The Makefile defines no test or lint targets. Use `make shell joshua-am62a` for controlled interactive BitBake inspection and verify the resulting image, boot, services, and peripherals manually on hardware. No automated quality gate is claimed by this leaf's Makefile.

## 5. Packaging and artifacts

- `make swu joshua-am62a` creates `build/joshua-am62a-$(SWU_VERSION).swu` from the latest rootfs image, with optional kernel/DTB payloads selected by `SWU_KERNEL_PATTERN` and `SWU_DTB_PATTERN`.
- Signed SWU requires `meta/meta-joshua/swupdate/keys/swupdate-private.pem`; without it, the Makefile creates an unsigned package and warns.
- `deploy/images/BOARD_TIMESTAMP/` receives `.wic.bz2` and `.wic.bmap` files.
- `deploy/sdk/BOARD_TIMESTAMP/` receives normal `.sh` SDK installers; `deploy/esdk/BOARD_TIMESTAMP/` receives `*-ext-*.sh` installers.
- `deploy/swu/BOARD_TIMESTAMP/` receives the SWU package.

## 6. Deployment, install, and run

- `make flash joshua-am62a DEVICE=/dev/sdX` - validate a block device, locate the latest `.wic.bz2`, and flash it with `bmaptool`; this is destructive and requires elevated device access.
- `make deploy-images`, `make deploy-sdk`, `make deploy-esdk`, and `make deploy-swu` - manually restage artifacts after their source outputs exist.
- SDK/eSDK shell images are built by `sdk-image`/`esdk-image`; the Makefile does not deploy to a cloud or remote board over the network.

Installation of the generated SDK/eSDK or booting/flashing the image must be performed and verified on the intended development host or physical board. Override `SWU_VERSION=1.2.3` for a release-like OTA name.

## 7. Cleanup

- `make clean` or `make clean-build` removes `build/`.
- `make clean-docker` removes KAS, SDK, and eSDK Docker images.
- `make clean-all` removes `build/`, `downloads/`, and `sstate-cache/`; this is expensive to recover from.
- `make completion` appends the tab-completion script to `~/.bashrc`.

## 8. Hardware, cloud, and manual verification caveats

Yocto compilation is not a boot or hardware pass. `make flash` writes a real block device, and image/OTA validation requires the actual `joshua-am62a` board, serial/boot access, storage, peripherals, update flow, and (for signed OTA) production key handling. No cloud deployment or credential management is defined; treat all default image credentials and unsigned-SWU fallback as development-only.
