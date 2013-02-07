#!/bin/usr/perl
package svnmail;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin";
use SvnDiffMail;

sub usage
{
  print <<"USAGE";
Usage: svnmail -d PATH
  Creates a commit report
  Valid options:
    -d         PATH        : specify repository path PATH (required)
    -rev       ARG         : specify repository revision ARG, defaults to youngest revision
    -name      ARG         : specify repository nice name ARG, defaults to basename of PATH
    -redmine   PROJECT_URL
    -to        EMAIL       : mail to
    -sendmail  PATH        : sendmail PATH
    -svnlook   PATH        : svnlook path
    -skip-authors ARG
USAGE
}
sub parse_options
{
  my ($self,@opts)=@_;
  while( $#opts >= 0 ){
    my $opt = shift(@opts);
    if($opt eq '-d') {
      $self->{sdm}->{repo}=shift(@opts);
    }elsif($opt eq '-maxline') {
      $self->{sdm}->{diff}->{maxline}=shift(@opts);
    }elsif($opt =~ /^-(rev|svnlook|to|sendmail|name|redmine|skip-authors)$/) {
      $self->{sdm}->{$1}=shift(@opts);
    }else{
      print "bad option $opt\n";
      &usage();
      exit -3;
    }
  }
}
sub new {
  my ($class) = @_;
  my $data = {
    sdm => SvnDiffMail->new()
  };
  my $self = bless $data, $class;
  return $self;
}
sub check_options
{
  my $self = shift;

  if( !defined($self->{sdm}->{repo}) ){
    print "missing required option -d\n";
    &usage();
    exit -3;
  }
}
sub main{
  my $self = shift;
  $self->parse_options(@_);
  $self->check_options();
  $self->{sdm}->get_svn_info();
  if(!$self->{sdm}->is_skip_commit()){
    $self->{sdm}->send_diff();
  }
}
if( $0 eq __FILE__ ){
  my $n = svnmail->new();
  $n->main(@ARGV);
}
1;
