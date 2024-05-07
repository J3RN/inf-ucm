# inf-ucm
[![License GPL 3][badge-license]](http://www.gnu.org/licenses/gpl-3.0.txt)

This is a package to allow you to interact with the Unison Codebase Manager (UCM).

## Features
- [ ] Run UCM (`inf-ucm`)
- [ ] Load current file into UCM (`inf-ucm-send-buffer`)

## TODO
- [ ] Got a feature you want to see? Open an issue! :smile:

## Installation

[`use-package`](https://github.com/jwiegley/use-package) can be used to install and/or configure `inf-ucm`:

``` elisp
(use-package inf-ucm
  :bind (("C-c u i" . 'inf-elixir)))
```

## Development

I am not yet using any kind of build tool (like [Eldev](https://github.com/doublep/eldev) or [Cask](https://github.com/cask/cask)) to develop this plugin. Generally speaking, working with the code involves:
1. Clone the git repository
2. Make some changes
3. Load your changes with `M-x load-file RET inf-elixir.el RET`
4. Verify your changes worked
5. Send a PR :pray:
