package Freelex::Controller::Reports;

use base qw/Catalyst::Controller/;
use strict;

use Data::Dumper;
use FreelexDB::Utils::Entities;
freelex_entities_init;

use FreelexDB::Utils::Mlmessage;
mlmessage_init;

use FreelexDB::Utils::Format;

use URI::Escape qw(uri_escape_utf8);

sub begin : Private {
  my ( $self, $c ) = @_;
  unless ($c->user_object ) { 
     $c->request->action(undef);
     $c->redirect("../login");
     $c->stash->{dont_render_template} = 1; 
  } else {
     $c->stash->{system_name} = entityise(FreelexDB::Globals->system_name);
     $c->stash->{user_object} = $c->user_object;
     $c->stash->{display_nav} = 1  unless defined $c->request->params->{'_nav'} && $c->request->params->{'_nav'} eq 'no';
     $c->stash->{start_prompt} = entityise(mlmessage('print_start_prompt',$c->user_object->{'lang'}),$c->request->headers->{'user-agent'});
     $c->stash->{end_prompt} = entityise(mlmessage('print_end_prompt',$c->user_object->{'lang'}),$c->request->headers->{'user-agent'});
     $c->stash->{format_prompt} =
     entityise(mlmessage('format',$c->user_object->{'lang'}),$c->request->headers->{'user-agent'});
     $c->stash->{print_prompt} = entityise(mlmessage('print',$c->user_object->{'lang'}),$c->request->headers->{'user-agent'});
     $c->stash->{tag_prompt} = entityise(mlmessage('headwordtags',$c->user_object->{'lang'}),$c->request->headers->{'user-agent'});
     $c->stash->{date} = localtime;
     $c->stash->{reports_dir} = FreelexDB::Globals->reports_dir;
     
  }
}

sub sql : Path('sql') {
  my( $self, $c ) = @_;

   my $whereclause;
   my @result = ();
   my $report;
   $c->stash->{title} = mlmessage('report',$c->user_object->{'lang'});

   if ($report = $c->request->params->{"_report"}) {

      open(REPORT,$c->stash->{reports_dir} . '/' . $report . '.sql') || bail($c,"can't open report file $report: $!");
      my $sql = join("",<REPORT>);
      close(REPORT);
      my $dbh = FreelexDB::Headword->db_Main;
      my $sth = $dbh->prepare($sql) || bail($c,$sql . '<br>prepare<br>returned the following error:<br><br>' . $dbh->errstr);
      $sth->execute  || bail($c,$sql . '<br>execute<br>returned the following error:<br><br>' . $dbh->errstr);
      my @rows = ();
      my $title = entityise(mlmessage($report,$c->user_object->{'lang'}));
      push @result, '<b>' . $title . '</b><br><br>';
      push @result, qq(<table border="1" cellpadding="2" cellspacing="2">\n<tr><td><b>);
      push @result, join("</b></td><td><b>", @{$sth->{NAME}}) . "</b></td></tr>\n";
      my $count = 0;
      while(my $row = $sth->fetchrow_arrayref) {
         $count++;
         my @NewRow = ();
         foreach my $e (@$row) {
            if (!defined($e) || $e eq '') {push @NewRow, 'NULL' }
            elsif ($e eq '0') { push @NewRow, '0' }
            elsif ($e =~ /.+\-(\d+)$/) {
               push @NewRow, qq(<a href="../headword/display?_nav=no&_id=) . $1 . qq(" target="_new">) . entityise($e) . qq(</a>);
            }
            else { push @NewRow, entityise($e) }
         }
              push @result,  "<tr><td>" . join('</td><td>',@NewRow) . "</td></tr>";
      }
      push @result, "</table><br>";
      push @result, $count . ' rows <br><br>';
      
      FreelexDB::Activityjournal->insert( {
              activitydate => $c->stash->{date},
              matapunauserid => $c->user_object->matapunauserid,
              verb => 'reports',
              object => $report,
              description => $count
            });
            
         FreelexDB::Activityjournal->dbi_commit;

   }

   opendir(REPORTS,$c->stash->{reports_dir}) || bail($c,"can't read reports directory: $!");
   my @repfiles = sort grep {/\.sql$/} readdir REPORTS;
   closedir(REPORTS);

   @repfiles = grep {s/.sql//} @repfiles;

   push @result, qq(<form action="../reports/sql" method="post">);
   push @result, mlmessage('please_select_a_report',$c->user_object->{'lang'}) . '<br>';
   push @result, qq(<select name="_report">\n);
   foreach my $repfile (@repfiles) {
      push @result, qq(<option value=") . $repfile . qq(">) . mlmessage($repfile,$c->user_object->{'lang'}) . qq(</option>);
   }
   push @result, qq(</select><br>);
   push @result, qq(<input type="hidden" name="_func" value="reports">);
   push @result, qq(<input type="submit" name="generate_report" value=") . mlmessage('generate_report',$c->user_object->{lang}) . qq(">);
   push @result, qq(</form>);
   $c->stash->{results} = join("",@result);
   $c->stash->{template} = 'reports.tt';
   $c->detach('Freelex::View::TT')
    
}

sub end : Private {
   my ( $self, $c ) = @_;
   die "You requested a dump"   if ((defined $c->request->params->{'_dump'}) && $c->request->params->{'_dump'} eq 1);
}

sub bail {
   my $c = shift;
   my $m = shift;
   $c->stash->{'message'} = mlmessage_block($m,$c->user_object->{lang});
   $c->stash->{template} = 'reports.tt';
   $c->forward('Freelex::View::TT');
   return 0;
}
   
   

1;