
all: prometheus-nginxlog-exporter

PACKAGE:=prometheus-nginxlog-exporter
VERSION:=$(shell git describe --dirty)

DESTDIR?=installdir
INSTALLDIR:=$(DESTDIR)/usr/sbin
ETCDIR:=$(DESTDIR)/etc

DEB?=$(shell find . -name "*.deb" -print -quit)

install:
	mkdir -p $(INSTALLDIR)
	mkdir -p $(ETCDIR)
	install -p prometheus-nginxlog-exporter $(INSTALLDIR)
	install -m a=r -p prometheus-nginxlog-exporter.yaml $(ETCDIR)

BUILD_DEP:= \
	golang \
	devscripts \

.PHONY: build-dep
build-dep:
	sudo apt install $(BUILD_DEP)

prometheus-nginxlog-exporter:
	CGO_ENABLED=0 \
	    go build -a -installsuffix cgo -o prometheus-nginxlog-exporter .

DEBEMAIL?=hamish.coleman@zerocap.com
DEBFULLNAME?="Auto Build"
export DEBEMAIL
export DEBFULLNAME
.PHONY: dpkg
dpkg:
	rm -f debian/changelog
	dch --create --empty --package $(PACKAGE) -v ${VERSION}-0 --no-auto-nmu local package Auto Build
	dpkg-buildpackage -rfakeroot -us -uc
	mv ../*.deb ./
