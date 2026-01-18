 magick -background black -fill white \
  -font "/usr/share/fonts/TTF/IBMPlexSerif-Bold.ttf" -pointsize 72 \
  label:"CYNOSURE" \
  -resize 800x200! \
  -morphology Convolve "3x3: 0 0 0 1 0 1 0 0 0" \
  text_scan.png


 jp2a --width=100 --height=20 --chars=" .:*@&\$#" text_scan.png

