FROM centos:latest

RUN dnf update -y && \
    dnf install -y make curl epel-release python3 && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    pip3 install pyserial && \
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh && \
    arduino-cli core update-index && \
    arduino-cli core install arduino:avr && \
    [ -d /app ] || mkdir /app

WORKDIR /app

CMD ["/bin/bash"]
