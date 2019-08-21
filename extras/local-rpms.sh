#!/bin/bash

set -e

VERSION=$(./scripts/pkg-version --version)
RELEASE=$(./scripts/pkg-version --release)
FULL_VERSION=$(./scripts/pkg-version --full)

SIGN=no make dist-vendor

DISTARCHIVE="gluster-prometheus-exporter-$FULL_VERSION-vendor.tar.xz"
SPEC=gluster-prometheus-exporter.spec

/usr/bin/cp ./extras/rpms/$SPEC ./

sed -i -E "
# Use bundled always
s/with_bundled 0/with_bundled 1/;
# Replace version with HEAD version
s/%global gluster_prom_ver[[:space:]]+(.+)$/%global gluster_prom_ver $VERSION/;
# Replace release with proper release
s/%global gluster_prom_rel[[:space:]]+(.+)$/%global gluster_prom_rel $RELEASE/;
# Replace Source0 with generated archive
s/^Source0:[[:space:]]+.*.tar.xz/Source0: $DISTARCHIVE/;
" ./$SPEC

cp ./$DISTARCHIVE ~/rpmbuild/SOURCES
cp ./$SPEC ~/rpmbuild/SPECS
rpmbuild -ba ~/rpmbuild/SPECS/$SPEC
