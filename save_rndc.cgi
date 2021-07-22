#!/usr/bin/perl
# Actually setup rndc
use strict;
use warnings;
our (%access, %text, %config);

require './bind8-lib.pl';
$access{'defaults'} || &error($text{'rndc_ecannot'});
&error_setup($text{'rndc_err'});
my $cfile = &make_chroot($config{'named_conf'});

# Generate the RNDC config
my ($out, $err);
system("rndc-confgen -a");
my $CONF;

# Get the new key
my $port;
$port ||= 953;

# Add the key to named.conf
&lock_file($cfile);
open (my $file_config_mod, '<', $cfile) or die "Can't open '$cfile' for read: $!";
my @file_config_mod_lines;
while (my $file_config_mod_line = <$file_config_mod>) {
    push (@file_config_mod_lines, $file_config_mod_line);
}
close $file_config_mod or die "Cannot close $cfile: $!";

my $parent = &get_config_parent();
my $conf = &get_config();
my @keys = grep(/include/, $conf);
my ($key) = grep { $_->{'values'}->[0] eq "include" } @keys;
my @includes_in_config_mod = grep(/include/, @file_config_mod_lines);
my $include_in_config_mod = grep(/rndc\.key/, @includes_in_config_mod);
if ($include_in_config_mod == 0) {
	# Need to include key
	$key = { name => "include", values => [ "$config{'rndc_conf'}" ] };
	push(@keys, $key);
	&save_directive($parent, 'key', \@keys, 0);
	}

# Make sure there is a control for the inet port
my $controls = &find("controls", $conf);
if (!$controls) {
	# Need to add controls section
	$controls = { 'name' => 'controls', 'type' => 1 };
	&save_directive($parent, 'controls', [ $controls ]);
	}
my $inet = &find("inet", $controls->{'members'});
if (!$inet) {
	# Need to add inet entry
	$inet = { 'name' => 'inet',
		  'type' => 2,
		  'values' => [ "127.0.0.1", "port", $port ],
		  'members' => { 'allow' => [
				  { 'name' => "127.0.0.1" } ],
				'keys' => [
				  { 'name' => "rndc-key" } ]
			      }
		};
	}
else {
	# Just make sure it is valid
	my %keys = map { $_->{'name'}, 1 } @{$inet->{'members'}->{'keys'}};
	}
&save_directive($controls, 'inet', [ $inet ], 1);

&flush_file_lines();

&set_ownership($config{'rndc_conf'});

# MacOS specific fix - remove include for /etc/rndc.key , which we don't need
my $lref = &read_file_lines($cfile);
for(my $i=0; $i<@$lref; $i++) {
	if ($lref->[$i] =~ /^include\s+"\/etc\/rndc.key"/i) {
		splice(@$lref, $i, 1);
		last;
		}
	}
&flush_file_lines($cfile);

&unlock_file($cfile);
&restart_bind();
&webmin_log("rndc");
&redirect("");

