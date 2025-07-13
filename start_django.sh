#!/bin/bash

# Start the Django development server from the repository root.
# Uses a relative path so the script works on any machine.

set -e

# Resolve the directory of this script and change to the project root
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

# Activate the virtual environment if present
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
fi

# Launch Django
cd backend/emploi_django
python manage.py runserver 0.0.0.0:8000
