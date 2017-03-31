=head1 LICENSE
Copyright [1999-2016] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=head1 NAME

  ehiveRNAseq::RNAseq_conf;

=head1 DESCRIPTION

  An example of a basic RNA-Seq pipeline implemented in eHive. 
  This is intended to describe different pipeline approaches, 
  not to perform a comprehensive RNA-Seq analysis.

  The 5 basic steps are:
  1) QC of the FASTQ files using fastqc
  2) Adapter and quality trimming using trim_galore
  3) Alignment to a genome/transcriptome using hisat2
  4) QC matrics on the aligned BAM files using qualimap
  5) Summary report using multiqc

=head1 DATE

  March 2017

=head1 AUTHOR 
 
  ChuangKee Ong
  Open Targets, European Bioinformatics Institute (EMBL-EBI), 
  Wellcome Trust Genome Campus, Cambridge, CB10 1SD, UK
  Tel: +44(0)1223 4 92671
  
  ckong@ebi.ac.uk

=cut
package ehiveRNAseq::RNAseq_conf;

use strict;
use warnings;
#use File::Spec;
use Bio::EnsEMBL::Hive::Version 2.4;
use base ('Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf');  

sub default_options {
    my ($self) = @_;

    return {
       ## inherit other stuff from base class
       %{ $self->SUPER::default_options() },

       ## general parameters
       'pipeline_name' => $self->o('hive_dbname'),       
       'email'         => $self->o('ENV', 'USER').'@ebi.ac.uk',
       'data_dir'      => '',
       'output_dir'    => '', 
       ## flag settings
       'flag_pe'       => '0', # default=> 0 or 1 whether data are single or paired-end 
       ## data libraries
       'gtf'           => '/nfs/nobackup/otar/data/reference/Homo_sapiens.GRCh38.87.gtf',
       'reference'     => '/nfs/nobackup/otar/data/reference/hg19_hisat',
       ## executables
       'fastqc'        => '/homes/ckong/work/lib/FastQC/fastqc',
       'trim_galore'   => '/homes/ckong/work/lib/trim_galore',
       'hisat2'        => '/homes/ckong/work/lib/hisat-0.1.6-beta/hisat',
       'samtools'      => '/usr/bin/samtools',
       'htseq_count'   => '/homes/ckong/.local/bin/htseq-count',
       'qualimap'      => '/homes/ckong/work/lib/qualimap_v2.2.1/qualimap',
       'multiqc'       => '/homes/ckong/.local/bin/multiqc',		

       ## eHive database details
       'pipeline_db' => {  
 	  -host   => $self->o('hive_host'),
       	  -port   => $self->o('hive_port'),
          -user   => $self->o('hive_user'),
          -pass   => $self->o('hive_password'),
	  -dbname => $self->o('hive_dbname'),
          -driver => 'mysql',
       },
    };
}

sub pipeline_create_commands {
    my ($self) = @_;
    return [
      # inheriting database and hive tables' creation
      @{$self->SUPER::pipeline_create_commands},
      'mkdir -p '.$self->o('output_dir'),
    ];
}

# Ensures output parameters gets propagated implicitly
sub hive_meta_table {
  my ($self) = @_;
  
  return {
    %{$self->SUPER::hive_meta_table},
    'hive_use_param_stack'  => 1,
  };
}

# Override the default method, to force an automatic loading of the registry in all workers
sub beekeeper_extra_cmdline_options {
  my ($self) = @_;
  return 0; 
      #' -reg_conf ' . $self->o('registry'),
  #;
}

# these parameter values are visible to all analyses, 
# can be overridden by parameters{} and input_id{}
sub pipeline_wide_parameters {  
    my ($self) = @_;

    return {
            %{$self->SUPER::pipeline_wide_parameters},  # here we inherit anything from the base class
	    'pipeline_name' => $self->o('pipeline_name'), #This must be defined for the beekeeper to work properly
	    'data_dir'      => $self->o('data_dir'),
	    'output_dir'    => $self->o('output_dir'),
    };
}

