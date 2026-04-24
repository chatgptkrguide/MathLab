fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android distribute

```sh
[bundle exec] fastlane android distribute
```

Build and distribute to Firebase App Distribution

### android patch

```sh
[bundle exec] fastlane android patch
```

OTA patch via Shorebird (no reinstall needed)

### android deploy_play_store

```sh
[bundle exec] fastlane android deploy_play_store
```

Deploy to Google Play Store (internal/alpha/beta/production)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
