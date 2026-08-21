#!/bin/bash
#SBATCH -t 0-2:30                         # Runtime in D-HH:MM format
#SBATCH -p bch-compute                    # Partition to run in
#SBATCH --mem=10GB 


TARGET="${1}"
VCF="${2}"
chrom_num="${3}"
processed_genotype_dir="${4}"
TMPDIR="${5}"
TARGET_POS_FILE="${6}"

OUT="${processed_genotype_dir}/gtex_v9_eqtl_chr${chrom_num}"

echo $chrom_num

source ~/.bashrc
conda activate plink_env

echo "PART1"
bcftools norm \
  -m -any \
  -r "chr${chrom_num}" \
  -R ${TARGET_POS_FILE} \
  -Oz \
  -o "${TMPDIR}/chr${chrom_num}.split.vcf.gz" \
  "${VCF}"


echo "PART2"

bcftools index -t "${TMPDIR}/chr${chrom_num}.split.vcf.gz"


echo "PART3"

awk 'BEGIN{FS=OFS="\t"} {print $1":"$2":"$3":"$4}' "${TARGET}" | sort -u > "${TMPDIR}/target_keys${chrom_num}.txt"
awk 'BEGIN{FS=OFS="\t"} {print $1, $2}' "${TARGET}" | sort -u > "${TMPDIR}/target_positions${chrom_num}.tsv"

echo "PART4"

bcftools view \
  -R "${TMPDIR}/target_positions${chrom_num}.tsv" \
  -Ou "${TMPDIR}/chr${chrom_num}.split.vcf.gz" | \
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\n' | \
awk 'BEGIN{FS=OFS="\t"} {print $1":"$2":"$3":"$4}' | \
grep -Fwf "${TMPDIR}/target_keys${chrom_num}.txt" | \
sort -u > "${TMPDIR}/extract_ids${chrom_num}.txt"


echo "PART5"

bcftools view \
  -v snps \
  -Oz \
  -o "${TMPDIR}/chr${chrom_num}.split.snps.vcf.gz" \
  "${TMPDIR}/chr${chrom_num}.split.vcf.gz"

bcftools index -t "${TMPDIR}/chr${chrom_num}.split.snps.vcf.gz"


echo "PART6"

plink2 \
  --vcf "${TMPDIR}/chr${chrom_num}.split.snps.vcf.gz" \
  --set-all-var-ids chr@:#:\$r:\$a \
  --make-pgen \
  --out "${TMPDIR}/chr${chrom_num}.split.snps.with_ids"




echo "PART7"
plink2 \
  --pfile "${TMPDIR}/chr${chrom_num}.split.snps.with_ids" \
  --extract "${TMPDIR}/extract_ids${chrom_num}.txt" \
  --make-pgen \
  --out "${OUT}"





