FROM golang:1.15.3

WORKDIR /go/hugo

RUN mkdir -p /hugo && \
	cd /hugo && \
	wget https://github.com/gohugoio/hugo/releases/download/v0.78.2/hugo_0.78.2_Linux-64bit.tar.gz && \
	tar -xvf hugo_0.78.2_Linux-64bit.tar.gz

USER 1000

ENV HUGO_BIND="0.0.0.0" \
    HUGO_DESTINATION="public" \
    HUGO_ENV="DEV"

CMD /hugo/hugo server -D \
	--disableFastRender \
	--bind 0.0.0.0 \
	--baseURL http://0.0.0.0 \
	--noHTTPCache \
	--templateMetrics \
	--ignoreCache
