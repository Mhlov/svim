CURRENT_DIR=$(shell pwd -P)

TARGET_BIN_DIR=${HOME}/bin

BIN_NAME=svim.pl
TARGET_BIN=${TARGET_BIN_DIR}/${BIN_NAME}
ORIGINAL_BIN=${CURRENT_DIR}/bin/${BIN_NAME}

BIN_NAME2=update-desktop-vi-server.pl
TARGET_BIN2=${TARGET_BIN_DIR}/${BIN_NAME2}
ORIGINAL_BIN2=${CURRENT_DIR}/bin/${BIN_NAME2}


help: help
	@echo "Usage:"
	@echo "\tInstall/symlink/uninstall all:"
	@echo "\tmake install | link | uninstall\n"
	@echo "\tInstall/symlink/uninstall svim:"
	@echo "\tmake install_svim | link_svim | uninstall_svim\n"
	@echo "\tInstall/symlink/uninstall update-desktop-vi-server:"
	@echo "\tmake install_udvs | link_udvs | uninstall_udvs"


install: install_svim install_udvs

link: link_svim link_udvs

uninstall: uninstall_svim uninstall_udvs


install_svim: copy_svim

link_svim: symlink_svim

uninstall_svim: delete_svim


install_udvs: copy_udvs

link_udvs: symlink_udvs

uninstall_udvs: delete_udvs


copy_svim:
	@test -e "${TARGET_BIN}" || \
		cp "${ORIGINAL_BIN}" "${TARGET_BIN}"


copy_udvs:
	@test -e "${TARGET_BIN2}" || \
		cp "${ORIGINAL_BIN2}" "${TARGET_BIN2}"


symlink_svim:
	@test -e "${TARGET_BIN}" || \
		ln -s "${ORIGINAL_BIN}" "${TARGET_BIN}"


symlink_udvs:
	@test -e "${TARGET_BIN2}" || \
		ln -s "${ORIGINAL_BIN2}" "${TARGET_BIN2}"


delete_svim:
	@test -e "${TARGET_BIN}" && \
		rm "${TARGET_BIN}"


delete_udvs:
	@test -e "${TARGET_BIN2}" && \
		rm "${TARGET_BIN2}"

