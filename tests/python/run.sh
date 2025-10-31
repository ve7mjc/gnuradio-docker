#!/bin/bash
set -euo pipefail

find_python_package() {
    local pkg="$1"
    [[ -z "$pkg" ]] && { echo "Usage: find_python_package <package_name>"; return 1; }

    shopt -s nullglob
    local roots=(/usr/local/lib/python* /usr/lib/python* "$HOME/.local/lib/python*")
    local results=()

    for root in "${roots[@]}"; do
        [[ -d "$root" ]] || continue
        while IFS= read -r path; do
            # Trim to package directory if a file path matched
            [[ "$path" == */__version__.py ]] && path="${path%/__version__.py}"
            results+=("$path")
        done < <(find "$root" -type d -path "*-packages/${pkg}" -o -type f -path "*-packages/${pkg}/__version__.py" 2>/dev/null)
    done

    if ((${#results[@]})); then
        printf '%s\n' "${results[@]}" | sort -u
    else
        echo "Not found"
    fi
}



VENV_PATH="${1:-.venv}"
REQ_FILE="${2:-requirements.txt}"

init_python_venv() {

  # Create venv if missing or incomplete
  if [ ! -d "$VENV_PATH" ] || [ ! -f "$VENV_PATH/bin/activate" ]; then
    echo "Creating Python virtual environment at $VENV_PATH"
    python3 -m venv "$VENV_PATH"
  fi

  # Activate venv
  # shellcheck disable=SC1090
  source "$VENV_PATH/bin/activate"

  # Install requirements only if not already satisfied
  if [ -f "$REQ_FILE" ]; then
    echo "Installing/updating dependencies from $REQ_FILE"
    python -m pip install --requirement "$REQ_FILE" --upgrade --quiet
  else
    echo "No $REQ_FILE found, skipping."
  fi

}

# find /usr /usr/local -type d -path "*/gnuradio" | grep site-packages

# /usr/lib/python3.12/site-packages/ <- volk_modtool
# ls -latr /usr/lib/python3.12/dist-packages/
# gnuradio -> /usr/local/lib/python3.12/dist-packages/
# ls -latr /usr/local/lib/python3.12/dist-packages/
# ls -latr /usr/local/lib/python3.12/site-packages/

# find / | grep numpy

export PYTHONPATH="/usr/lib/python3/site-packages:/usr/lib/python3.12/site-packages:/usr/local/lib/python3.12/dist-packages:${PYTHONPATH:-}"

echo "Found Python packages at location(s):"
echo "- gnuradio: $(find_python_package gnuradio)"
echo "- requests: $(find_python_package requests)"
echo "- satellites: $(find_python_package satellites)"

python main.py
