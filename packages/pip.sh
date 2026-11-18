package: pip
version: "%(tag_basename)s"
tag: 26.0.1 
sources:
- https://raw.githubusercontent.com/pypa/get-pip/refs/tags/%(version)s/public/get-pip.py
requires:
 - Python
 - setuptools
 - gcc
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
python3 $SOURCEDIR/get-pip.py \
  --no-setuptools \
  --no-wheel \
  pip==${PKGVERSION} \
  --prefix="$INSTALLROOT"

for py in $(grep -RlI -m1 '^#\!.*python' ${INSTALLROOT}/${PYTHON3_LIB_SITE_PACKAGES} | grep -v '\.pyc$') ; do
  lnum=$(grep -n -m1 '^#\!.*python' $py | sed 's|:.*||')
  sed -i -e "${lnum}c#!/usr/bin/env python3" $py
done

rm -f ${INSTALLROOT}/bin/pip
perl -p -i -e "s|^#!.*python.*|#!/usr/bin/env python3|" ${INSTALLROOT}/bin/pip3*
perl -p -i -e "s| ${WORK_DIR}/.*/python3 | python3 |" ${INSTALLROOT}/bin/pip3*
