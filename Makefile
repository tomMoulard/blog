up:
	docker-compose up

new:
	hugo new "posts/$(shell date +%F)-$(shell echo $(POST) | sed "s/ /-/g").md"

build:
	docker-compose build
