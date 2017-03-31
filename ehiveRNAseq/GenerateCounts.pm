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

  ehiveRNAseq::GenerateCounts;

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
package ehiveRNAseq::GenerateCounts;

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

    my $bam_file    = $self->param_required('bam_file');
    my $gtf         = $self->param_required('gtf');
    my $htseq_count = $self->param_required('htseq_count');
    my $bam_dir     = $self->param_required('output_dir')."/bam";
    my $output_dir  = $self->param_required('output_dir')."/counts";

    my $counts_file = "$bam_file.counts.txt";

    $self->check_dir($output_dir);

    # generate gene level counts using htseq-count
    my $cmd = "$htseq_count -t exon -q -f bam $bam_dir/$bam_file $gtf > $output_dir/$counts_file";

    system($cmd);

    if ( $? == -1 ){
        print "generate counts step failed for $bam_file: $!\n";
    }
    else {
        printf "generate counts step for $bam_file exited with value %d\n", $? >> 8;
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


