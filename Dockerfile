FROM ubuntu:latest

# https://serverfault.com/a/1016972
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV TZ=US/Chicago

RUN apt update -y \
    && apt install -y asterisk

CMD /usr/sbin/asterisk -g -f -p -c -vvvvv
