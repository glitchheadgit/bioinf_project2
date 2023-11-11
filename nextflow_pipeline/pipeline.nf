process fastqc {
	conda "bioconda::fastqc"
	publishDir "${launchDir}/${params.output}/fastqc", pattern: "*html", mode: "copy"
	publishDir "${launchDir}/${params.output}/fastqc/zip", pattern: "*zip", mode: "copy"
	input:
	tuple val(index), path(reads)
	output:
	tuple val(index), path(reads), emit: tuple
	path "*"
	script:
	"""
	fastqc -t 6 *
	"""
}


process indexing {
	conda "bioconda::bwa"
	input:
	path reference
	output:
	path "*", emit: index
	script:
	"""
	bwa index $reference
	"""
}


process alignment {
	conda "bioconda::bwa bioconda::samtools"
	publishDir "${launchDir}/${params.output}/alignment", mode: "copy"
	input:
	tuple val(index), path(reads)
	path reference
	path index
	output:
	path "*", emit: bam
	script:
	"""
	bwa mem $reference ${reads[0]} | samtools view -S -b - | samtools sort - > alignment.sorted.bam
	"""
}


process mpileup {
	conda "bioconda::samtools"
	publishDir "${launchDir}/${params.output}/variant_calling", mode: "copy"
	input:
	path reference
	path bam
	output:
	path "*", emit: pileup
	script:
	"""
	samtools mpileup -d $params.coverage_threshold -f $reference $bam > vc.mpileup
	"""
}


process varscan {
	conda "bioconda::varscan"
        publishDir "${launchDir}/${params.output}/variant_calling", mode: "copy"
	input:
	path pileup
	output:
	path "*", emit: vcf
	script:
	"""
	varscan mpileup2snp $pileup  --min-var-freq $params.minvarfreq --variants --output-vcf 1 > vs_${params.minvarfreq}.vcf
	"""
}


process digest_vcf {
	publishDir "${launchDir}/${params.output}/variant_calling", mode: "copy"
	input:
	path vcf
	output:
	path "*"
	script:
	"""
	cat $vcf | grep -v '^##'| awk '{print \$1, \$2, \$4, \$5, "FREQ:", \$10}'|awk -F: '{print \$1, \$8}' | sort -k6 > digest.tsv
	"""
}


workflow {
	Channel
		.fromFilePairs( params.reads, checkIfExists: true, size: -1 )
		.set { reads_ch }
	Channel
		.fromPath( params.ref, checkIfExists: true )
		.set { ref }
	fastqc( reads_ch )
	indexing( ref )
	alignment( reads_ch, ref, indexing.out.index )
	mpileup( ref, alignment.out.bam )
	varscan( mpileup.out.pileup )
	digest_vcf( varscan.out.vcf )
}
// parameters: minvarfreq ref reads output coverage_threshold
