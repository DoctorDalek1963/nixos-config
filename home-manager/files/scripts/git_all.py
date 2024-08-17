#!/usr/bin/env python
"""A simple script to run 'git status' in all directories in the current directory."""

import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from typing import Callable
import rich


def info(string: str) -> None:
    """Pretty print an info message."""
    rich.print(f"[cyan][ {string} ][/cyan]")


def warning(string: str) -> None:
    """Pretty print a warning message."""
    rich.print(f"[red][ {string} ][/red]")


def git_one_dir(
    direc: str,
    rel_dir: str,
    command: str,
    results: dict[str, str],
    *,
    pipe: bool,
    progress: bool,
) -> None:
    """Run a git command in a single directory. Used for multithreading."""
    full_dir = os.path.join(direc, rel_dir)

    try:
        if ".git" not in os.listdir(full_dir):
            return

        if pipe:
            if progress:
                info(f"Running {command} in {rel_dir}")

            output = subprocess.run(
                ["git", "-C", full_dir, command], stdout=subprocess.PIPE, check=True
            )
            out = output.stdout.decode()

            if out.endswith("\n"):
                out = out[:-1]

            results[rel_dir] = out

            if progress:
                info(f"Run {command} in {rel_dir}")

            return

        if progress:
            info(f"Running {command} in {rel_dir}")

        # If we don't want to pipe it, just run it and use stdout
        subprocess.run(["git", "-C", full_dir, command], check=True)

        if progress:
            info(f"Run {command} in {rel_dir}")

    except NotADirectoryError:
        pass

    except subprocess.CalledProcessError:
        warning(f"{command} failed in {rel_dir}")


def git_all(
    direc: str, command: str, *, pipe: bool = False, progress: bool = False
) -> dict[str, str]:
    """Run the git command in all subdirectories. If piping, return a dict of results, else return an empty dict."""
    direc = os.path.expanduser(direc)  # Expand ~ as user's home dir
    all_dirs = os.listdir(direc)

    results: dict[str, str] = {}

    with ThreadPoolExecutor(len(all_dirs)) as tpe:
        _ = [
            tpe.submit(
                git_one_dir,
                direc,
                rel_dir,
                command,
                results,
                pipe=pipe,
                progress=progress,
            )
            for rel_dir in all_dirs
        ]

    # Sort results by the key, ignoring case
    # If we haven't piped anything, then this dictionary is empty
    return dict(sorted(results.items(), key=lambda item: item[0].lower()))


def status(direc: str) -> None:
    """Show the git status of every subdirectory of direc."""
    print()

    results = git_all(direc, "status", pipe=True)

    for directory, output in results.items():
        string = f"[bold cyan]{directory}:[/bold cyan]"

        if (("up to date" in output) or ("up-to-date" in output)) and (
            "nothing to commit" in output
        ):
            string += " [green]Clean[/green]"
        else:
            string += f"\n[red]{output}[/red]"

        rich.print(string)
        print()


def fetch(direc: str) -> None:
    """Fetch from the remote in every subdirectory of direc."""
    git_all(direc, "fetch", pipe=True, progress=True)


def pull(direc: str) -> None:
    """Pull from the remote in every subdirectory of direc."""
    git_all(direc, "pull", progress=True)


def push(direc: str) -> None:
    """Push to the remote in every subdirectory of direc."""
    git_all(direc, "push", progress=True)


command_dict: dict[str, Callable[[str], None]] = {
    "status": status,
    "fetch": fetch,
    "pull": pull,
    "push": push,
}


def main() -> None:
    """Do the main method."""
    recognised_commands = "\nRecognised commands:\n  " + "\n  ".join(
        command_dict.keys()
    )

    if len(sys.argv) == 1 or sys.argv[1] in ("-h", "--help"):
        print("Usage: git-all <command> [directory]")
        print(recognised_commands)
        return

    command = sys.argv[1]
    directory = sys.argv[2] if len(sys.argv) >= 3 else f"{os.environ['HOME']}/repos"

    if command in command_dict:
        command_dict[command](directory)

    else:
        print(f'Unrecognised command: "{command}"')
        print(recognised_commands)


if __name__ == "__main__":
    main()
