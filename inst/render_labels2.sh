#!/bin/bash
for arg in "$@"; do
   case "$arg" in
      collector=*) collector="${arg#*=}" ;;
   esac
done

mkdir -p "${collector}-processed"
files=($(ls ${collector}-raw/* | sort -Vt / -k2,2))

if command -v pdfjam >/dev/null 2>&1; then
   echo 
   for (( i=0; i<${#files[*]}; i+=4 )); do
      filename="${files[i]##*/}"
      pdfjam "${files[@]:$i:4}" \
         --nup 2x2 \
         --landscape \
         --outfile "${collector}-processed/$filename" \
         --noautoscale true \
         --quiet
   done
else
   echo "pdfjam not detected — using ImageMagick (rasterizing)"
   if ! command -v convert >/dev/null 2>&1; then
      echo "Error: neither pdfjam nor ImageMagick found."
      exit 1
   fi
   for (( i=0; i<${#files[*]}; i+=4 )); do
      filename="${files[i]##*/}"
      montage -density 400 "${files[@]:$i:4}" \
         -tile 2x2 -geometry +0+0 \
         "${collector}-processed/$filename"
   done
fi

# Combine all processed PDFs into final
mkdir -p ../final
files=($(ls "${collector}-processed"/* | sort -V))

if command -v pdftk >/dev/null 2>&1; then
   pdftk "${files[@]}" cat output "../final/${collector}-labels.pdf"
else
   echo "pdftk not found — using ImageMagick to combine (rasterized)"
   convert "${files[@]}" "../final/${collector}-labels.pdf"
fi

echo "Final labels located at: ../final/${collector}-labels.pdf"

# Cleanup
rm -rf "${collector}-raw" "${collector}-processed"
