FROM ubuntu:24.04 AS build

# package cache
ARG APTPROXY="http://172.17.0.1:3142"
RUN echo "Acquire::http::Proxy \"$APTPROXY\";" > /etc/apt/apt.conf.d/01proxy

# RUN echo 'Acquire::http::Proxy "http://host.docker.internal:3142";' > /etc/apt/apt.conf.d/01proxy

RUN apt update && apt install -y \
    git cmake g++ python3-dev python3-pip libboost-all-dev \
    libfftw3-dev libgmp-dev swig libzmq3-dev libuhd-dev

#
# VOLK MUST be installed first
#

RUN git clone --recursive https://github.com/gnuradio/volk.git
WORKDIR /volk/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3 ../
RUN make -j$(nproc) && make install && ldconfig

#
# GNU Radio
#
# RUN git clone --branch v3.10.10.0 https://github.com/gnuradio/gnuradio.git
# WORKDIR /gnuradio/build
# RUN cmake -DENABLE_DEFAULT=OFF -DENABLE_GR_BLOCKS=ON -DENABLE_GRC=OFF \
#           -DENABLE_GR_QTGUI=OFF -DENABLE_GR_WXGUI=OFF ..
# RUN make -j$(nproc) && make install && ldconfig

# Add a non-root user if you prefer
# RUN useradd -m gnuradio && echo "gnuradio:gnuradio" | chpasswd && adduser gnuradio sudo


# RUN git clone --branch v3.10.10.0 https://github.com/gnuradio/gnuradio.git
# WORKDIR /gnuradio/build
# RUN cmake -DENABLE_DEFAULT=OFF -DENABLE_GR_BLOCKS=ON -DENABLE_GRC=OFF \
#           -DENABLE_GR_QTGUI=OFF -DENABLE_GR_WXGUI=OFF ..
# RUN make -j$(nproc) && make install && ldconfig

# FROM ubuntu:24.04
# COPY --from=build /usr/local /usr/local
# RUN ldconfig
# CMD ["gnuradio-config-info", "--version"]

# Expose whatever ports if needed (e.g., for network streaming)
# ENTRYPOINT or CMD as needed for your workflow
CMD ["bash"]
