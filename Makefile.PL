use inc::Module::Install;

name 'Freelex';
all_from 'lib/Freelex.pm';

requires Catalyst => '5.62';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
