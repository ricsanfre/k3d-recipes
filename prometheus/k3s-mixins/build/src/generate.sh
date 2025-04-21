#!/bin/sh

set -e # Exit on any error
set -u # Treat unset variables as an error

# Define paths
MIXINS_DIR="./templates"

# Function to escape YAML content
escape_yaml() {
  local file_path="$1"
  echo "Escaping $file_path..."
  # Read the file content, process, and overwrite it
  sed -i \
    -e 's/{{/{{`{{/g' \
    -e 's/}}/}}`}}/g' \
    -e 's/{{`{{/{{`{{`}}/g' \
    -e 's/}}`}}/{{`}}`}}/g' \
    "$file_path"
  echo "Escaped $file_path."
}

# Clean the templates directory
echo "Cleaning templates directory..."
rm -rf ${MIXINS_DIR}/*
echo "Templates directory cleaned."

# Convert Jsonnet to YAML
echo "Converting Jsonnet to YAML..."
jsonnet main.jsonnet -J vendor -m ${MIXINS_DIR} | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml' -- {}
echo "Jsonnet conversion completed."

# Remove all non-YAML files
echo "Removing non-YAML files..."
find ${MIXINS_DIR} -type f ! -name "*.yaml" -exec rm {} +
echo "Non-YAML files removed."

# Escape YAML files
echo "Escaping YAML files..."
find ${MIXINS_DIR} -name '*.yaml' | while read -r file; do
  escape_yaml "$file"
done
echo "YAML files escaped."

echo "Processing completed successfully!"
