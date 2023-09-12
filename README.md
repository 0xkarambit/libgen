
# Libgen

Shell Script to directly download book from [libgen](https://libgen.is/)

> just a product of my procrastination

## Install

```console
git clone https://github.com/HarshitJoshi9152/libgen
cd libgen/
./get.sh book output_file.pdf
```

## Usage

`./get.sh [BOOK] [OUTPUT_FILE]`

Example

`./get.sh "The Communist Manifesto" commie.pdf`

## Dependencies

- fzf
- pug
- jq

## Roadmap

- Show book info in fzf preview
- Show book thumbnail in preview
- Option to Download multiple books
- Add option to silently download in background and BELL when finished