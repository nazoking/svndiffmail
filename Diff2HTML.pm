package Diff2HTML;

use strict;
use warnings;

sub new {
  my ($class) = @_;
  my $data = {
    decoration=>{
     all=>['<pre>','</pre>'],
     ins=>['<div style=background:#cfc>','</div>'],
     del=>['<div style=background:#fcc>','</div>'],
     para=>['<div style=background:#eee>','</div>'],
     nochange=>['',''],
     header=>['<div style=background:#eed>','</div>']
   }
  };
  my $self = bless $data, $class;
  return $self;
}

sub toHtml{
  my ($self,@values) = @_; 
  local *IN = shift(@values);
  local *OUT = shift(@values);

  my $mode=0;
  my $prev="";
  my $input;
  my $nextmode;
  my $lines = 1;

  print OUT $self->{decoration}{all}[0];
  while($input=<IN>){
    if( $input =~ /^\+/ ){
      $nextmode="ins";
    }elsif( $input =~ /^\-/ ){
      $nextmode="del";
    }elsif( $input =~ /^\@/ ){
      $nextmode="para";
    }elsif( $input =~ /^ / ){
      $nextmode="nochange";
    }else{
      $nextmode="header";
    }
    if($mode ne $nextmode){
      chomp($prev);
      print OUT &htmlescape($prev);
      $prev="";
      if($mode){
        print OUT $self->{decoration}{$mode}[1];
      }
      $mode=$nextmode;
      print OUT $self->{decoration}{$mode}[0];
    }
    print OUT &htmlescape($prev);
    $prev = $input;
    $lines ++;
    if(defined($self->{maxline}) && $self->{maxline} < $lines){
      last;
    }
  }
  chomp($prev);
  print OUT &htmlescape($prev);
  if($mode){
    print OUT $self->{decoration}{$mode}[1];
  }
  print OUT $self->{decoration}{all}[1];
}


sub htmlescape {
  my $str = $_[0];
  $str =~ s/&/&amp;/g;
  $str =~ s/</&lt;/g;
  $str =~ s/>/&gt;/g;
  $str =~ s/\"/&quot;/g;
  $str =~ s/\'/&#39;/g;
  return $str;
}


if ($0 eq __FILE__) {
  my $n = Diff2HTML->new();
  $n->toHtml(*STDIN,*STDOUT);
}

1;
