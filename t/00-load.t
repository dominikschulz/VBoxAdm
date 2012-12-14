#!perl -T

use Test::More tests => 9;

BEGIN {
    use_ok( 'VBoxadm::Cmd::Command::alias' ) || print "Bail out!
";
    use_ok( 'VBoxadm::Cmd::Command::awl' ) || print "Bail out!
";
    use_ok( 'VBoxadm::Cmd::Command::dkim' ) || print "Bail out!
";
    use_ok( 'VBoxadm::Cmd::Command::domain' ) || print "Bail out!
";
    use_ok( 'VBoxadm::Cmd::Command::domainalias' ) || print "Bail out!
";
    use_ok( 'VBoxadm::Cmd::Command::mailbox' ) || print "Bail out!
";
    use_ok( 'VBoxadm::Cmd::Command::migrate' ) || print "Bail out!
";
    use_ok( 'VBoxadm::Cmd::Command::vacbl' ) || print "Bail out!
";
    use_ok( 'VBoxadm::Cmd::Command' ) || print "Bail out!
";
# TODO more ...
}

diag( "Testing VBoxAdm $VBoxAdm::VERSION, Perl $], $^X" );
