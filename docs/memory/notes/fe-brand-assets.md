# fe brand assets (2026-11-05, run 3 task-07)

- No `rsvg-convert`, ImageMagick, Inkscape or Pillow on the owner's Mac; PNGs are rendered with
  headless Chrome: inline the SVG in an HTML page, then `Google Chrome --headless
  --force-device-scale-factor=1 --default-background-color=00000000 --window-size=N,N
  --screenshot=out.png page.html` (transparent background works).
- The badge ring text is Inter 800; the app bundles only 400 to 700, so the render page loads
  Inter ExtraBold through `@font-face` (downloaded from Google Fonts to a temp dir, not committed).
- `flutter_launcher_icons` 0.14.4 wraps the adaptive foreground in a 16% `<inset>` by default;
  `adaptive_icon_foreground_inset: 0` is set because `icon-foreground-1024.png` already carries
  the 108dp padding (glove about 41dp tall, inside the 66dp safe zone).
- Glove bounding box in the 100-unit artboard: x 19.51..89.36, y 10.62..89.00 (Chrome getBBox),
  used to centre the glove in the icon SVGs.
