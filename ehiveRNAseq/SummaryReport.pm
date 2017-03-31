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

  ehiveRNAseq::SummaryReport;

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
package ehiveRNAseq::SummaryReport;

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
    my $multiqc     = '/homes/ckong/.local/bin/multiqc';#$self->param_required('multiqc');
    my $process_dir = $self->param_required('output_dir');
    my $output_dir  = $self->param_required('output_dir')."/multiqc";

    $self->check_dir($output_dir);

    my $cmd = "$multiqc $process_dir -o $output_dir";

    system($cmd);

    if ( $? == -1 ){
        print "generate summary report step failed $!\n";
    }
    else {
        printf "generate summary report exited with value %d\n", $? >> 8;
    }

 
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


