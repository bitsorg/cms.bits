package: python-python3
version: "v1"
requires:
 - Python
---
mkdir $INSTALLROOT/bin/
ln -s $BITS_WORK_DIR/$ARCHITECTURE/Python/$PYTHON_VERSION-$PYTHON_REVISION/bin/python3 $BITS_WORK_DIR/$ARCHITECTURE/Python/$PYTHON_VERSION-$PYTHON_REVISION/bin/python
