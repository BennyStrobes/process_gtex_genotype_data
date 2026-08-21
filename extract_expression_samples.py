import numpy as np
import os
import sys
import pdb
import gzip




def extract_expression_samples(expression_dir):
	dicti = {}
	for file_name in os.listdir(expression_dir):
		if file_name.endswith('expression.bed.gz') == False:
			continue
		full_filer = expression_dir + file_name
		f = gzip.open(full_filer,'rt')
		head_count = 0
		for line in f:
			line = line.rstrip()
			data = line.split('\t')
			if head_count > 0:
				break
			for samp_id in np.asarray(data[4:]):
				info = samp_id.split('-')
				if len(info) != 2 or info[0] != 'GTEX':
					print('assumptinoeroroor')
					pdb.set_trace()
				dicti[samp_id] = 1
			head_count = head_count + 1
		f.close()
	return dicti




#####################
# Command line args
#####################
plink2_output_stem = sys.argv[1]
output_file = sys.argv[2]
expression_dir = sys.argv[3]



expr_samples_dicti = extract_expression_samples(expression_dir)

input_file = plink2_output_stem + '.psam'
f = open(input_file)
t = open(output_file,'w')
used = {}
head_count = 0
for line in f:
	line = line.rstrip()
	data = line.split('\t')
	if head_count == 0:
		head_count = head_count + 1
		t.write('#IID\n')
		continue
	samp_info = data[0].split('-')
	new_name = samp_info[0] + '-' + samp_info[1]
	if new_name in expr_samples_dicti:
		t.write(data[0] + '\n')
		used[data[0]] =1
f.close()
t.close()
