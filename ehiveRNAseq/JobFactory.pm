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

  ehiveRNAseq::JobFactory;

=head1 DESCRIPTION


=head1 DATE

  March 2017

=head1 AUTHOR 
 
  ChuangKee Ong
  Open Targets, European Bioinformatics Institute (EMBL-EBI), 
  Wellcome Trust Genome Campus, Cambridge, CB10 1SD, UK
  Tel: +44(0)1223 4 92671
  
  ckong@ebi.ac.uk

=cut
package ehiveRNAseq::JobFactory;

use strict;
use Data::Dumper;
use base ('Bio::EnsEMBL::Hive::Process');

sub param_defaults {

    return {

           };
}

sub fetch_input {
    my ($self) 	= @_;

return 0;
}

sub run {
    my ($self) = @_;

return 0;
}

sub write_output {
    my ($self)  = @_;
    
    my $flag_pe = $self->param_required('flag_pe');
    my $dir     = $self->param_required('data_dir');
    my $data    = {};

    opendir(DIR, $dir) or die $!;

    while (my $file = readdir(DIR)) {
    	next unless ($file =~ m/fastq$/);
	if($flag_pe==1){
	   $data->{$1}->{$file}=1 if($file =~/(.+)\_\d{1}.+/);
	}
    }
    closedir(DIR);

    foreach my $sample (keys $data){
       my ($pair1, $pair2) = keys $data->{$sample};
       $self->dataflow_output_id( { 'fastq_file1' => $pair1, 'fastq_file2' => $pair2 }, 2);
    }      

return 0;
}

1;


