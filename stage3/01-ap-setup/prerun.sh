#!/bin/bash -e

chmod 644 files/*.conf || true
chmod 644 files/*.service || true
chmod 755 files/*.sh || true
chmod 755 files/*.py || true
chmod 755 files/setup-server.py || true
chmod 644 files/ap-setup.service || true