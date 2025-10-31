# GNU Radio headless docker image

- Ubuntu 24.04
- GNU Radio 3.10.12
    - Volk 3.1.2
    - Python support
    - FFT, Filter, Blocks, Analog, Digital, Audio, Vocoder, ZeroMQ
    - UHD, SoapySDR
- Python 3.12

## Components

- gr-satellites
    - https://github.com/daniestevez/gr-satellites.git

## Building

- Uses cmake `install_manifest.txt` for both Volk and GNU Radio to move only built files to the runtime image

## Todo

- Normalize Python package locations (built from source specifically)

## Challenges

### Python package install path

Observing Python packages being installed to any combination of:

```
/usr/{local/}/{python|python3.12}/{site|dist}-packages
```

The above combinations results in potentially 8 different paths.

- `dist-packages` is a convention specific to Debian-based Linux distributions
- `site-packages` - standard directory where third-party Python packages are installed by tools like pip when using a non-Debian-based system or a Python installation built from source.

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
