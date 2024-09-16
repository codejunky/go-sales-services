# Check to see if we can use ash, in Alpine images, or default BASH
SHELL_PATH = /bin/ash
SHEL = $(if $(wildcard $SHELL_PATH)),/bin/ash,/bin/bash

run:
		go run app/services/sales-api/main.go