
# Libgen

Shell Script to directly download book from [libgen](https://libgen.is/)

[![asciicast](https://asciinema.org/a/JXwkz25g1cgnFo4pzu8tQvnCS.png)](https://asciinema.org/a/JXwkz25g1cgnFo4pzu8tQvnCS)

> just a product of my procrastination

## Install

```console
git clone https://github.com/HarshitJoshi9152/libgen
cd libgen/
./libgen.sh book output_file.pdf
```

## Usage

`./libgen.sh BOOK OUTPUT_FILE`

Example

`./libgen.sh "The Communist Manifesto" commie.pdf`

## Dependencies

- [fzf](https://github.com/junegunn/fzf)
- [pug](https://github.com/ericchiang/pup)
- [jq](https://github.com/jqlang/jq)

## Roadmap

- [x] Show book info in fzf preview
- [ ] Show book thumbnail in preview
- [ ] Option to Download multiple books
- [ ] Add option to silently download in background and BELL when finished