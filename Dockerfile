FROM ubuntu:24.04 AS builder

# apt package cache using apt-cacher-ng running on host
ARG APTPROXY=""
RUN if [ -n "$APTPROXY" ]; then \
        echo "Acquire::http::Proxy \"$APTPROXY\";" > /etc/apt/apt.conf.d/01proxy && \
        echo "Using apt proxy: $APTPROXY"; \
    else \
        echo "No apt proxy configured"; \
    fi

# prevent debian package configuration prompts (will assume defaults)
ENV DEBIAN_FRONTEND=noninteractive

#
# Common Builder Environment
#

RUN apt-get update && apt-get install -y --no-install-recommends \
        git cmake build-essential g++ \
        python3-dev python3-pip python3-mako \
        libboost-all-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN git config --global advice.detachedHead false

RUN mkdir /ext && mkdir /opt/manifests

#
# VOLK
#

RUN cd /ext && git clone --branch v3.1.2 --recursive \
        https://github.com/gnuradio/volk.git \
    && cd volk/ \
    && cmake -B build -S . \
        -DCMAKE_BUILD_TYPE=Release \
        -DPYTHON_EXECUTABLE=/usr/bin/python3 \
        -DCMAKE_INSTALL_PREFIX=/usr \
    && cmake --build build -j$(nproc) && cmake --install build && ldconfig \
    && cp build/install_manifest.txt /opt/manifests/volk-manifest.txt \
    && tar czf /tmp/volk-install.tar.gz --warning=none \
        -T /ext/volk/build/install_manifest.txt

#
# GNU Radio
#

RUN cd /ext && git clone --branch v3.10.12.0 https://github.com/gnuradio/gnuradio.git

RUN apt-get update && apt-get install -y --no-install-recommends \
        libfftw3-dev libgmp-dev swig libspdlog-dev libpkgconf-dev \
        libgsl-dev libzmq5-dev cppzmq-dev libthrift-dev pkg-config \
        libsdl1.2-dev \
        python3-pygccxml python3-numpy python3-packaging python3-pybind11 \
        python3-pkgconfig python3-thrift python3-scipy \
        libcodec2-dev libgsm1-dev libsndfile1-dev portaudio19-dev \
        libiio-dev libsoapysdr-dev libuhd-dev libad9361-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN cd /ext/gnuradio && rm -rf build/ && cmake -B build -S . \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_GNURADIO_RUNTIME=ON \
        -DENABLE_PYTHON=ON \
        -DENABLE_GR_BLOCKS=ON \
        -DENABLE_GR_FILTER=ON \
        -DENABLE_GR_ANALOG=ON \
        -DENABLE_GR_DIGITAL=ON \
        -DENABLE_GR_SOAPY=ON \
        -DENABLE_GR_ZEROMQ=ON \
        -DENABLE_GR_FFT=ON \
        -DENABLE_GRC=OFF \
        -DENABLE_MANPAGES=OFF \
        -DENABLE_GR_QTGUI=OFF \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DPYTHON_EXECUTABLE=/usr/bin/python3 \
        -DGR_PYTHON_DIR=$(python3 -c "import sysconfig; print(sysconfig.get_path('platlib'))") \
    && cmake --build build -j$(nproc) && cmake --install build && ldconfig \
    && cp /gnuradio/build/install_manifest.txt /opt/manifests/gnuradio-manifest.txt \
    && tar czf /tmp/gnuradio-install.tar.gz --warning=none \
        -T /gnuradio/build/install_manifest.txt

# Save Boost runtimes (no easier way to apt-get install libboost without '-dev')
RUN mkdir -p /opt/runtime-libs && \
    cp -a /usr/lib/x86_64-linux-gnu/libboost_*.so.* /opt/runtime-libs/

#
# SoapySDR
#
# requires: cmake g++ libpython3-dev python3-numpy swig
RUN cd /ext && git clone https://github.com/pothosware/SoapySDR.git \
    && cd SoapySDR \
    && cmake -B build/ \
    && make -j$(nproc) \
    && make -B build/ install \
    && cp build/install_manifest.txt /opt/manifests/soapy-sdr-manifest.txt \
    && tar czf /tmp/soapy-sdr-install.tar.gz --warning=none \
        -T install_manifest.txt \
    && ldconfig && cd /ext && rm -rf SoapySDR

#
# gr-satellites
#
RUN cd /ext && git clone https://github.com/daniestevez/gr-satellites.git /gr-satellites
RUN cd /ext/gr-satellites && git checkout v5.8.0 \
    && rm -rf build/ \
    && cmake -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DPYTHON_EXECUTABLE=/usr/bin/python3 \
        -DGR_PYTHON_DIR=$(python3 -c "import sysconfig; print(sysconfig.get_path('platlib'))") \
    && cmake --build build -j$(nproc) && cmake --install build && \
    cp /gr-satellites/build/install_manifest.txt /opt/manifests/gr-satellites-manifest.txt \
    && tar czf /tmp/gr-satellites-install.tar.gz --warning=none \
        -T /gr-satellites/build/install_manifest.txt


#
# RUNTIME LAYER
#

FROM ubuntu:24.04

# apt package cache using apt-cacher-ng running on host
ARG APTPROXY=""
RUN if [ -n "$APTPROXY" ]; then \
        echo "Acquire::http::Proxy \"$APTPROXY\";" > /etc/apt/apt.conf.d/01proxy && \
        echo "Using apt proxy: $APTPROXY"; \
    else \
        echo "No apt proxy configured"; \
    fi

# prevent debian package configuration prompts (will assume defaults)
ENV DEBIAN_FRONTEND=noninteractive

# Copy all cmake build install manifests
COPY --from=builder /opt/manifests /opt/manifests

RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3 python3-pip python3-venv

RUN apt-get install -y --no-install-recommends \
    libspdlog1.12 libpkgconf3 libiio0 \
    libfftw3-mpi3 libfftw3-double3 libfftw3-long3 libfftw3-quad3 libfftw3-single3 libfftw3-mpi3 \
    libgmp10 swig libzmq3-dev libuhd-dev \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /tmp/volk-install.tar.gz /tmp/
RUN tar xzf /tmp/volk-install.tar.gz -C / && \
    rm /tmp/volk-install.tar.gz

COPY --from=builder /tmp/gnuradio-install.tar.gz /tmp/
RUN tar xzf /tmp/gnuradio-install.tar.gz -C / && \
    rm /tmp/gnuradio-install.tar.gz

COPY --from=builder /tmp/gr-satellites-install.tar.gz /tmp/
RUN tar xzf /tmp/gr-satellites-install.tar.gz -C / && \
    rm /tmp/gr-satellites-install.tar.gz

# Boost runtimes
COPY --from=builder /opt/runtime-libs /usr/lib/x86_64-linux-gnu

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-numpy python3-construct \
    libgsl27 \
    python3-requests python3-websocket python3-zmq

# Preparations
RUN groupadd -r gnuradio && \
    useradd -r -g gnuradio -s /bin/bash -m gnuradio && \
    usermod -a -G audio gnuradio

RUN ldconfig

# Clear all apt caches and temporary files
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    rm -rf /var/cache/apt/archives/* /var/cache/apt/*.bin /tmp/* /var/tmp/*

# Switch to non-root user
USER gnuradio
WORKDIR /home/gnuradio

# Initialize GNU Radio and VOLK as the user
RUN mkdir -p ~/.config/gnuradio/prefs ~/.volk
RUN volk_profile
RUN python3 -c "from gnuradio import gr; tb = gr.top_block(); del tb; print('GNU Radio initialized')"

CMD ["gnuradio-config-info", "--version"]
