#!/bin/bash
#SBATCH -t 0-8:30                         # Runtime in D-HH:MM format
#SBATCH -p bch-compute                    # Partition to run in
#SBATCH --mem=10GB 


#############################
# Input data
#############################

# GTEx vcf (downloaded directly from DB-GAP)
input_vcf_file="/lab-share/CHIP-Strober-e2/Public/GTEx/genotype_dbgap_download/GTEx_Analysis_2021-02-11_v9_WholeGenomeSeq_953Indiv.SHAPEIT2_phased.vcf.gz"

# eQTL summary statistics
gtex_v10_eqtl_sumstats_dir="/lab-share/CHIP-Strober-e2/Public/GTEx/eqtl_sumstats/"


#############################
# Output directories
#############################
variants_to_extract_dir="/lab-share/CHIP-Strober-e2/Public/ben/process_gtex_genotype_data/variants_to_extract/"

processed_genotype_dir="/lab-share/CHIP-Strober-e2/Public/ben/process_gtex_genotype_data/processed_genotype/"

tmp_genotype_dir="/lab-share/CHIP-Strober-e2/Public/ben/process_gtex_genotype_data/tmp_genotype"





#############################
# Code
#############################
if false; then
source ~/.bashrc
conda activate borzoi
python extract_variants_that_were_used_in_gtex_v10_eqtl_analysis.py $gtex_v10_eqtl_sumstats_dir ${variants_to_extract_dir}
fi

if false; then
source ~/.bashrc
conda activate plink_env
bcftools index -t $input_vcf_file
fi

if false; then
for chrom_num in {1..22}; do
	sbatch extract_chrom_specific_plink2_file.sh ${variants_to_extract_dir}"gtex_v10_eqtl_variants_chr"${chrom_num}".tsv" $input_vcf_file $chrom_num $processed_genotype_dir $tmp_genotype_dir ${variants_to_extract_dir}"gtex_v10_eqtl_variant_positions_chr"${chrom_num}".tsv"
done
fi



