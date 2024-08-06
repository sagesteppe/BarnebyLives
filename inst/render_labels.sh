#!/bin/bash
for arg in "$@"; do
   case "$arg" in
      collector=*) collector="${arg#*=}" ;;
   esac
done

mkdir ${collector}-processed
files=($(ls ${collector}-raw/* | sort -Vt / -k2,2))
for (( i=0; i<${#files[*]}; i+=4 ));
do
  filename="${files[i]##*/}"
  pdfjam "${files[@]:$i:4}" --nup 2x2 --landscape --outfile ${collector}-processed/$filename --noautoscale true --quiet
done

mkdir ../final
files=($(ls ${collector}-processed/* | sort -Vt / -k2,2))
pdftk ${files[*]} output ../final/${collector}-labels.pdf

echo "final labels are located at: final/${collector}-labels.pdf"

rm ${collector}-raw -r
rm ${collector}-processed -r
