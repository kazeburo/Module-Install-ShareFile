use inc::Module::Install;
name 'Module-Install-ShareFile';
all_from 'lib/Module/Install/ShareFile.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
#auto_include;
WriteAll;