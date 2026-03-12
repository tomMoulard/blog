up:
	docker-compose up

new:
	go run github.com/gohugoio/hugo@v0.157.0 new "posts/$(shell date +%F)-$(shell echo $(POST) | sed "s/ /-/g").md"

build:
	docker-compose build
