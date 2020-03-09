up:
	hugo server -D --disableFastRender

new:
	hugo new "posts/$(shell date +%F)-$(shell echo $(POST) | sed "s/ /-/g").md"

build:
	hugo -D
