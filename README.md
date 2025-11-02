# GNU Radio headless docker image

Ubuntu + GNU Radio + Python for

- Ubuntu 24.04
- GNU Radio 3.10.12
    - Volk 3.1.2
    - Python module
    - Blocks: FFT, Filter, Blocks, Analog, Digital,
    - Additional Blocks: Audio, Vocoder, ZeroMQ, UHD, SoapySDR
- Python 3.12

## Components

- gr-satellites
    - https://github.com/daniestevez/gr-satellites.git

## Building

- Uses cmake `install_manifest.txt` where possible to pull only files to the runtime image which were built from that stage

## Todo

- Normalize Python package locations (built from source specifically)

## Future

- Make SDR hardware support (ie. UHD, RTL) an optional Docker image for applications which would benefit from a smaller image and will pass samples in via ZeroMQ, UDP, or File

## Challenges

### Runtime libraries versus development packages

Many of the development packages are easiliy specified as {package}-dev but the associated runtime has only versioned packages, and unfortunately multiple versions may also exist. The easiest and most reliable way to runtime success is to install the dev package - but at the expense of image size.

(TODO) Find a way to determine the appropriate runtime package for a given *-dev* package.

### Python package install path

Python packages are being installed to any combination of the following:

```
/usr/{local/}/{python|python3.12}/{site|dist}-packages
```

- `dist-packages` is a convention specific to Debian-based Linux distributions
- `site-packages` - standard directory where third-party Python packages are installed by tools like pip when using a non-Debian-based system or a Python installation built from source.

Important factor for Python ***venv*** usage - when creating a venv environment it does NOT add system package locations into the search paths by default! Add `--system-site-packages` to the venv creation command to do so. Example:

```
python3 -m venv --system-site-packages myenv
```

## CMake Configuration (GNU Radio)

### Enabled components

- testing-support
- python-support
- post-install
- gnuradio-runtime
- common-precompiled-headers
- gr-ctrlport
- gr-blocks
- gr-fec
- gr-fft
- gr-filter
- gr-analog
- gr-digital
- gr-dtv
- gr-audio
    - alsa
    - oss
    - jack
    - portaudio
- gr-channels
- gr-pdu
- gr-iio
    - libad9361
- gr-trellis
- gr-uhd
- gr-uhd UHD 4.0 RFNoC
- gr-utils
- gr_blocktool
- gr-video-sdl
- gr-vocoder
    - codec2
    - freedv
    - gsm
- gr-wavelet
- gr-zeromq
- gr-network
- gr-soapy

### Disabled components

- doxygen
- man-pages
- gnuradio-companion
- gr-qtgui
- gr_modtool
