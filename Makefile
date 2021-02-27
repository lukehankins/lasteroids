ifeq ($(OS),Windows_NT)
	BOON = ./boon/boon-windows-amd64/boon.exe
else
    detected_OS := $(shell uname -s)
	ifeq ($(detected_OS),Linux)
		BOON = ./boon/boon-linux-amd64/boon
	else
		BOON = ./boon/boon-macos-amd64/boon
	endif
endif

.PHONY: play clean

.DEFAULT_GOAL: play

play:
	@/Applications/love.app/Contents/MacOS/love --console .

clean:
	@$(BOON) clean

release/Lasteroids.love: $(wildcard *.lua) $(wildcard %/%.lua)
	@$(BOON)  love download 11.3
	@$(BOON)  build . --target all

build: release/Lasteroids.love 

