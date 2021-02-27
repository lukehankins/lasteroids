.PHONY: play clean

.DEFAULT_GOAL: play

play:
	@/Applications/love.app/Contents/MacOS/love --console .

clean:
	@./boon/boon clean

release/Lasteroids.love: $(wildcard *.lua) $(wildcard %/%.lua)
	@./boon/boon love download 11.3
	@./boon/boon build . --target all

build: release/Lasteroids.love 

