# Official haskell docker image is based on debian buster, which is too "stable"
# (oldoldstable) now. So here we install ghc manually.
FROM docker.io/library/debian:bookworm

ENV LANG C.UTF-8

# -----------------------------------------------------------------------------
# Install ghc & cabal
#
# Ref: https://github.com/haskell/docker-haskell
# -----------------------------------------------------------------------------

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        curl \
        git \
        gcc \
        g++ \
        libc6-dev \
        libffi-dev \
        libgmp-dev \
        libnuma-dev \
        libsqlite3-dev \
        libtinfo-dev \
        make \
        cmake \
        pkg-config \
        netbase \
        openssh-client \
        bash-completion \
        xz-utils \
        zlib1g-dev

ARG CABAL_INSTALL=3.8.1.0
ARG CABAL_INSTALL_RELEASE_KEY=E9EC5616017C3EE26B33468CCE1ED8AE0B011D8C

RUN set -eux; \
    cd /tmp; \
    ARCH="$(uname -m)"; \
    CABAL_INSTALL_TAR="cabal-install-$CABAL_INSTALL-$ARCH-linux-deb10.tar.xz"; \
    CABAL_INSTALL_URL="https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/$CABAL_INSTALL_TAR"; \
    CABAL_INSTALL_SHA256SUMS_URL="https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/SHA256SUMS"; \
    # sha256 from https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/SHA256SUMS
    case "$ARCH" in \
        'aarch64') \
            CABAL_INSTALL_SHA256='c7fa9029f2f829432dd9dcf764e58605fbb7431db79234feb3e46684a9b37214'; \
            ;; \
        'x86_64') \
            CABAL_INSTALL_SHA256='c71a1a46fd42d235bb86be968660815c24950e5da2d1ff4640da025ab520424b'; \
            ;; \
        *) echo >&2 "error: unsupported architecture '$ARCH'"; exit 1 ;; \
    esac; \
    curl -fSL "$CABAL_INSTALL_URL" -o cabal-install.tar.gz; \
    echo "$CABAL_INSTALL_SHA256 cabal-install.tar.gz" | sha256sum --strict --check; \
    \
    curl -sSLO "$CABAL_INSTALL_SHA256SUMS_URL"; \
    curl -sSLO "$CABAL_INSTALL_SHA256SUMS_URL.sig"; \
    GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
    gpg --batch --keyserver keyserver.ubuntu.com --receive-keys "$CABAL_INSTALL_RELEASE_KEY"; \
    gpg --batch --verify SHA256SUMS.sig SHA256SUMS; \
    # confirm we are verifying SHA256SUMS that matches the release + sha256
    grep "$CABAL_INSTALL_SHA256  $CABAL_INSTALL_TAR" SHA256SUMS; \
    gpgconf --kill all; \
    \
    tar -xf cabal-install.tar.gz -C /usr/local/bin; \
    \
    rm -rf /tmp/*; \
    \
    cabal --version

ARG GHC=9.2.8
ARG GHC_RELEASE_KEY=88B57FCF7DB53B4DB3BFA4B1588764FBE22D19C4

RUN set -eux; \
    cd /tmp; \
    ARCH="$(uname -m)"; \
    GHC_URL="https://downloads.haskell.org/~ghc/$GHC/ghc-$GHC-$ARCH-deb10-linux.tar.xz"; \
    # sha256 from https://downloads.haskell.org/~ghc/$GHC/SHA256SUMS
    case "$ARCH" in \
        'aarch64') \
            GHC_SHA256='645433359d8ad9e7b286f85ef5111db1b787ee3712c24c5dfde7c62769aa59a4'; \
            ;; \
        'x86_64') \
            GHC_SHA256='10d1be25487bcf99ac8eb77beaa220c85e69f8c1106f4219ce019206ecc0ac51'; \
            ;; \
        *) echo >&2 "error: unsupported architecture '$ARCH'" ; exit 1 ;; \
    esac; \
    curl -sSL "$GHC_URL" -o ghc.tar.xz; \
    echo "$GHC_SHA256 ghc.tar.xz" | sha256sum --strict --check; \
    \
    GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
    curl -sSL "$GHC_URL.sig" -o ghc.tar.xz.sig; \
    gpg --batch --keyserver keyserver.ubuntu.com --receive-keys "$GHC_RELEASE_KEY"; \
    gpg --batch --verify ghc.tar.xz.sig ghc.tar.xz; \
    gpgconf --kill all; \
    \
    tar xf ghc.tar.xz; \
    cd "ghc-$GHC"; \
    ./configure --prefix "/opt/ghc/$GHC"; \
    make install; \
    \
    rm -rf /tmp/*; \
    \
    "/opt/ghc/$GHC/bin/ghc" --version

ENV PATH /root/.cabal/bin:/root/.local/bin:/opt/ghc/${GHC}/bin:$PATH

# -----------------------------------------------------------------------------
# Install grpc
# -----------------------------------------------------------------------------

RUN apt-get update && apt-get install -y \
      build-essential autoconf libtool libssl-dev pkg-config cmake git

 ARG PARALLEL
 RUN BUILD_DIR=$(mktemp -d) && \
     cd $BUILD_DIR && \
     git clone --depth 1 --branch v1.54.2 --recurse-submodules https://github.com/grpc/grpc && \
     cd grpc && \
     cmake -DCMAKE_INSTALL_PREFIX=/usr \
           -DgRPC_BUILD_TESTS=OFF \
           -DBUILD_SHARED_LIBS=ON \
           -DgRPC_INSTALL=ON \
           -DCMAKE_BUILD_TYPE=Release \
           -DgRPC_SSL_PROVIDER=package \
           . && \
     make -j ${PARALLEL:-$(nproc)} && \
     make install -j${PARALLEL:-$(nproc)} && \
     rm -rf $BUILD_DIR

# -----------------------------------------------------------------------------
# Build bench
# -----------------------------------------------------------------------------

COPY haskell_hs_grpc_protosuite_bench /app/bench
COPY proto /app/proto

RUN cd /app/bench && cabal update && make && cabal install

RUN rm -rf /app

ENTRYPOINT /root/.cabal/bin/haskell-hs-grpc-protosuite-bench +RTS -N${GRPC_SERVER_CPUS:-1}
