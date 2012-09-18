use Test::More qw( no_plan );
use VBoxAdm::SMTP::Proxy::MA '@VERSION@';
use Test::Memory::Cycle;

BEGIN { use_ok( 'VBoxAdm::SMTP::Proxy::MA', '@VERSION@' ); }

my $Proxy = VBoxAdm::SMTP::Proxy::MA->new();
isa_ok( $Proxy, 'VBoxAdm::SMTP::Proxy' );
isa_ok( $Proxy, 'VBoxAdm::SMTP::Proxy::MA' );
can_ok( $Proxy, qw(child_finish_hook child_init_hook db_connect logger prepare_queries process_request) );
can_ok( $Proxy, qw(prepare_queries process_request process_message) );
memory_cycle_ok($Proxy);
