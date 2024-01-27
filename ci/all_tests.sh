#!/usr/bin/env bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

if [ -z "${ROC}" ]; then
  echo "ERROR: The ROC environment variable is not set.
    Set it to something like:
        /home/username/Downloads/roc_nightly-linux_x86_64-2023-10-30-cb00cfb/roc
        or
        /home/username/gitrepos/roc/target/build/release/roc" >&2

  exit 1
fi

EXAMPLES_DIR='./examples'
PACKAGE_DIR='./package'

# roc check
for ROC_FILE in $EXAMPLES_DIR/*.roc; do
    $ROC check $ROC_FILE
done

# roc build
for ROC_FILE in $EXAMPLES_DIR/*.roc; do
    $ROC build $ROC_FILE --linker=legacy
done

# check output
for ROC_FILE in $EXAMPLES_DIR/*.roc; do
    ROC_FILE_ONLY="$(basename "$ROC_FILE")"
    NO_EXT_NAME=${ROC_FILE_ONLY%.*}
    expect ci/expect_scripts/$NO_EXT_NAME.exp
done

# test building docs website
$ROC docs $PACKAGE_DIR/main.roc