sub resource_classes {
    my $self = shift;

    return {
      'default' => {'LSF' => '-q production-rh7 -n 4 -M 4000   -R "rusage[mem=4000]"'},
      '8GB'  	=> {'LSF' => '-q production-rh7 -n 4 -M 8000   -R "rusage[mem=8000]"'},
      '16GB'  	=> {'LSF' => '-q production-rh7 -n 4 -M 16000  -R "rusage[mem=16000]"'},
      '32GB'  	=> {'LSF' => '-q production-rh7 -n 4 -M 32000  -R "rusage[mem=32000]"'},
      '64GB'  	=> {'LSF' => '-q production-rh7 -n 4 -M 64000  -R "rusage[mem=64000]"'},
      '128GB'  	=> {'LSF' => '-q production-rh7 -n 4 -M 128000 -R "rusage[mem=128000]"'},
      '256GB'  	=> {'LSF' => '-q production-rh7 -n 4 -M 256000 -R "rusage[mem=256000]"'},
    }
}

sub pipeline_analyses {
    my ($self) = @_;
    
    return [

    { -logic_name     => 'backbone_fire_pipeline',
      -module         => 'Bio::EnsEMBL::Hive::RunnableDB::Dummy',
      -input_ids      => [ {} ], 
      -parameters     => {},
      -hive_capacity  => -1,
      -rc_name 	      => 'default',       
      -meadow_type    => 'LOCAL',
      -flow_into      => { 
			   '1->A' => ['job_factory'],
                           'A->1' => ['summary_report'],
                         }		                       
    },   

   { -logic_name      => 'job_factory',
     -module          => 'ehiveRNAseq::JobFactory',
     -parameters      => {
			   'flag_pe'  => $self->o('flag_pe'), 
                         },
     -hive_capacity   => -1,
     -rc_name 	      => 'default',     
     -max_retry_count => 1,
     #-wait_for   => $pipeline_flow,
     -flow_into       => { '2' => 'quality_control', },    
   },

   { -logic_name      => 'quality_control',
     -module          => 'ehiveRNAseq::QualityControl',
     -parameters      => {	
			   'fastqc' => $self->o('fastqc'),
			 },
     -hive_capacity   => 10,
     -rc_name 	      => 'default',    
     -max_retry_count => 3,
     -flow_into       => { '1' => 'adapter_trimming', },    
   },

   { -logic_name      => 'adapter_trimming',
     -module          => 'ehiveRNAseq::AdapterTrim',
     -parameters      => { 
			   'trim_galore' => $self->o('trim_galore'),		
		         },
     -hive_capacity   => 10,
     -rc_name         => 'default',
     -max_retry_count => 3,
     -flow_into       => { '1' => 'reads_alignment', },
   },

   { -logic_name      => 'reads_alignment',
     -module          => 'ehiveRNAseq::ReadsAlignment',
     -parameters      => {      
			   'reference' => $self->o('reference'),
			   'hisat2'    => $self->o('hisat2'),							
			   'samtools'  => $self->o('samtools'),							
			 },
     -hive_capacity   => 10,
     -rc_name         => 'default',
     -max_retry_count => 3,
     -flow_into       => { '-1' => 'reads_alignment_8GB',  
     			   '1'  => 'generate_counts', 
 			 },
    },

   { -logic_name      => 'reads_alignment_8GB',
     -module          => 'ehiveRNAseq::ReadsAlignment',
     -parameters      => { 
                           'reference' => $self->o('reference'),
                           'hisat2'    => $self->o('hisat2'),
                           'samtools'  => $self->o('samtools'),
                         },
     -hive_capacity   => 10,
     -rc_name         => '8GB',
     -max_retry_count => 3,
     -flow_into       => { '1' => 'generate_counts', },
   },

   { -logic_name      => 'generate_counts',
     -module          => 'ehiveRNAseq::GenerateCounts',
     -parameters      => {
                           'htseq_count' => $self->o('htseq_count'),
			   'gtf'	 => $self->o('gtf'),
                         },
     -hive_capacity   => 10,
     -rc_name         => 'default',
     -max_retry_count => 3,
     -flow_into       => { '1' => 'post_alignment_qc', },
   },

   { -logic_name      => 'post_alignment_qc',
     -module          => 'ehiveRNAseq::PostAlignmentQC',
     -parameters      => { 
                           'qualimap' => $self->o('qualimap'),
                           'gtf'      => $self->o('gtf'),     
                         },
     -hive_capacity   => 10,
     -rc_name         => '8GB',
     -max_retry_count => 3,
   },

   { -logic_name      => 'summary_report',
     -module          => 'ehiveRNAseq::SummaryReport',
     -parameters      => {
                           'multiqc' => $self->o('multiqc'),
                         },
     -hive_capacity   => 10,
     -rc_name         => 'default',
     -max_retry_count => 3,
   },

    ];
}

1;

