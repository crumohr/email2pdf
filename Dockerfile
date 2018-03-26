FROM phusion/baseimage:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_PACKAGES='git build-essential fakeroot checkinstall gdebi-core wget'
WORKDIR /tmp
COPY . /tmp/email2pdf/
RUN useradd -ms /bin/bash email2pdf && mkdir /var/email2pdf && chmod a+rw /var/email2pdf
RUN apt-get update && apt-get install -y $BUILD_PACKAGES \
        sudo \
        fontconfig \
        getmail4 \
        libfontconfig1 \
        libfreetype6 \
        libjpeg-turbo8 \
        libx11-6 \
        libxext6 \
        libxrender1 \
        python \
        python3-bs4 \
        python3-html5lib \
        python3-magic \
        python3-requests \
        python3-dateutil \
        python3-flake8 \
        python3-pip \
        python3-reportlab \
        python3-pypdf2 \
        python3-freezegun \
        xfonts-75dpi \
        xfonts-base && \
    wget -q -O wkhtmltox.tar.xz https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz && \
    fakeroot checkinstall --pkgname=wkhtmltox --pkgversion=0.12.4 -y --fstrans=no --install=no tar --xz -xvf wkhtmltox.tar.xz --strip-components=1 -C / && \
    fakeroot checkinstall --pkgname=python3-pdfminer3k --pkgversion=0.1 -y --fstrans=no --install=no pip3 install pdfminer3k && \
    dpkg -i *.deb && rm *.xz && rm *.deb && \
    make determineversion builddeb_real && dpkg -i *.deb && \
    ln -s /usr/share/fonts /usr/lib/x86_64-linux-gnu/fonts && \
    apt-get remove --purge -y $BUILD_PACKAGES && apt-get -y autoremove && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER email2pdf
RUN mkdir /home/email2pdf/.getmail
COPY getmailrc /home/email2pdf/.getmail/getmailrc

ENV QT_QPA_PLATFORM=offscreen
WORKDIR /var/email2pdf
CMD ["/sbin/my_init"]
