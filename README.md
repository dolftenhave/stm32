# STM32

This repo contains some info and helper scripts that I use for my STM32 tool chain.

- [Boards](#boards)
- [Setup](#Setup)
- [Starting a new project](#starting-a-new-project)

## Boards

- [STM32F407G-disc1](F407G/README.md)
- `NUCLEO-F446RE`. *(Have not used it yet hence no folder)*.

## Setup

- [Requirements](#requirements)
- [Language Server](#language-server)

[Getting Sarted](https://wiki.st.com/stm32mcu/wiki/Category:Getting_started_with_STM32_:_STM32_step_by_step)

### Requirements

- [STM32CubeMx](https://www.st.com/en/development-tools/stm32cubemx.html)
- `arm-none-eabi-gcc` and `arm-none-eabi-newlib`.
- `make` build tool.
- `bear` lsp generator.
- `openocd` to flash the binaries.

STM32CubeMx must be installed from the website.

Then run this to install all the other dependencies.
```bash
sudo pacman -S arm-none-eabi-gcc arm-none-eabi-newlib bear make openocd
```

### Language Server

#### Nvim Clangd LSP

By default, `clangd` assumes the code is beig compiled for the host machine. In order to use the correct drivers, the `--query-drivers` flag must be passed to `clangd` in the neovim LSP config so it knows to ask for the ARM compiler and its coresponding headers.

Adding the following lines to the `lsp-config.lua` file will fix that.

```lua
-- inside the:
-- vim.lsp.enable("clangd", {
        cmd = {
            "clangd",
            "--background-index",
            "--query-drivers=**arm-none-eabi-g*",
            "--header-insertion=iwyu",
        },
--}
```

#### The create a `.clangd` file.

```yaml
CompileFlags:
  # Remove GCC-specific flags that Clang doesn't understand
  Remove: 
    - "-fno-tree-loop-distribute-patterns"
    - "-mthumb-interwork"
    - "-Wstrict-aliasing=*"
  
  # Add flags to suppress annoying warnings that aren't relevant 
  Add:
    - "-Wno-unknown-warning-option"
    - "-Wno-unsupported-floating-point-opt"
    - "-Wno-unused-parameter"
```

#### `.clang-format` for 4 space indenting.

Add the following `.clang-format` file into the root of the project in order too have 4 space indenting.

```
BasedOnStyle: LLVM
IndentWidth: 4
TabWidth: 4
UseTab: Always
```

Run `make clean` to clean the project.
Run `bear -- make -j$(nproc)`.

## Starting a new project

Use `STM32CubeMx` to create a new project. 

**IMPORTANT:** In the Project Manager > Project > Toolchain/IDE tab, make sure to select MakeFile from the dropdown list.

Then run the `init.sh` shell script from inside the root directory of the project. This will create the `.compile_command.json` file and add some helper functions to the Makefile.

The project can the be flashed to the board with `make flash`.
