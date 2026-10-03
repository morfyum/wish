#!/bin/bash
sudo chcon -Rt container_file_t ../shared/

# One Fedora 44 the SELiunx give a wrong label to .msi files from web.
# Need to set container_file_t flag on these files,
# because sama share does not show non container_file_t files.
# TODO?: Use a template file with correct SELinux flag instead of this?
