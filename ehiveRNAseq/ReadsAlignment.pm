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

  ehiveRNAseq::ReadsAlignment;

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
package ehiveRNAseq::ReadsAlignment;

use strict;
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

    my $data_file1  = $self->param_required('fastq_file1');
    my $data_file2  = $self->param_required('fastq_file2');
    my $data_dir    = $self->param_required('data_dir');    
    my $output_dir  = $self->param_required('output_dir')."/bam";
    my $hisat2      = $self->param_required('hisat2');
    my $samtools    = $self->param_required('samtools');
    my $reference   = $self->param_required('reference')."/hg19_hisat";

    $self->check_dir($output_dir);

    my $output_file = $1 if($data_file1 =~/(.+)\_\d{1}.+$/);
    my $sam_file    = "$output_file.sam";
    my $bam_file    = "$output_file.bam";

    #my $cmd = "$hisat2 -x $reference --no-mixed --no-discordant -1 $data_dir/$data_file1 -2 $data_dir/$data_file2 | samtoos view -bS > $output_dir/$bam_file";
    my $cmd  = "$hisat2 -x $reference --no-mixed --no-discordant -1 $data_dir/$data_file1 -2 $data_dir/$data_file2 > $output_dir/$sam_file";
    my $cmd2 = "$samtools view -bS $output_dir/$sam_file > $output_dir/$bam_file";

    system($cmd);
    system($cmd2);

    if ( $? == -1 ){
        print "reads alignment step failed for $data_file1 & $data_file2: $!\n";
    }
    else {
        printf "reads alignment step for $data_file1 & $data_file2 exited with value %d\n", $? >> 8;
    }

    $self->dataflow_output_id( { 'bam_file' => $bam_file }, 1);

return 0;
}

sub check_dir {
    my ($self, $dir) = @_;

    unless (-e $dir){
      if($self->debug()){
        print STDERR "$dir doesn't exists. I will try to create it\n";
        print STDERR "mkdir $dir (0755)\n";
      }
      die "Impossible to create directory $dir\n" unless (mkdir $dir, 0755 );
    }    

return 0;
}

1;


