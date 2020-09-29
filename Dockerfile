FROM centos:latest

RUN dnf update -y && \
    dnf install -y make curl epel-release python3 && \
    pip3 install pyserial && \
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh && \
    arduino-cli core update-index && \
    arduino-cli core install arduino:avr && \
    # arduino-cli core install arduino:megaavr && \
    # ATTinyCore https://github.com/SpenceKonde/ATTinyCore
    arduino-cli --additional-urls http://drazzy.com/package_drazzy.com_index.json core install ATTinyCore:avr && \
    # MiniCore: An Arduino core for the ATmega328, ATmega168, ATmega88, ATmega48 and ATmega8
    arduino-cli --additional-urls https://mcudude.github.io/MiniCore/package_MCUdude_MiniCore_index.json core install MiniCore:avr && \
    # ESP32
    arduino-cli --additional-urls https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json core install esp32:esp32 && \
    [ -d /app ] || mkdir /app

WORKDIR /app

CMD ["/bin/bash"]
