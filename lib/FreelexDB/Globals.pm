package FreelexDB::Globals;

use strict;
use base qw(FreelexDB::Globals::Defaults);

sub db_name { "kupengahao" }
sub db_user { "kupengahao" }
sub db_password { "kupu" }

sub headword_fields_dir { '/home/www-bin/kupengahao/lib/FreelexDB/Headword/Fields' }
sub system_name { "Kupenga Hao" };
sub mlmessage_file_location { '/home/www-bin/kupengahao/messages.txt' };
sub reports_dir { '/home/www-bin/kupengahao/reports/' };
sub support_contact_name { 'Dave Moskovitz' }
sub support_contact_email { '<a href="mailto:dave@thinktank.co.nz">dave@thinktank.co.nz</a>' }
sub support_contact_phone {'027 220 2202'}

sub fckeditor_path { '../static/FCKeditor' }
sub fckeditor_height { 200 };

sub textarearows { 4 }
sub textareacols { 100 }

1;
