# [iCode](https://github.com/morinoyu8/icode)

<!-- [![Build Status](https://github.com/ish-app/ish/actions/workflows/ci.yml/badge.svg)](https://github.com/ish-app/ish/actions) -->
<!-- [![goto counter](https://img.shields.io/github/search/ish-app/ish/goto.svg)](https://github.com/ish-app/ish/search?q=goto) -->
<!-- [![fuck counter](https://img.shields.io/github/search/ish-app/ish/fuck.svg)](https://github.com/ish-app/ish/search?q=fuck) -->

<p align="center">
<img src="https://github.com/morinoyu8/icode-assets/blob/main/icode-poster.png?raw=true">
</p>

A code editor for iOS with Linux emulator [iSH](https://github.com/ish-app/ish).

iCode allows file operations, code editing, and terminal operations all in one app! iCode is developed with the goal of being released on App Store.

This project is forked from Linux emulator [iSH](https://github.com/ish-app/ish). Please send issues, pull requests, etc. about Linux emulator to [iSH](https://github.com/ish-app/ish). 

I am not a native English speaker, so issues and pull requests regarding README and code comments are welcome☺️

## What is iCode can do

iCode is currently able to do the following:

- 📁 File operations
  - Moving between directories in the Linux file system
  - Creating files and folders

- 📝 Code editing
  - Opening and saving files
  - Auto pairs
  - Running language servers on the Linux emulator
  - Code completions

- 💻 Linux emulations
  - Running your programs
  - Git operations
  - ... Everything the Linux emulator [iSH](https://github.com/ish-app/ish) can do

## Hacking

This project has a git submodule, make sure to clone with `--recurse-submodules` or run `git submodule update --init` after cloning.

You'll need these things to build the project:

 - Python 3
   + Meson (`pip3 install meson`)
 - Ninja
 - Clang and LLD (on mac, `brew install llvm`, on linux, `sudo apt install clang lld` or `sudo pacman -S clang lld` or whatever)
 - sqlite3 (this is so common it may already be installed on linux and is definitely already installed on mac. if not, do something like `sudo apt install libsqlite3-dev`)
 - libarchive (`brew install libarchive`, `sudo port install libarchive`, `sudo apt install libarchive-dev`) TODO: bundle this dependency

### Build for iOS

Create iCode.xcconfig in the app folder with the following contents.

```xcconfig
// app/iCode.xcconfig
ROOT_BUNDLE_IDENTIFIER = // Bundle identifier
DEVELOPMENT_TEAM = // Your development team ID
```

Change `ROOT_BUNDLE_IDENTIFIER` to something unique, and change `DEVELOPMENT_TEAM` to your development team ID. It's possible to specify bundle identifier and your development team ID in the project or target build settings, but you should put it here to reduce merge conflicts.Then open the project in Xcode, and click Run. There are scripts that should do everything else automatically. If you run into any problems, open an issue and I'll try to help.

## Language Server

iCode currently supports only [clangd](https://clangd.llvm.org) as a language server. And the only function that can be performed is code completion. To use clangd, you need to run `apk add clang-extra-tools` in the terminal within iCode.