# drago

Drag and drop files out of the terminal on macOS — a native AppKit take on
[dragon](https://github.com/mwh/dragon) / [ripdrag](https://github.com/nik012003/ripdrag),
without GTK.

`drago file.pdf` opens a small window listing the file;
drag it into Mail, a browser upload field, Finder or any other app.
`drago --target` does the reverse:
drop files onto the window and their paths are printed to stdout.

## Install

Requires macOS 12+ and the Xcode command-line tools (`xcode-select --install`).

```sh
brew install xeruf/tap/drago
```

Or from source:

```sh
git clone https://github.com/xeruf/drago && cd drago
make install                 # installs to /usr/local/bin
make install PREFIX=~/.local # or anywhere else
```

## Usage

```sh
drago report.pdf photo.jpg   # one draggable row per file
drago -x -a *.pdf            # extra "All N items" row, exit after the first drag
drago -A -x .                # only the all-at-once row
drago -t                     # drop target: prints dropped paths/URLs, then exits
drago -t -k | while read -r f; do cp "$f" ~/inbox; done  # keep accepting drops
fd -e png | drago -I -x      # read paths from stdin
```

| Flag | |
| --- | --- |
| `-x`, `--and-exit` | exit after the first successful drag or drop |
| `-a`, `--all` | add an item that drags all files at once |
| `-A`, `--all-compact` | show only the all-at-once item |
| `-t`, `--target` | act as a drop target and print dropped paths/URLs |
| `-k`, `--keep` | with `--target`: keep accepting drops |
| `-p`, `--print-path` | print the path of each dragged file |
| `-T`, `--on-top` | keep the window above other windows (default, accepted for dragon compatibility) |
| `-N`, `--no-on-top` | let other windows cover it |
| `-i`, `--icon-only` | show only icons |
| `-I`, `--stdin` | read additional paths from stdin |

Without file arguments and without `--stdin`, `--target` is implied.
<kbd>Esc</kbd> closes the window.

The short flags match dragon's where they overlap,
so a wrapper like `drag() { dragon -x -a "$@"; }` works unchanged on both platforms.

## Related

- [dragon](https://github.com/mwh/dragon) (GTK3) and [ripdrag](https://github.com/nik012003/ripdrag) (GTK4) — the Linux originals;
  on macOS they need a full GTK install and have open drag issues.
- [dragterm](https://github.com/Wevah/dragterm) — native drag-out under the cursor;
  no drop target or batch options.

## Development

```sh
swift build        # debug build → .build/debug/drago
swift test         # unit tests for option parsing / path handling
```

## License

[GPL-3.0](LICENSE)
