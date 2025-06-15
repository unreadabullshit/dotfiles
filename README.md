# DOTFILES

## Disclaimer
The files inside the "/link" folder and the program inside "/linker" were tailored for my personal use, tested only on my systems(MacOS and whatever linux distro I'm using currently), feel free to copy some of these but I can't ensure they'll work on your system!!

## Setup

On the **link-map.txt**, write where your folder/file should be linked to like:

`RELATIVE_PATH_TO_FILE_OR_FOLDER:WHERE_THE_SYMLINK_SHOULD_BE_CREATED`

Eg.:

```bash
./link/nvim:~/.config/nvim  #folder
./link/.zsh:~/.zsh          #file
```

- the "link" folder is just a suggestion, you can rename the folder or use more than one, they just have to be properly written at the link-map.txt

Also, notice that the `origin` path **should** be relative to the working directory of this project while the `target` path **have** to be an absolute path starting from the user home path ("~/").

> check the functions **getTargetPath** and **getOriginPath** at `linker/src/main.zig` if you wanna know why.

## Run the linker program

run on your terminal when inside the project folder:

```bash
./dotfiles
```

### success

On success you'll see where each file/folder ended being liked to like this:

![](/examples/success%20example.png)

### error

On error, the program will tell you what could have gone wrong:

![](/examples/erros%20example.png)

## Tweak the linker

The program is simple and made using Zig, on a nutshell it will read the contents of the link-map.txt, do some validations and then link the paths.

Edit whatever you need on it and then run using the `dev` flag

```bash
# at: /dotfiles/linker/
zig run src/main.zig -- dev
```

> if you run it from the project root(/dotfiles), you don't have to use the dev flag since its only purpose it to set the cwd one level down.

The build output is located at /linker/zig-out/bin/ and you can replace the "dotfiles" file at the project root with it.
