#!/usr/bin/env bash
# Start the local UI directly from source; never install or update anything.
set -euo pipefail

fail() {
    printf 'AIO: %s\n' "$*" >&2
    exit 1
}

AIO_ROOT=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
UI_SRC="$AIO_ROOT/KohakuMoss-UI/src"
TRAINER_ROOT="$AIO_ROOT/KohakuMossTrainer"
TRAINER_PYTHON="$TRAINER_ROOT/.venv/bin/python"

[[ -f "$UI_SRC/kohakumoss_ui/__main__.py" && -f "$UI_SRC/kohakumoss_ui/cli.py" ]] ||
    fail "UI source is missing. Initialize the KohakuMoss-UI submodule yourself; no Git commands were run."
[[ -f "$TRAINER_ROOT/scripts/train/moss.py" && -d "$TRAINER_ROOT/configs" ]] ||
    fail "Trainer scripts/configs are missing. Initialize the KohakuMossTrainer submodule yourself; no Git commands were run."

# -I isolates the probe from inherited PYTHONPATH; the UI launch keeps it below.
probe_python() {
    [[ -f "$1" && -x "$1" ]] || return 1
    SELECTED_PYTHON=$("$1" -I -c 'import sys; sys.exit("Python >=3.11 required") if sys.version_info < (3, 11) else print(sys.executable)' 2>/dev/null)
}

SELECTED_PYTHON=
if [[ ${AIO_PYTHON+x} ]]; then
    probe_python "$AIO_PYTHON" || fail "AIO_PYTHON is not a working Python >=3.11 executable: $AIO_PYTHON"
elif [[ -e "$TRAINER_ROOT/.venv" || -L "$TRAINER_ROOT/.venv" ]]; then
    probe_python "$TRAINER_PYTHON" || fail "Trainer .venv is broken or needs Python >=3.11: $TRAINER_PYTHON. Repair it or explicitly set AIO_PYTHON."
elif [[ -e "$AIO_ROOT/KohakuMoss-UI/.venv" || -L "$AIO_ROOT/KohakuMoss-UI/.venv" ]]; then
    probe_python "$AIO_ROOT/KohakuMoss-UI/.venv/bin/python" || fail "UI .venv is broken or needs Python >=3.11. Repair it or explicitly set AIO_PYTHON."
else
    for name in python3 python; do
        candidate=$(command -v "$name" || true)
        if probe_python "$candidate"; then
            break
        fi
    done
    [[ -n "$SELECTED_PYTHON" ]] || fail "No working Python >=3.11 found. Install an environment yourself or set AIO_PYTHON to its executable."
fi

export PYTHONPATH="$UI_SRC${PYTHONPATH:+:$PYTHONPATH}"
if [[ -d "$TRAINER_ROOT/.venv/bin" ]]; then
    export PATH="$TRAINER_ROOT/.venv/bin:$PATH"
fi
if [[ ! ${KOHAKUMOSS_PYTHON+x} ]]; then
    if [[ -f "$TRAINER_PYTHON" && -x "$TRAINER_PYTHON" ]]; then
        export KOHAKUMOSS_PYTHON="$TRAINER_PYTHON"
    else
        export KOHAKUMOSS_PYTHON="$SELECTED_PYTHON"
    fi
fi
# Grabber root/interpreter discovery stays with the UI, respecting its overrides.
# A later --root argument takes precedence; relative arguments keep caller cwd.
exec "$SELECTED_PYTHON" -u -m kohakumoss_ui --root "$TRAINER_ROOT" "$@"
