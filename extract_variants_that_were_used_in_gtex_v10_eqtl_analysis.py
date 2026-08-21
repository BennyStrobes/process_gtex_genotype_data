import numpy as np
import os
import sys
import pdb
import pyarrow.parquet as pq
import pandas as pd
import pyarrow.compute as pc



def extract_ordered_list_of_all_variant_ids_on_this_chromosome(gtex_sumstats_dir, chrom_string):
	variants = {}

	for file_name in os.listdir(gtex_sumstats_dir):
		if not file_name.endswith('chr' + str(chrom_string) + '.parquet'):
			continue

		print(file_name)
		pf = pq.ParquetFile(gtex_sumstats_dir + file_name)

		for rg in range(pf.num_row_groups):
			table = pf.read_row_group(
				rg,
				columns=['gene_id', 'variant_id', 'tss_distance', 'af']
			)

			if table.num_columns == 0:
				continue

			gene_col = table['gene_id']
			variant_col = table['variant_id']
			dist_col = table['tss_distance']
			af_col = table['af']


			variant_ids = table['variant_id'].to_pylist()

			for variant_id in variant_ids:
				variants[variant_id] = 1
	return variants










eqtl_sumstats_dir = sys.argv[1]
variant_output_dir = sys.argv[2]


for chrom_num in range(1,23):
	print(chrom_num)

	# Extract ordered list of variant ids in this chromosome
	variant_ids = extract_ordered_list_of_all_variant_ids_on_this_chromosome(eqtl_sumstats_dir, str(chrom_num))

	t = open(variant_output_dir + 'gtex_v10_eqtl_variants_chr' + str(chrom_num) + '.tsv', 'w')
	t2 = open(variant_output_dir + 'gtex_v10_eqtl_variant_positions_chr' + str(chrom_num) + '.tsv', 'w')

	for variant_id in [*variant_ids]:
		var_info = variant_id.split('_')
		if len(var_info[2]) != 1 or len(var_info[3]) != 1:
			continue
		t.write(var_info[0] + '\t' + var_info[1] + '\t' + var_info[2] + '\t' + var_info[3] + '\n')
		t.write(var_info[0] + '\t' + var_info[1] + '\t' + var_info[3] + '\t' + var_info[2] + '\n')
		t2.write(var_info[0] + '\t' + var_info[1] + '\n')
	t.close()
	t2.close()
	print(variant_output_dir + 'gtex_v10_eqtl_variant_positions_chr' + str(chrom_num) + '.tsv')



