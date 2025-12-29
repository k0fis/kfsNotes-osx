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

`ditto -c -k --sequesterRsrc --keepParent kfsNotes.app ../kfsNotes_2025-12-29_12-24-00.zip`



``` bash
brew tap k0fis/kfsnotes
brew install --cask kfsnotes
```

## First launch on macOS

kfsNotes is distributed outside the Mac App Store and is signed with a self-signed certificate.

On first launch, macOS may block the app with a security warning.

### How to open kfsNotes for the first time

1. Open **Applications**
2. Right-click **kfsNotes**
3. Choose **Open**
4. Confirm **Open** in the dialog

Alternatively:
- Go to **System Settings → Privacy & Security**
- Click **Open Anyway** next to kfsNotes

After the first launch, the app will open normally.

> This warning is expected and does **not** indicate malware.
