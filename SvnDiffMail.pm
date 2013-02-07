#!/bin/usr/perl
package SvnDiffMail;
use strict;
use warnings;
use Diff2HTML;

sub new {
  my ($class) = @_;
  my $data = {
    svnlook=>"svnlook",
    diff => Diff2HTML->new()
  };
  my $self = bless $data, $class;
  return $self;
}
sub completion_options
{
  my $self = shift;

  if( !defined($self->{repo}) ){
    print "missing required option -d\n";
    &usage();
    exit -3;
  }
  if( !defined($self->{name}) ){
    $self->{name} = "SVN: ".$self->{repo};
  }
  if( !defined($self->{rev} ) ){
    $self->{rev}=`$self->{svnlook} youngest $self->{repo}`;
    chomp($self->{rev});
  }
}

sub svnlook
{
  my $self = shift;
  my $com = shift;
  my $command = "$self->{svnlook} $com $self->{repo} -r $self->{rev}";
  my $ret = `$command`;
  if( $! != 0 ){
    return "miss! $! [$command]-$ret--";
  }
  return $ret;
}
sub get_svn_info
{
  my $self = shift;
  if( !defined($self->{rev} ) ){
    $self->{rev}=`$self->{svnlook} youngest $self->{repo}`;
    chomp($self->{rev});
  }
  if( !defined($self->{name}) ){
    $self->{name} = "SVN: ".$self->{repo};
  }
  $self->{LOG}=$self->svnlook( "log" );
  $self->{LOG} =~ /^(.*)/;
  $self->{LOG1}=$1;
  $self->{AUTHOR}=$self->svnlook( "author" );
  chomp($self->{AUTHOR});
  
}
sub rev_html
{
  my $self = shift;
  if( defined($self->{redmine}) ){
    return "<a href='".$self->{redmine}."/repository/revisions/".$self->{rev}."'>".$self->{rev}."</a>";
  }else{
    return $self->{rev};
  }
}
sub diff
{
  my $self = shift;
  local *OUT = shift;
  open IN,"$self->{svnlook} diff $self->{repo} -r $self->{rev} -x -b|";
  $self->{diff}->toHtml(*IN,*OUT);
  close IN;
}

sub print_mail{
  my $self = shift;
  print "Content-Type: text/html\n";
  print "Subject: [$self->{name} r$self->{rev}] $self->{LOG1}\n";
  print "\n";

  print <<"HTML";
<div>
@{[$self->svnlook("date")]}<br />
Revision:@{[$self->rev_html()]}
Author:$self->{AUTHOR}
</div>
HTML

  print "<h3>Log Message</h3><pre>$self->{LOG}</pre>";

  print "<h3>Changes</h3><pre>@{[$self->svnlook('changed')]}</pre>";

  print '<div style="border:2px solid #CCC">';
  $self->diff(*STDOUT);
  print '</div>';
}
sub open_name
{
  my $self = shift;
  if(defined($self->{to}) and defined($self->{sendmail})){
    return "|$self->{sendmail} $self->{to}";
  }else{
    return ">-";
  }
}
sub send_diff
{
  my $self = shift;
  local *FH;
  open FH, $self->open_name();
  local *STDOUT=*FH;
  $self->print_mail();
  close FH;
}
sub is_skip_commit
{
  my $self = shift;
  my @list = split(/\s+/,$self->{"skip-authors"});
  for( @list ){
    return 1 if $_ eq $self->{AUTHOR}
  }
  return 0;
}

1;
