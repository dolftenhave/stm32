#!/bin/bash

# Dolf ten Have
# 20/02/2026

RESET="\033[0m"
OK="\033[92m"
WARN="\033[93m"
ERROR="\033[91m"
IMPORTANT="\033[95m"

BOARDS=("stm32f4x")

echo "Please select your board:"
count=1
for b in ${BOARDS[@]}; do
	echo "$count) $b"
	(( count++ ))
done
echo "0) other board"
echo "q) quit"
echo ""
read -p "Choice: " BOARD

if [[ $BOARD -eq "q" ]]; then
	exit
elif [[ $BOARD -eq "0" ]]; then
	echo ""
	read -p "Enter your board name: " BOARD
elif [[ $BOARD -gt ${#BOARDS[@]} ]]; then
	echo "Not a valid option, exiting."
	exit
else
	BOARD=$BOARDS[$BOARD]
fi

echo -e "Setting up environment for $IMPORTANT$BOARD$RESET"

# Check dependencies are installed.
DEPENDENCIES=("arm-none-eabi-gcc" "arm-none-eabi-newlib" "bear" "make" "openocd")
MISSING_DEPENDENCIES=""

for dep in ${DEPENDENCIES[@]}; do
	if [ -z "$(pacman -Qs $dep)" ]; then
		echo "$WARN[WARNING]$RESET: Missing '$dep'"
		MISSING_DEPENDENCIES="${MISSING_DEPENDENCIES} $dep"
	fi
done

if [ -z "$MISSING_DEPENDENCIES" ]; then
	echo "$OK All dependencies are present.$RESET"
else
	sudo pacman -S $MISSING_DEPENDENCIES
fi

# Clang format.
echo -e "BasedOnStyle: LLVM\nIndentWidth: 4\nTabWidth: 4\nUseTab: Always" >> .clang-format
echo -e "Created .clang-format"

bear -- make -j$(nprox)
echo "Generated LSP DB"

# Genrate .clangd file.
echo -e "\n\nCompileFlags:\n  # Remove GCC-specific flags that Clang doesn't understand\n  Remove: \n    - '-fno-tree-loop-distribute-patterns'\n    - '-mthumb-interwork'\n    - '-Wstrict-aliasing=*'\n  \n  # Add flags to suppress annoying warnings that aren't relevant \n  Add:\n    - '-Wno-unknown-warning-option'\n    - '-Wno-unsupported-floating-point-opt'\n    - '-Wno-unused-parameter'" >> .clangd
echo "Created '.clangd'"

# Tell clangd where the compilation database is (if you put it in a build folder)
# compilationDatabase: "build/"

# Append commands to the end to the make file.
echo -e "\n\n# Flash the project to the board.\nflash: all\n\topenocd -f interface/stlink.cfg -f target/stm32f4x.cfg -c 'program build/${PWD##*/}.elf verify reset exit'" >> Makefile
echo "Flash command added to make file."
echo -e "\n\n# Regenrate the LSP data\ncompiledb: clean\n\tbear --make -j$(nproc)" >> Makefile
echo "LSP db command added to the make file."
echo -e "${IMPORTANT}run 'make flash' to flash your project to the board.${RESET}"
echo -e "${IMPORTANT}run 'make compiledb' to rebuild the compile_commands.json file.${RESET}"
echo -e "${WARN}NOTE${RESET}: If the the program name differs from the current directory name, then you need to update the flash command in the make file to match the program name."

echo -e "${OK}DONE.$RESET You can now remove this script."
