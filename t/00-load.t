#!perl

use Test::More tests => 87;

BEGIN {
    use_ok( 'VBoxAdm::Cmd::Command::alias' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cmd::Command::awl' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cmd::Command::dkim' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cmd::Command::domain' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cmd::Command::domainalias' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cmd::Command::mailbox' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cmd::Command::migrate' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cmd::Command::vacbl' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cmd::Command' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Controller::API' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Controller::Autodiscover' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Controller::AWL' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Controller::Cleanup' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Controller::CLI' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Controller::DMARC' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Controller::Frontend' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Controller::Mailarchive' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Controller::Notify' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Controller::Vacation' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cron::Command::awl' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cron::Command::cleanup' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cron::Command::dmarc' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cron::Command::mailarchive' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cron::Command::notify' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cron::Command' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::ar' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::da' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::de' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::en' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::es' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::fi' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::fr' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::hi' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::it' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::ja' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::ko' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::pl' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::pt' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::ru' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N::zh' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Migration::Plugin::Debmin1' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Migration::Plugin::Debmin2' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Migration::Plugin::Postfixadmin' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Migration::Plugin::Vexim' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Migration::Plugin' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Model::Alias' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Model::AWL' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Model::DMARCRecord' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Model::DMARCReport' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Model::Domain' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Model::DomainAlias' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Model::Mailbox' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Model::RFCNotify' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Model::RoleAccount' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Model::User' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Model::VacationBlacklist' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Model::VacationNotify' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::SMTP::Proxy::MA' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::SMTP::Proxy::SA' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::SMTP::Client' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::SMTP::Proxy' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::SMTP::Server' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cmd' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Cron' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::L10N' ) || print "Bail out!
";
    use_ok( 'VBoxAdm::Migration' ) || print "Bail out!
";
    use_ok( 'VDnsAdm::Controller::API' ) || print "Bail out!
";
    use_ok( 'VDnsAdm::Controller::CLI' ) || print "Bail out!
";
    use_ok( 'VDnsAdm::Controller::Frontend' ) || print "Bail out!
";
    use_ok( 'VDnsAdm::L10N::de' ) || print "Bail out!
";
    use_ok( 'VDnsAdm::L10N::en' ) || print "Bail out!
";
    use_ok( 'VDnsAdm::Model::Domain' ) || print "Bail out!
";
    use_ok( 'VDnsAdm::Model::Group' ) || print "Bail out!
";
    use_ok( 'VDnsAdm::Model::Record' ) || print "Bail out!
";
    use_ok( 'VDnsAdm::Model::Template' ) || print "Bail out!
";
    use_ok( 'VDnsAdm::Model::TemplateRecord' ) || print "Bail out!
";
    use_ok( 'VDnsAdm::Model::User' ) || print "Bail out!
";
    use_ok( 'VDnsAdm::L10N' ) || print "Bail out!
";
    use_ok( 'VWebAdm::Model::MessageQueue' ) || print "Bail out!
";
    use_ok( 'VWebAdm::Model::User' ) || print "Bail out!
";
    use_ok( 'VWebAdm::API' ) || print "Bail out!
";
    use_ok( 'VWebAdm::DB' ) || print "Bail out!
";
    use_ok( 'VWebAdm::DNS' ) || print "Bail out!
";
    use_ok( 'VWebAdm::L10N' ) || print "Bail out!
";
    use_ok( 'VWebAdm::Model' ) || print "Bail out!
";
    use_ok( 'VWebAdm::SaltedHash' ) || print "Bail out!
";
    use_ok( 'VWebAdm::Utils' ) || print "Bail out!
";
}

diag( "Testing VBoxAdm $VBoxAdm::VERSION, Perl $], $^X" );
