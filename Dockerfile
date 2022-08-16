# Get all of our CPAN dependencies, build, and test.
FROM alpine:3 AS build

RUN apk update && apk add \
	curl \
	tar \
	make \
	gcc \
	build-base \
	wget \
	gnupg \
	perl \
	perl-utils \
	perl-dev \
	perl-app-cpanminus \
	&& rm -rf /var/cache/apk/*

RUN cpanm -i local::lib

WORKDIR /src/app

COPY cpanfile ./

RUN cpanm -n --installdeps -l ./vendor .

COPY . ./

RUN prove -lvcf -I./lib -Mlocal::lib=./vendor

# Run our application.
FROM alpine:3

RUN apk update && apk add \
	perl \
	curl \
	make \
	perl-app-cpanminus \
	&& rm -rf /var/cache/apk/*

RUN cpanm -n -i local::lib

WORKDIR /src/app
COPY --from=build /src/app/vendor ./vendor
COPY --from=build /src/app/lib ./lib
COPY --from=build /src/app/bin ./bin

EXPOSE 3000

ENTRYPOINT [ "/usr/bin/perl", "-I./lib", "-Mlocal::lib=./vendor", \
	"./bin/picklews", "prefork" ]
