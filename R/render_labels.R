files=(raw/*)
for (( i=0; i<${#files[*]}; i+=4 ));
do
  filename="${files[i]##*/}"
  pdfjam "${files[@]:$i:4}" --nup 2x2 --landscape --outfile "processed/$filename" --noautoscale true
done

files=(processed/*)
pdftk ${files[*]} output final/labels.pdf
