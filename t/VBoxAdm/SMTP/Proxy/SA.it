use Test::More qw( no_plan );
use VBoxAdm::SMTP::Proxy::SA '@VERSION@';
use Test::Memory::Cycle;

BEGIN { use_ok( 'VBoxAdm::SMTP::Proxy::SA', '@VERSION@' ); }

my $Proxy = VBoxAdm::SMTP::Proxy::SA::->new();
isa_ok( $Proxy, 'VBoxAdm::SMTP::Proxy' );
isa_ok( $Proxy, 'VBoxAdm::SMTP::Proxy::SA' );
can_ok( $Proxy, qw(child_finish_hook child_init_hook db_connect logger prepare_queries process_request) );
memory_cycle_ok($Proxy);

#can_ok($Proxy,qw(prepare_queries process_request process_message));
#can_ok($Proxy,qw(is_spam max_msg_size sa_block_score want_sa));
