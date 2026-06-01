#!/bin/bash
# prep_pca_final.sh



THREADS=4
CHR="${1:?Need CHR}"
INPUT_VCF="raw_merge_chr${CHR}.vcf.gz"




echo "----------------------------------------------------------------"
echo " CONVERTING TO PLINK FORMAT (BED/BIM/FAM)"
echo "----------------------------------------------------------------"

plink --threads $THREADS  \
      --vcf "$INPUT_VCF"  \
      --const-fid  --allow-no-sex \
      --set-missing-var-ids @:# \
      --new-id-max-allele-len 10 \
      --indep-pairwise 50 5 0.4 \
      --out "temp_chr${CHR}"


plink --threads $THREADS \
      --vcf "$INPUT_VCF" \
      --const-fid \
      --allow-no-sex \
      --extract "temp_chr${CHR}.prune.in" \
      --set-missing-var-ids @:# \
      --new-id-max-allele-len 10 \
      --make-bed \
      --out "chr${CHR}"
