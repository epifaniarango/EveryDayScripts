#!/bin/bash
# merge_and_pca_v2.sh

THREADS=4
MEM=32000 




rm -f merge_list.txt
for CHR in {2..22}; do
    echo "chr${CHR}.bed chr${CHR}.bim chr${CHR}.fam" >> merge_list.txt
done


plink --threads $THREADS --memory $MEM \
      --bfile chr1 \
      --set-missing-var-ids @:# \
      --merge-list merge_list.txt \
      --make-bed \
      --out data

