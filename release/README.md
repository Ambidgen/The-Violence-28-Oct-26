# release/

`TheViolence.exe` — the single-file Windows build — belongs in this folder.

It is not committed: GitHub rejects files over 100 MB and this one is 107 MiB.
Attach it to a GitHub Release instead. Rebuild it with:

```sh
tools/build_windows_exe.sh
```

See `../RELEASE.md` for what is inside it and how it was produced.
