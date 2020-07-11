FROM centos:latest

RUN dnf update -y && \
    dnf install -y make curl epel-release && \
    dnf update -y && \
    dnf install -y screen && \
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh && \
    arduino-cli core update-index && \
    arduino-cli core install arduino:avr && \
    arduino-cli core install arduino:megaavr && \
    arduino-cli --additional-urls https://mcudude.github.io/MiniCore/package_MCUdude_MiniCore_index.json core install MiniCore:avr && \
    [ -d /app ] || mkdir /app

WORKDIR /app

CMD ["/bin/bash"]
