#!/bin/tcsh
#BSUB -n 1
#BSUB -W 900
#BSUB -J run_qiime
#BSUB -o stdout.run_qiime
#BSUB -e stderr.run_qiime
module load /usr/local/usrapps/bioinfo/modulefiles/qiime2/2021.8

qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path fastq_files/ --input-format CasavaOneEightSingleLanePerSampleDirFmt --output-path marten_paired-end-demux.qza
qiime demux summarize --i-data marten_paired-end-demux.qza --o-visualization marten-demux-subsample.qzv
qiime dada2 denoise-paired --i-demultiplexed-seqs marten_paired-end-demux.qza --p-trim-left-f 13 --p-trim-left-r 13 --p-trunc-len-f 150 --p-trunc-len-r 130 --o-table table.qza 
--o-representative-sequences rep-seqs.qza --o-denoising-stats denoising-stats.qza
qiime metadata tabulate --m-input-file denoising-stats.qza --o-visualization denoising-stats.qzv
qiime feature-table summarize --i-table table.qza --o-visualization table.qzv --m-sample-metadata-file marten_16S_metadata_QIIME.tsv
qiime feature-table tabulate-seqs --i-data rep-seqs.qza --o-visualization rep-seqs.qzv

qiime phylogeny align-to-tree-mafft-fasttree --i-sequences rep-seqs.qza --o-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza --o-tree unrooted-tree.qza --o-rooted-tree 
rooted-tree.qza

qiime diversity core-metrics-phylogenetic --i-phylogeny rooted-tree.qza --i-table table.qza --p-sampling-depth 10 --m-metadata-file marten_16S_metadata_QIIME.tsv --output-dir 
marten-dada-core-metrics-results-10

qiime diversity alpha-group-significance --i-alpha-diversity marten-dada-core-metrics-results-10/faith_pd_vector.qza --m-metadata-file marten_16S_metadata_QIIME.tsv --o-visualization 
marten-dada-core-metrics-results-10/faith-pd-group-significance-10.qzv

qiime diversity alpha-group-significance --i-alpha-diversity marten-dada-core-metrics-results-10/evenness_vector.qza --m-metadata-file marten_16S_metadata_QIIME.tsv --o-visualization 
marten-dada-core-metrics-results-10/evenness-group-significance-10.qzv

qiime diversity beta-group-significance --i-distance-matrix marten-dada-core-metrics-results-10/unweighted_unifrac_distance_matrix.qza --m-metadata-file marten_16S_metadata_QIIME.tsv 
--m-metadata-column Age --o-visualization marten-dada-core-metrics-results-10/unweighted-unifrac-body-site-significance-10.qzv --p-pairwise

qiime diversity beta-group-significance --i-distance-matrix marten-dada-core-metrics-results-10/unweighted_unifrac_distance_matrix.qza --m-metadata-file marten_16S_metadata_QIIME.tsv 
--m-metadata-column Age --o-visualization marten-dada-core-metrics-results-10/unweighted-unifrac-subject-group-significance-10.qzv --p-pairwise

qiime emperor plot --i-pcoa marten-dada-core-metrics-results-10/unweighted_unifrac_pcoa_results.qza --m-metadata-file marten_16S_metadata_QIIME-adjust.tsv --p-custom-axes Sex --o-visualization 
marten-dada-core-metrics-results-10/unweighted-unifrac-Sex-10.qzv

qiime emperor plot --i-pcoa marten-dada-core-metrics-results-10/bray_curtis_pcoa_results.qza --m-metadata-file marten_16S_metadata_QIIME-adjust.tsv --p-custom-axes Sex --o-visualization 
marten-dada-core-metrics-results-10/bray-curtis-emperor-Sex-10.qzv

qiime diversity beta-group-significance --i-distance-matrix marten-dada-core-metrics-results-10/unweighted_unifrac_distance_matrix.qza --m-metadata-file marten_16S_metadata_QIIME.tsv 
--m-metadata-column Color --o-visualization marten-dada-core-metrics-results-10/unweighted-unifrac-subject-color-significance.qzv --p-pairwise

