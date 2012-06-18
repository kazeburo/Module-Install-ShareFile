package Module::Install::ShareFile;

use strict;
use warnings;
use File::Find;
use ExtUtils::Manifest;
use Carp;
use base qw/Module::Install::Base/;
use File::Spec;
use File::Spec::Unix;

our $VERSION = '0.01';

sub install_sharefile {
    my $self = shift;
    my $file = shift;
    my %args = @_;

    unless ( defined $file and -f $file ) {
        Carp::croak("Illegal or missing file install_sharefile param: '$file'");
    }

    my $type = exists $args{type} ? $args{type} : 'dist';
    unless ( defined $type and $type eq 'module' or $type eq 'dist' ) {
        die "Illegal or invalid share dir type '$type'";
    }

    # Split by type
    my $S = ($^O eq 'MSWin32') ? "\\" : "\/";

    my $from = File::Spec->catfile(File::Spec::Unix->splitdir($file));
    my $dist = exists $args{dist} ? $args{dist} : $file;
    my @dist = File::Spec::Unix->splitdir($dist);
    my $to = File::Spec->catfile(@dist);

    my $root;
    if ( $type eq 'dist' ) {
        # Set up the install
        $root = "\$(INST_LIB)${S}auto${S}share${S}dist${S}\$(DISTNAME)";
    }
    else {
        my $module = Module::Install::_CLASS($args{module});
        unless ( defined $module ) {
            die "Missing or invalid module name '$_[0]'";
        }
        $module =~ s/::/-/g;
        $root = "\$(INST_LIB)${S}auto${S}share${S}module${S}$module";
    }

    my $postamble = '';
    my $perm_dir = eval($ExtUtils::MakeMaker::VERSION >= 6.52) ? '$(PERM_DIR)' : 755; ## no critic

    my @dist_dir = @dist;
    pop @dist_dir;
    my $dist_dir_stack = '';
    for my $dist_dir ( @dist_dir ) {
        $dist_dir_stack .= $S . $dist_dir;
        $postamble .=<<"END";
\t\$(NOECHO) \$(MKPATH) "$root$dist_dir_stack"
\t\$(NOECHO) \$(CHMOD) $perm_dir "$root$dist_dir_stack"
END
    }

    $postamble .=<<"END";
\t\$(NOECHO) \$(CP) "$from" "$root${S}$to"
END

    # Set up the install
    $self->postamble(<<"END_MAKEFILE");
config ::
$postamble

END_MAKEFILE

    $self->build_requires( 'ExtUtils::MakeMaker' => '6.11' );
    $self->no_index( file => $file );
}

1;
__END__

=head1 NAME

Module::Install::ShareFile - Install non-code file for use during run-time

=head1 SYNOPSIS

  install_sharefile 'file.txt';
  
  install_sharefile 'file.txt';
      dist => 'file.csv';
  
  install_sharefile 'file.txt',
      type => 'module'
      module => 'MyApp::Web',
      dist => 'file.csv';

=head1 DESCRIPTION

Module::Install::Share is very useful but It's can install only directory. This module can install a file to share directory.

=head1 METHODS

=head2  install_sharefile( $from, I<%args> )

Adds file to install.

Attributes are as follows:

=over 4

=item type: String

Specify install type as 'dist' or 'module'. default is 'dist'

=item module: String

If type is 'module', module name is required.

=item dist: String

Destination path. If not defined original file name is used.

=back

=head1 AUTHOR

Masahiro Nagano E<lt>kazeburo {at} gmail.comE<gt>

=head1 SEE ALSO

L<Module::Install::Share>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
