import os
import platform
import subprocess
import sys


PLATFORM_MAP = {
    "Windows": "windows",
    "Darwin": "macos",
    "Linux": "linux",
}


def main():
    # Start Django backend
    backend = subprocess.Popen([sys.executable, "start_servers.py"])

    try:
        target = PLATFORM_MAP.get(platform.system(), "chrome")
        print(f"Running Flutter app on: {target}")
        subprocess.run(["flutter", "run", "-d", target], check=True)
    finally:
        backend.terminate()


if __name__ == "__main__":
    main()
