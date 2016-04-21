# split-win

A `split` command for Windows which likes that of the non-Windows. And some tools.

This splits a big file to specific size files. And also, it creates a list of file checksum and a BAT file that joins the split files into a file (i.e. an original file).

## Usage

It is recommended to save the `split.ps1` and `split.cmd` files into the `Path` folder such as `C:\Windows\System32`, to be able to use from anywhere.

Run this command in console:

```console
split target-file
```

Or, you can drag & drop a target file to a `split.cmd` icon.

For example, `split test.jpg` was run, and then, these files were created:

```
test.jpg.001
test.jpg.002
test.jpg.003
test.jpg.checksum
test.jpg.join.bat
test.jpg.join.test.bat
```

- `test.jpg.001` ... `test.jpg.N`: The split files. The number of files differs depending on the [`-size` option](#-size) and the size of original file.
- `test.jpg.checksum`: A list of file checksum (SHA1).
- `test.jpg.join.bat`: A BAT file to join the split files into a file (i.e. an original file).
- `test.jpg.join.test.bat`: A BAT file to test whether the joined file and the original file are perfect equal.

## `split` Command

```console
split <target-file-path>
```

```console
split -path <target-file-path> [-size <split-size>] [-noJoin] [-noTest] [-noSum]
```

```console
split <target-file-path> [<split-size>] [-noJoin] [-noTest] [-noSum]
```

### `-path`

The target file path.

### `-size`

The size of the split files that is a number as bytes or a number with an unit such as `5kb`, `5mb`, `5gb`, etc..  
This is optional. The default is `256mb`.

For example, split a `test.zip` to 640mb files.

```console
split -size 640mb test.zip
```

### `-noJoin`

Don't create a BAT file to join the split files into a file.  
This is optional.

### `-noTest`

Don't create a BAT file to test.  
This is optional.

### `-noSum`

Don't create a list of file checksum.  
This is optional.
