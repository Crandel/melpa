## Settings

TOP := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

-include ./config.mk

ifeq ($(INSIDE_DOCKER), true)
PACKAGE_BUILD_DIRECTORY := $(TOP)/package-build
else ifndef PACKAGE_BUILD_DIRECTORY
PACKAGE_BUILD_DIRECTORY := $(TOP)/package-build
endif

INDEX_TARGETS ?= archive-contents json html

## MELPA Channels

MELPA_CHANNEL ?= unstable

ifeq ($(MELPA_CHANNEL), unstable)
PKGDIR  := packages
HTMLDIR := html
CHANNEL_CONFIG := "(progn\
  (setq package-build-stable nil)\
  (setq package-build-build-function 'package-build--build-multi-file-package)\
  (setq package-build-snapshot-version-functions '(package-build-timestamp-version))\
  (setq package-build-badge-data '(\"melpa\" \"\#922793\")))"

else ifeq ($(MELPA_CHANNEL), stable)
PKGDIR  := packages-stable
HTMLDIR := html-stable
CHANNEL_CONFIG := "(progn\
  (setq package-build-stable t)\
  (setq package-build-all-publishable nil)\
  (setq package-build-build-function 'package-build--build-multi-file-package)\
  (setq package-build-release-version-functions '(package-build-tag-version))\
  (setq package-build-badge-data '(\"melpa stable\" \"\#3e999f\")))"

else ifeq ($(MELPA_CHANNEL), snapshot)
# This is an experimental channel, which may
# eventually replace the "unstable" channel.
PKGDIR  := packages-snapshot
HTMLDIR := html-snapshot
CHANNEL_CONFIG := "(progn\
  (setq package-build-stable nil)\
  (setq package-build-badge-data '(\"snapshot\" \"\#30a14e\")))"

else ifeq ($(MELPA_CHANNEL), release)
# This is an experimental channel, which may
# eventually replace the "stable" channel.
PKGDIR  := packages-release
HTMLDIR := html-release
CHANNEL_CONFIG := "(progn\
  (setq package-build-stable t)\
  (setq package-build-badge-data '(\"release\" \"\#9be9a8\")))"

else
$(error Unknown MELPA_CHANNEL: $(MELPA_CHANNEL))
endif

HTMLDIRS = html html-stable html-snapshot html-release
PKGDIRS  = packages packages-stable packages-snapshot packages-release

include $(PACKAGE_BUILD_DIRECTORY)/package-build.mk

## MELPA Targets

PACKAGE_BUILD_REPO ?= "https://github.com/melpa/package-build"

pull-package-build:
	git fetch $(PACKAGE_BUILD_REPO)
	git -c "commit.gpgSign=true" subtree \
	$(shell test -e package-build && echo merge || echo add) \
	-m "Merge Package-Build $$(git describe --always FETCH_HEAD)" \
	--squash -P package-build FETCH_HEAD

helpall::
	$(info )
	$(info MELPA specific)
	$(info ==============)
	$(info make pull-package-build   Merge new package-build.el version)
help helpall::
	@echo
