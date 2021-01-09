EMSCR=em++

SRC=src/maximilian/src/maximilian.cpp
SRC_EM=src/maximilian/src/maximilian.embind.cpp
# SRC_LIBS=../../../src/libs/*.cpp
# SRC_LIBS=../../src/libs/maxiSynths.cpp
SRC_LIBS=src/maximilian/src/libs/maxiSynths.cpp src/maximilian/src/libs/maxiGrains.cpp src/maximilian/src/libs/maxiFFT.cpp src/maximilian/src/libs/fft.cpp src/maximilian/src/libs/maxiMFCC.cpp
C_SRC_LIBS=src/maximilian/src/libs/stb_vorbis.c

BUILD_DIR=dist
MKDIR_P = mkdir -p

# POST_JS – external js handling web audio etc
POST_JS=src/maximilian.post.js

OUTPUT=$(BUILD_DIR)/maximilian.wasm


# AudioWorklet working configuration

CFLAGS=--bind -O3\
	-s WASM=1 \
	-s BINARYEN_ASYNC_COMPILATION=0 \
	-s SINGLE_FILE=1 \
	-s ALLOW_MEMORY_GROWTH=1 \
	-s ABORTING_MALLOC=0 \
	-s TOTAL_MEMORY=512Mb -DVORBIS \
	-s "EXPORT_NAME='Maximilian'" \
  -s "BINARYEN_METHOD='native-wasm'" \
	-s ERROR_ON_UNDEFINED_SYMBOLS=0 \
  --js-opts 0 -g4 --source-map-base "http://localhost:9000/audio-worklet/build/"


	# For optimisations and compiler settings

	# check https://emscripten.org/docs/optimizing/Optimizing-Code.html#optimizing-code
	# and https://emscripten.org/docs/tools_reference/emcc.html#emcc-compiler-optimization-options
	# and https://github.com/emscripten-core/emscripten/blob/master/src/settings.js

	# -s MODULARIZE=1
	# --js-opts 0 \  # Enables JavaScript optimizations, relevant when we generate JavaScript — 0 prevents optimizer from running
	# -g4 \ # Controls the level of debuggability. g4 value is the highest level, generates a source map using LLVM debug information, when linking
  # -s MODULARIZE=1 \ # Don't use this with --post-js, it will get messy. MODULARIZE puts all the output into a function. It minifies globals to names that might conflict with others in the global scope, including the name of Module itself. make sure a global variable called Module already exists before the closure-compiled code runs.



RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
CYAN=\033[0;36m
RESET=\x1b[0m

# --post-js $(POST_JS)

all: full

.PHONY: directory
directory: ${BUILD_DIR}
	@echo "Copying files"

${BUILD_DIR}:
	${MKDIR_P} ${BUILD_DIR}

full: directory
	@echo "${YELLOW}\r\nmaximilian.wasm – WebAssembly (Wasm) build for Web Audio API AudioWorklet\r\n ${RESET}"
	$(EMSCR) $(CFLAGS) --post-js $(POST_JS) -o $(OUTPUT) $(SRC_EM) $(SRC) $(SRC_LIBS) $(C_SRC_LIBS)

clean:
	@echo "Cleaning up"
	rm -f $(BUILD_DIR)/maximilian.*
