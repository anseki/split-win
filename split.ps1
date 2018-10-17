# split-win
# https://github.com/anseki/split-win
#
# Copyright (c) 2015 anseki
# Licensed under the MIT license.

Param(
  [Parameter(Mandatory=$True)] [string] $path,
  [long] $size = 256mb, # split size 256mb
  [switch] $noJoin = $False,
  [switch] $noTest = $False,
  [switch] $noSum = $False
)

[long] $BUFFER_BYTES = 1024 * 80

if (-not (Test-Path $path)) {
  $Host.UI.WriteErrorLine('Specify a target file.')
  exit 1
}

[long] $srcBytes = $(Get-ChildItem $path).Length
'Target File: {0} ({1:#,0} bytes)' -f $path, $srcBytes
if ($srcBytes -le $size) {
  $Host.UI.WriteErrorLine('Specify a file larger than {0:#,0} bytes.' -f $size)
  exit 1
}

$path = $(Get-ChildItem $path).FullName
[IO.FileStream] $streamSrc = New-Object IO.FileStream(
  $path, [IO.FileMode]::Open, [IO.FileAccess]::Read)

[Collections.Generic.List[string]] $destList = New-Object Collections.Generic.List[string]

[int] $fileNum = 0
[IO.FileStream] $streamDest
[long] $destBytes = 0
[long] $readBytes = -1

while ($srcBytes -gt 0 -and $readBytes -ne 0) {
  if ($destBytes -ge $size -or $streamDest -eq $Null) {
    if ($streamDest -ne $Null) {
      $streamDest.Close()
      $destList.Add($pathDest)
      'Saved File: {0}' -f (Split-Path $pathDest -Leaf)
    }
    # New file
    $fileNum++
    [string] $pathDest = $path + '.' + $fileNum.ToString('000')
    $streamDest = New-Object IO.FileStream(
      $pathDest, [IO.FileMode]::Create, [IO.FileAccess]::Write)
    $destBytes = 0
  }

  [long] $copyBytes = $BUFFER_BYTES
  if ($copyBytes -gt $srcBytes) { $copyBytes = $srcBytes }
  if ($copyBytes -gt $size - $destBytes) { $copyBytes = $size - $destBytes }

  [byte[]] $data = New-Object byte[] $copyBytes
  $readBytes = $streamSrc.Read($data, 0, $copyBytes)
  $streamDest.Write($data, 0, $readBytes)
  $srcBytes -= $readBytes
  $destBytes += $readBytes
}
if ($streamDest -ne $Null -and $destBytes -gt 0) {
  $streamDest.Close()
  $destList.Add($pathDest)
  'Saved File: {0}' -f (Split-Path $pathDest -Leaf)
}
$streamSrc.Close()

# join command
[string] $cmdJoin = 'COPY /b ' + [string]::Join(' +', $destList.ToArray())

if (-not $noJoin) {
  # BAT to join files
  Out-File -FilePath ($path + '.join.bat') -Encoding Default -InputObject (
    $cmdJoin + ' ' + $path)
}

if (-not $noTest) {
  # BAT to join files test
  Out-File -FilePath ($path + '.join.test.bat') -Encoding Default -InputObject (
    $cmdJoin + ' ' + $path + ".tmp`r`n" +
    'fc /b ' + $path + ' ' + $path + '.tmp && del ' + $path + ".tmp`r`n" +
    "@echo Push any key to close...`r`n@pause > nul")
}

if (-not $noSum) {
  # Checksum list
  [string] $checksum = $path + '.checksum'
  Out-File -FilePath $checksum -Encoding Default -InputObject (
    (CertUtil -hashfile $path SHA1 | findstr -v ':').Replace(' ', '') +
    ' ' + (Split-Path $path -Leaf))
  foreach ($destPath in $destList) {
    Out-File -Append -FilePath $checksum -Encoding Default -InputObject (
      (CertUtil -hashfile $destPath SHA1 | findstr -v ':').Replace(' ', '') +
      ' ' + (Split-Path $destPath -Leaf))
  }
}

'OK'
