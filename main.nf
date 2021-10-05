
#!/usr/bin/env nextflow
/*
 * Copyright 2020-2021, Seqera Labs
 * Copyright 2013-2019, Centre for Genomic Regulation (CRG)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

db_file = params.db_name
chunks = Channel
            .fromPath(params.query)
            .splitFasta(by: params.chunk)

/* 
 * Extends a BLAST query for each entry in the 'chunks' channel 
 */
process blast {
    memory = params.max_memory
    cpus = params.max_cpus
//   publishDir file(params.work_dir), mode: 'copy', overwrite: true 
    db_file = params.db_name

    input:
    file 'query.fa' from chunks
    path db_dir from file(params.db)
    
    output:
    file "blast.out" into blast_results
    
    script:
    """
    blastn -max_target_seqs 5 -num_threads 8 -db $db_dir/$db_file -query query.fa -outfmt 6 > blast.out
    """
}

blast_results
    .collectFile(name: "${params.output}")
