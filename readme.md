Sign

``` bash
CERT="Pavel Dřímalka"
APP="kfsNotes.app"

xattr -cr "$APP"

codesign --force --deep \
  --options runtime \
  --timestamp=none \
  --sign "$CERT" "$APP"

codesign --verify --deep --strict "$APP"
```


##homebrew

``` bash
brew tap k0fis/brews
brew install --cask kfsnotes
```
