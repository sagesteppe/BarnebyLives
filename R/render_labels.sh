#!/bin/bash

# Loop through arguments
for arg in "$@"; do
   case "$arg" in
      collector=*) collector="${arg#*=}" ;;
   esac
done

mkdir processed-${collector}

files=(raw-${collector}/*)
for (( i=0; i<${#files[*]}; i+=4 ));
do
  filename="${files[i]##*/}"
  pdfjam "${files[@]:$i:4}" --nup 2x2 --landscape --outfile processed-${collector}/$filename --noautoscale true
done

files=("processed-${collector}/*")
pdftk ${files[*]} output final/${collector}-labels.pdf

echo "final labels are located at: final/${collector}-labels.pdf"

rm -r raw-${collector}
rm -r processed-${collector}
