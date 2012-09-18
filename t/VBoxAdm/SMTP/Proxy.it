use Test::More qw( no_plan );
use VBoxAdm::SMTP::Proxy '@VERSION@';
use Test::Memory::Cycle;

BEGIN { use_ok( 'VBoxAdm::SMTP::Proxy', '@VERSION@' ); }

my $Proxy = VBoxAdm::SMTP::Proxy->new();
isa_ok( $Proxy, 'VBoxAdm::SMTP::Proxy' );
can_ok( $Proxy, qw(child_finish_hook child_init_hook db_connect logger prepare_queries process_request) );
memory_cycle_ok($Proxy);
