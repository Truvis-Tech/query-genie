#!/bin/bash

# Find the first matching .whl file
WHEEL_FILE=$(ls trulens-*-py3-none-any.whl 2>/dev/null | head -n 1)

# Check if a matching file was found
if [[ -z "$WHEEL_FILE" ]]; then
  echo "No matching .whl file (trulens-*-py3-none-any.whl) found in the current directory."
  exit 1
fi

echo "📦 Installing: $WHEEL_FILE"
pip install "$WHEEL_FILE"

if [[ $? -ne 0 ]]; then
  echo "pip install failed."
  exit 1
fi

echo "Running: trulens-app"
trulens-app
