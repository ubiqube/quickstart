#!/bin/bash
. /usr/share/install-libraries/il-lib.sh

emit_step "Remove old msa_sdk folders."
rm -Rf /opt/fmc_repository/Process/PythonReference/msa_sdk*
ln -sf /opt/fmc_repository/python-sdk/msa_sdk /opt/fmc_repository/Process/PythonReference/msa_sdk
emit_step "Create custom folder."
mkdir -p /opt/fmc_repository/Process/PythonReference/custom
touch /opt/fmc_repository/Process/PythonReference/custom/__init__.py
