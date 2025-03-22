ARG BASH_VERSION=${BASH_VERSION:-5.0}

FROM bash:${BASH_VERSION}-alpine3.21

RUN apk add --no-cache bats util-linux git

WORKDIR /suite

RUN git init
RUN git submodule add https://github.com/bats-core/bats-support.git test_helper/bats-support
RUN git submodule add https://github.com/bats-core/bats-assert.git test_helper/bats-assert

COPY . /suite/

CMD ["/suite/hook.bats"]