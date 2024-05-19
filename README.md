# maybe_rendering_bug

## Set up

```
gleam add lustre tardis
gleam add --dev lustre_dev_tools
gleam run -m lustre/dev start
```

Add `target = "javascript"` to `gleam.toml`.

## Example debugger session

See the video in `./example/gleam_lustre_maybe_rendering_bug.mp4` for a debugging session with tardis and the browser debugger.  Breakpoint is set on attribute modifications of the canvas element.
