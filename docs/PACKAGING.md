# 📦 Packaging Rules

Never guess installer contents.

Known-good ZIP layout:

`KNOWN-GOOD-ZIP-CONTENTS.txt`

Every future ZIP must record:

- exact Git SHA
- branch
- kernel Image origin
- module set
- installer base
- SHA256
- experiment purpose
- rollback artifact

Never mix modules/images from different commits.
