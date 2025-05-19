# blog moulard

comment exliquer sa et le reste !!!

## note Guillaume
Dans docker mini

https://hub.docker.com/r/klakegg/hugo
https://hub.docker.com/r/klakegg/hugohttps://hub.docker.com/r/klakegg/hugo

docker run --rm -it \
  --name hugo \
  --network dockermac \
  -v $(pwd):/src \
  -p 1313:1313 \
  klakegg/hugo \
  server -b https://blogtest.moulard.org/ --port=443



