#!/bin/tcsh
#BSUB -n 1
#BSUB -W 900
#BSUB -J run_qiime
#BSUB -o stdout.run_qiime
#BSUB -e stderr.run_qiime
module load /usr/local/usrapps/bioinfo/modulefiles/qiime2/2021.8

qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path fastq_files/ --input-format CasavaOneEightSingleLanePerSampleDirFmt --output-path marten_paired-end-demux.qza

qiime vsearch join-pairs --i-demultiplexed-seqs marten_paired-end-demux.qza --o-joined-sequences marten_demux-joined.qza

qiime demux summarize --i-data marten_demux-joined.qza --o-visualization marten_demux-joined.qzv

qiime quality-filter q-score --i-demux marten_demux-joined.qza --o-filtered-sequences marten_demux-joined-filtered.qza --o-filter-stats marten_demux-joined-filter-stats.qza

qiime deblur denoise-16S --i-demultiplexed-seqs marten_demux-joined-filtered.qza --p-trim-length 460 --p-sample-stats --o-representative-sequences marten_deblur_rep-seqs.qza --o-table 
marten_deblur_table.qza --o-stats marten_deblur-stats.qza

qiime feature-table summarize --i-table marten_deblur_table.qza --o-visualization marten_deblur_table.qzv

qiime phylogeny align-to-tree-mafft-fasttree --i-sequences marten_deblur_rep-seqs.qza --o-alignment marten_deblur_aligned-rep-seqs.qza --o-masked-alignment marten_deblur_masked-aligned-rep-seqs.qza 
--o-tree marten_deblur_unrooted-tree.qza --o-rooted-tree marten_deblur_rooted-tree.qza 

qiime diversity core-metrics-phylogenetic --i-phylogeny marten_deblur_rooted-tree.qza --i-table marten_deblur_table.qza --p-sampling-depth 10 --m-metadata-file marten_metadata_16s.csv --output-dir 
marten_deblur_core-metrics-results

qiime diversity alpha-group-significance --i-alpha-diversity marten_deblur_core-metrics-results/faith_pd_vector.qza --m-metadata-file marten_16S_metadata_QIIME.tsv --o-visualization 
marten_deblur_core-metrics-results/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance --i-alpha-diversity  marten_deblur_core-metrics-results/evenness_vector.qza --m-metadata-file marten_16S_metadata_QIIME.tsv --o-visualization 
marten_deblur_core-metrics-results/evenness-group-significance.qzv

qiime diversity beta-group-significance --i-distance-matrix  marten_deblur_core-metrics-results/unweighted_unifrac_distance_matrix.qza --m-metadata-file  marten_16S_metadata_QIIME.tsv 
--m-metadata-column Sex --o-visualization marten_deblur_core-metrics-results/unweighted-unifrac-sex-significance.qzv --p-pairwise

qiime diversity beta-group-significance --i-distance-matrix marten_deblur_core-metrics-results/unweighted_unifrac_distance_matrix.qza --m-metadata-file  marten_16S_metadata_QIIME.tsv 
--m-metadata-column Color --o-visualization marten_deblur_core-metrics-results/unweighted-unifrac-color-significance.qzv --p-pairwise
