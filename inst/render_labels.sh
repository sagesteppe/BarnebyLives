#!/bin/bash

# Loop through named arguments
for arg in "$@"; do
   case "$arg" in
      collector=*) collector="${arg#*=}" ;;
   esac
done

mkdir ${collector}-processed
files=$(find ${collector}-raw -mindepth 1 | sort -Vt / -k2,2)
for (( i=0; i<${#files[*]}; i+=4 ));
do
  filename="${files[i]##*/}"
  pdfjam "${files[@]:$i:4}" --nup 2x2 --landscape --outfile ${collector}-processed/$filename --noautoscale true --quiet
done

mkdir ../final
files=$(find ${collector}-processed | sort -Vt / -k2,2)
pdftk ${files[*]} output ../final/${collector}-labels.pdf

echo "final labels are located at: final/${collector}-labels.pdf"

#rm ${collector}-raw -r
rm ${collector}-processed -r
