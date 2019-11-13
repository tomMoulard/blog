up:
	hugo server -D

new:
	hugo new posts/$(shell date +%F)-$(POST).md

build:
	hugo -D