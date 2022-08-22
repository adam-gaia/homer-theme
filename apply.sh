#!/usr/bin/env bash
set -Eeuo pipefail

WORKING_DIR="${PWD}"
SOURCE_DIR="${WORKING_DIR}/assets"
TARGET_DIR="${HOME}/Data/homer"
TRASHCAN="${HOME}/.trash"
mkdir -p "${TRASHCAN}"

# Clean first
timestamp="$(date +%d-%m-%Y_%H-%M-%S)"
echo "Sudo password needed to remove old files"
for file in "${TARGET_DIR}/"*; do 
  file_name="$(basename "${file}")"
  trash_location="${TRASHCAN}/${file_name}_${timestamp}"
  sudo mv "${file:?}" "${trash_location}"
  sudo chown -R agaia:users "${trash_location}"
done

# Copy files
return_code=0
for source_file in "${SOURCE_DIR}/"*; do 
  source_full_path="$(realpath "${source_file}")"

  source_short_path="${source_full_path/${WORKING_DIR}/.}"
  source_name="$(basename "${source_full_path}")"
 
  target="${TARGET_DIR}/${source_name}"

  if ! cp -r "${source_full_path}" "${target:?}" &>/dev/null; then
    echo "[Error] Unable to copy ${source_short_path} to ${target}"
    return_code=1
  fi

  echo "[Success] Copied ${source_short_path} to ${target}"
done

echo "Sudo password needed to change permissions of linked files"
sudo chown --recursive root:root "${TARGET_DIR:?}/"*

exit "${return_code}"

