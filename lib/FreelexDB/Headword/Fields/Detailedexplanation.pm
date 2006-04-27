#sub format_detailedexplanation_form { 
#   my $self = shift;   
#   my $val;
#   
#   if ((ref $self) && (defined $self->detailedexplanation)) { 
#      $val = $self->detailedexplanation;
#   } else {
#      $val = "";
#   }
#   return <<EOM
#<script type="text/javascript" src="/static/FCKeditor/fckeditor.js"></script>
#<script type="text/javascript">
#<!--
#var sBasePath = '/static/FCKeditor/' ;
#
#var oFCKeditor = new FCKeditor( 'detailedexplanation' ) ;
#oFCKeditor.ToolbarSet = 'Freelex' ;
#oFCKeditor.BasePath	= sBasePath ;
#oFCKeditor.Height	= 200 ;
#oFCKeditor.Value	= '$val' ;
#oFCKeditor.Create() ;
#//-->
#</script>
#EOM
#;

sub format_detailedexplanation_form_type { 'fckeditor' }


1;
      

   
     
      
         