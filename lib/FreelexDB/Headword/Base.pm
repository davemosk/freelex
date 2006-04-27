#!/usr/bin/perl;

package FreelexDB::Headword::Base;
  
  use base 'FreelexDB::DBI';
  use strict;
  
  use FreelexDB::Globals ();
  use FreelexDB::Utils::Format;
  use FreelexDB::Utils::Entities;
  use FreelexDB::Utils::Validation;
  use FreelexDB::Utils::Synonyms;
  
  use Carp;
  
  freelex_entities_init();
  use Data::Dumper;

sub external_fields { return ['HEADWORDTAGS'] }

sub display_order_form {
   return ['headword','headwordid','variantno','gloss','symbol','binomial','synonyms','HEADWORDTAGS','definition','essay','english','example', 'relatedterms','detailedexplanation','neweditorialcomment','owneruserid','CREATEUSERANDDATE','UPDATEUSERANDDATE'];
}

sub pseudo_cols {
   return grep {  $_ eq uc($_) } @{__PACKAGE__->display_order_form};
}

sub display_order_print {
   return ['headword','variantno','headwordid','gloss','symbol','binomial','synonyms','definition','essay','english','example','relatedterms','detailedexplanation'];
}

sub search_result_cols { return ['headword','headwordid','gloss','definition','example','owneruserid'] }

sub search_include_other_cols { return 
['gloss','symbol','definition','example','english','essay','detailedexplanation','relatedterms','source']
}

sub format { 
   my $self = shift;
   $self = shift   if (!ref $self && $self =~ /FreelexDB\:\:Headword$/);
   my $col = shift;
   my $formatmode = shift || 'plain';
   my @other_args = @_;
   my $val;
   unless ((ref $self) && (ref $self->find_column("$col")) && ($val = $self->get($col))) {
      $val = "";
   }
     
   
   my $format_func_type = 'format_' . $col . '_' . $formatmode . '_type';
   
   if (defined &$format_func_type) {
      #
      # is it a tag?
      #

      my $type = eval('&'.$format_func_type);
      if ( my @tags = $type =~ /\s*\<([^\s\>]+)(?:\s|\>)/g) {
         return entityise($type . $val) . '</' . join('></',reverse @tags) .  '>';
      }
      
      elsif ($type eq 'textarea') {
         return fltextarea($col,$val);
      }
      elsif ($type eq 'textbox') {
         return fltextbox($col,$val);
      }
      elsif ($type eq 'fckeditor') {
         return flfckeditor($col,$val)
      }
      
      else { die "unknown format type $type for $format_func_type" }
   }
   
   else {
      my $format_func_name = 'format_' . $col . '_' . $formatmode;
      if (defined &$format_func_name) {
         my $ffnresult = eval('&'.$format_func_name.'($self,@other_args)');
         if ($@) { croak "error in $format_func_name:" . $@ }
         else { return $ffnresult }
#      return $ffnresult;
      }
      elsif ($formatmode ne 'plain') {
         my $format_func_plain_name = 'format_' . $col . '_plain';
         if (defined &$format_func_plain_name) {
            return eval('&'.$format_func_plain_name.'($self,@other_args)');
         }
      }
      
      return $val;
   }
}

sub rowtohashref {
   my $self = shift;
   my $archivecopy = {};
   foreach my $ac (FreelexDB::Hwarchive->all_columns) {
     if (defined $self->get($ac)) {
        $archivecopy->{$ac} = $self->get($ac)   
     }
   }
   return $archivecopy;
}


sub canupdate {
   my $self = shift;
   my $user_object = shift;
   
   return 0 unless $user_object->canupdate;
   return 1 if $self->owneruserid = $user_object->matapunauserid;
   return 1 if $user_object->editor;
   return 0;  
}
   

sub validate {
   my $self = shift;
   my $col = shift;
   my $c = shift || "";
   my $validate_sub_name = 'validate_' . $col;   
   if (defined &$validate_sub_name) {
      return eval('&'.$validate_sub_name.'($self,$c)');
    }
   else {
      return ();
   }
}

sub preupdate {
   my ($self, $col, $c) = @_;
   my $pre_update_sub_name = 'pre_update_' . $col;   
   if (defined &$pre_update_sub_name) {
      $self->$pre_update_sub_name($c);
   }
}


sub postupdate {
   my ($self, $col, $c) = @_;
   my $post_update_sub_name = 'post_update_' . $col;   
   if (defined &$post_update_sub_name) {
      $self->$post_update_sub_name($c);
   }
}
         

sub use_headword_fields {
   my @dir = FreelexDB::Globals->headword_fields_dir();
   my %loaded = ();
   foreach my $dir (@dir) {
      opendir(DIRHANDLE,$dir) || die "Couldn't open directory $dir: $!\nCheck FreelexDB::Globals->headword_fields_dir value";
      my @files = readdir DIRHANDLE;
      foreach my $f (@files) {
         next unless (my $fname) = $f =~ /^(.+)\.pm$/; 
         next if exists $loaded{$fname};
         $loaded{$fname} = 1;
         my $modname = 'FreelexDB::Headword::Fields::' . $fname;
         eval "use $modname ()";
         if ($@) { croak "error using $modname:" . $@ }
      }
      close DIRHANDLE;
   }
}

sub postdisplay {
   my $self = shift;
   my $col = shift;
   my $postdisplay_sub_name = 'postdisplay_' . $col;   
   if (defined &$postdisplay_sub_name) {
      return eval('&'.$postdisplay_sub_name.'($self)');
   }
   else {
      return;
   }
}


  1;
