<p align="center">
    A Safari App Extension that makes Reddit suck just a little bit less on Safari 13+.
    <img src='https://i.imgur.com/RLFPr6i.jpg'>
</p>

## Background

This project started in June 2019 as an attempt to port the entirety of the Reddit Enhancement Suite to the Safari App Extension framework. Since then, this project has diverted from that path and instead implements a select swath of features. Requests are welcome: simply open an issue. Pull requests are also welcome, as are code reviews.

## Requirements

As of version 1.4, redditweaks is only supported on macOS 10.15 (Catalina) and 11 (Big Sur). This is due to the adoption of SwiftUI and Combine in version 1.4.

Versions 1.3 and below were written in UIKit with the help of [SnapKit](https://github.com/SnapKit/SnapKit).

## Installation
1. Download the latest release from the [releases page](https://github.com/bermudalocket/redditweaks/releases).
2. Unzip the archive, and move `redditweaks.app` into `/Applications`.
3. Launch `redditweaks.app` and follow the prompt to enable the extension in Safari.
4. You may then close the app. It is not required to be open for the extension to work, but you cannot delete it.
