
all: prometheus-nginxlog-exporter

PACKAGE:=prometheus-nginxlog-exporter
VERSION:=$(shell git describe --dirty)
BUILD_DATE?=$(shell git log -1 --format=%cI)

# TODO: the following should have alternative values (some only work well
# when building locally, some only work well when building in actions)
BUILD_USER?=$(USER)
BUILD_SHA?=$(GITHUB_SHA)
BUILD_BRANCH?=$(GITHUB_REF_NAM)

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
	debhelper \
	devscripts \
	golang \

.PHONY: build-dep
build-dep:
	sudo apt install $(BUILD_DEP)

prometheus-nginxlog-exporter:
	CGO_ENABLED=0 go build \
	    -a -installsuffix cgo \
            -ldflags " \
	        -X github.com/prometheus/common/version.Version=$(VERSION) \
		-X github.com/prometheus/common/version.Branch=$(BUILD_BRANCH) \
		-X github.com/prometheus/common/version.Revision=$(BUILD_SHA) \
		-X github.com/prometheus/common/version.BuildUser=$(BUILD_USER) \
		-X github.com/prometheus/common/version.BuildDate=$(BUILD_DATE) \
	    " \
            -o prometheus-nginxlog-exporter .

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
