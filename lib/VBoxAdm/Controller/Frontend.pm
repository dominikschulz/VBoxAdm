package VBoxAdm::Controller::Frontend;

use base 'CGI::Application';

use strict;
use warnings;

use CGI::Carp qw(fatalsToBrowser);
use Encode;

# Needed for database connection
use CGI::Application::Plugin::DBH (qw/dbh_config dbh/);
use CGI::Application::Plugin::Redirect;
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::TT;
use CGI::Application::Plugin::RequireSSL;
use CGI::Application::Plugin::Authentication;

use Config::Std;
use DBI;
use Readonly;
use Try::Tiny;

use VWebAdm::Utils;
use VBoxAdm::L10N;
use VWebAdm::SaltedHash;
use Log::Tree;

use VBoxAdm::Model::Alias;
use VBoxAdm::Model::AWL;
use VBoxAdm::Model::Domain;
use VBoxAdm::Model::DomainAlias;
use VBoxAdm::Model::DMARCReport;
use VBoxAdm::Model::DMARCRecord;
use VBoxAdm::Model::Mailbox;
use VWebAdm::Model::MessageQueue;
use VBoxAdm::Model::RFCNotify;
use VBoxAdm::Model::RoleAccount;
use VBoxAdm::Model::User;
use VBoxAdm::Model::VacationBlacklist;
use VBoxAdm::Model::VacationNotify;



Readonly my $ENTRIES_PER_PAGE => 20;

############################################
# Usage      : Invoked by CGIApp
# Purpose    : Setup the Application
# Returns    : Nothing
# Parameters : None
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
# setup is run right after cgiapp_init
sub setup {
    my $self = shift;

    my $Logger = Log::Tree::->new( { 'facility' => 'VBoxAdm/Frontend', } );
    $self->{'logger'} = $Logger;

    # define the default run mode
    $self->start_mode('public_login');

    # define the mappings between the rm parameter and the actual sub
    $self->run_modes(

        #
        # Public
        #
        'public_login' => 'show_login',

        #
        # Private
        #

        # General
        'welcome' => 'show_welcome',

        # Domains
        'domains'       => 'show_domains',
        'domain'        => 'show_domain',
        'create_domain' => 'show_create_domain',
        'add_domain'    => 'show_add_domain',
        'remove_domain' => 'show_remove_domain',

        # no need for 'edit_domain', we can only change is_active anyway
        'update_domain' => 'show_update_domain',

        # Domain Aliases
        'domain_aliases'      => 'show_domain_aliases',
        'create_domain_alias' => 'show_create_domain_alias',
        'add_domain_alias'    => 'show_add_domain_alias',
        'remove_domain_alias' => 'show_remove_domain_alias',
        'edit_domain_alias'   => 'show_edit_domain_alias',
        'update_domain_alias' => 'show_update_domain_alias',

        # Aliases
        'aliases'      => 'show_aliases',
        'create_alias' => 'show_create_alias',
        'add_alias'    => 'show_add_alias',
        'remove_alias' => 'show_remove_alias',
        'edit_alias'   => 'show_edit_alias',
        'update_alias' => 'show_update_alias',

        # Mailboxes
        'mailboxes'      => 'show_mailboxes',
        'create_mailbox' => 'show_create_mailbox',
        'add_mailbox'    => 'show_add_mailbox',
        'remove_mailbox' => 'show_remove_mailbox',
        'edit_mailbox'   => 'show_edit_mailbox',
        'update_mailbox' => 'show_update_mailbox',

        # Broadcast
        'broadcast'      => 'show_broadcast',
        'send_broadcast' => 'show_send_broadcast',

        # Vacation Blacklist
        'vac_bl'        => 'show_vacation_blacklist',
        'create_vac_bl' => 'show_create_vacbl_entry',
        'add_vac_bl'    => 'show_add_vacbl_entry',
        'remove_vac_bl' => 'show_remove_vacbl_entry',

        # Auto-Whitelist
        'awl'        => 'show_awl',
        'update_awl' => 'show_update_awl',

        # Log
        'log' => 'show_log',

        # Admins
        'admins' => 'show_admins',

        # Vacation Replies
        'vac_repl' => 'show_vacation_replies',

        # RFC Notifies
        'notify' => 'show_rfc_notify',

        # Mailarchive
        # TODO show mailarchive if configured

        # RoleAccounts
        'role_accounts'       => 'show_role_accounts',
        'create_role_account' => 'show_create_role_account',
        'add_role_account'    => 'show_add_role_account',
        'remove_role_account' => 'show_remove_role_account',
        'edit_role_account'   => 'show_edit_role_account',
        'update_role_account' => 'show_update_role_account',
        
        # DMARC
        'dmarc_reports'       => 'show_dmarc_reports',
        'dmarc_report'        => 'show_dmarc_report',
    );

    # Authentication
    # Setup authentication using CGI::Application::Plugin::Authentication
    # Since we want to be able to support salted passwords, this is a bit messy.
    #
    # Contraints:
    # Only users who are either siteadmin or domainadmin should be able to login
    # and their account (= mailbox) must be active. Furthermore the username is
    # local_part@domain but those are stored in two different tables. So
    # we need to join those tables by specifying two tables and CONCAT the
    # fields together.
    #
    # Since the plugin does not support OR contraints we have to work around that issue.
    # In doubt I suggest to have a look the source code of the plugin.
    #
    # Filters:
    # The filter receives the user supplied password and the content of the column it is
    # applied to, extracts the pwscheme and salt, hashes the user supplied pass and returns
    # the password hash computed with the old salt and pwscheme. The plugin compares
    # the result with the unmodified column entry.
    $self->authen->config(
        DRIVER => [
            'DBI',
            TABLES      => [ 'mailboxes M', 'domains D' ],
            JOIN_ON     => 'M.domain_id = D.id',
            CONSTRAINTS => {
                "CONCAT(M.local_part,'\@',D.name)" => '__CREDENTIAL_1__',
                'M.is_active'                      => '1',
                'D.is_active'                      => '1',

                # WARNING: This contraint relies on an implementation detail of Plugin::Authentication!
                # This is bad style, but there is no other way right now.
                # The correct way would probably to create a custom Authen plugin.
                '(M.is_siteadmin OR M.is_domainadmin) AND 1' => '1',
            },
            COLUMNS => { 'dovecotpw:M.password' => '__CREDENTIAL_2__', },
            FILTERS => {
                'dovecotpw' => sub {

                    # since we may use salted passwords, we have to do our own
                    # password verification. a simple string eq would not do.
                    my $param   = shift;    # unused, always empty
                    my $plain   = shift;    # password from user
                    my $pwentry = shift;    # password hash from db
                    my ( $pwscheme, undef, $salt ) = &VWebAdm::SaltedHash::split_pass($pwentry);
                    my $passh = &VWebAdm::SaltedHash::make_pass( $plain, $pwscheme, $salt );
                    return $passh;
                },
            }
        ],
        LOGOUT_RUNMODE      => 'public_login',
        LOGIN_RUNMODE       => 'public_login',
        POST_LOGIN_CALLBACK => \&post_login_callback,
    );

    # only enable authen if called as CGI, this helps with testing and debugging from the commandline
    if ( !$self->is_shell() ) {
        $self->authen->protected_runmodes(qr/^(?!public_|api)/);
    }

    #
    # Configuration
    #
    # Valid config file locations to try
    my @conffile_locations = qw(
      vboxadm.conf
      conf/vboxadm.conf
      /etc/vboxadm/vboxadm.conf
      @CFGDIR@/vboxadm/vboxadm.conf
    );

    # if the application if run as a FastCGI app, the server might
    # provide an additional configuration location. if the points to file
    # add it to the list of possible locations
    if ( $ENV{CGIAPP_CONFIG_FILE} && -f $ENV{CGIAPP_CONFIG_FILE} ) {
        unshift( @conffile_locations, $ENV{CGIAPP_CONFIG_FILE} );
    }

    my ( %config, $conffile_used );

    # Try all config file locations
    foreach my $loc (@conffile_locations) {
        if ( -r $loc ) {
            $conffile_used = $loc;
            read_config $loc => %config;
            last;
        }
    }
    if ( !$conffile_used ) {
        $Logger->log( message => "Warning: No readable config file found in search path! (" . join( ':', @conffile_locations ) . ")", level => 'warning', );
    }
    $self->{config} = \%config;

    #
    # Database
    #
    my $user = $config{'default'}{'dbuser'} || 'root';
    my $pass = $config{'default'}{'dbpass'} || 'root';
    my $db   = $config{'default'}{'dbdb'}   || 'vboxadm';
    my $port = $config{'default'}{'dbport'} || 3306;
    my $host = $config{'default'}{'dbhost'} || 'localhost';
    my $dsn  = "DBI:mysql:database=$db;user=$user;password=$pass;host=$host;port=$port";
    $self->{base_url}     = $config{'cgi'}{'base_url'}     || '/cgi-bin/vboxadm.pl';
    $self->{media_prefix} = $config{'cgi'}{'media_prefix'} || '';

    # Connect to DBI database, same args as DBI->connect();
    # uses connect_cached for persistent connections
    # this should have no effect for CGI and speed up FastCGI
    # http://www.cosmocode.de/en/blog/gohr/2009-12/10-surviving-the-perl-utf-8-madness
    # http://www.gyford.com/phil/writing/2008/04/25/utf8_mysql_perl.php
    # http://stackoverflow.com/questions/6162484/why-does-modern-perl-avoid-utf-8-by-default
    # mysql_enable_utf8 should prepare the connection for UTF-8. It will also SET NAMES utf8.
    # Scripts, Database, Sourcecode, Userdata ... everything should be in UTF-8
    # the only point were we could deal with non-UTF-8 is when we output data to
    # non-utf-8 capable browsers (are there any?)
    $self->dbh_config(
        sub {
            DBI->connect_cached(
                $dsn, undef, undef,
                {
                    PrintError        => 0,
                    RaiseError        => 0,
                    mysql_enable_utf8 => 1,
                }
            );
        }
    );
    if ( !$self->dbh ) {
        $self->log( "Failed to establish DB connection with DSN $dsn and error message: " . DBI->errstr, 'error', );
        die("Could not connect to DB.");
    }

    #
    # L10N
    #
    # the user handle, will try to determine the appropriate language ... look at the docs of Locale::Maketext
    $self->{lh} = VBoxAdm::L10N::->get_handle();

    # this handle is used for logging. logged messages should always be in english
    $self->{lh_en} = VBoxAdm::L10N::->get_handle('en');

    #
    # Templating unsing the Template Toolkit
    #
    # Filters:
    # Have a look at the docs of the tt for info on dynamic filters.
    # Short version: they allow filters with more than one argument.
    # highlight provides syntax highlightning for the search
    # l10n provides localization via Locale::Maketext
    my @include_path = qw(tpl ../tpl /usr/lib/vwebadm/tpl);
    if ( $config{'cgi'}{'template_path'} && -d $config{'cgi'}{'template_path'} ) {
        unshift( @include_path, $config{'cgi'}{'template_path'} );
    }
    $self->tt_config(
        TEMPLATE_OPTIONS => {
            ENCODING     => 'utf8',
            INCLUDE_PATH => \@include_path,
            POST_CHOMP   => 1,
            FILTERS      => {
                'currency' => sub { sprintf( '%0.2f', @_ ) },

                # dynamic filter factory, see TT manpage
                'highlight' => [
                    sub {
                        my ( $context, $search ) = @_;

                        return sub {
                            my $str = shift;
                            if ($search) {
                                $str =~ s/($search)/<span class='hilighton'>$1<\/span>/g;
                            }
                            return $str;
                          }
                    },
                    1
                ],

                # A localization filter. Turn the english text into the localized counterpart using Locale::Maketext
                'l10n' => [
                    sub {
                        my ( $context, @args ) = @_;

                        return sub {
                            my $str = shift;
                            return $self->{lh}->maketext( $str, @args );
                          }
                    },
                    1,
                ],
                
                'localtime' => sub { "".localtime($_[0]) },
            }
        }
    );
    $self->tt_params( base_url     => $self->{base_url} );
    $self->tt_params( media_prefix => $self->{media_prefix} );

    my $Messages = VWebAdm::Model::MessageQueue::->new(
        {
            'lh'      => $self->{'lh'},
            'lh_en'   => $self->{'lh_en'},
            'session' => $self->session,
            'logger'  => $Logger,
        }
    );
    $self->{'Messages'} = $Messages;

    # setup classes if the user is logged in
    if ( $self->authen->is_authenticated && $self->authen->username ) {

        # if we can not create a new user object we MUST NOT die but redirect to login page instead
        my $User;
        eval {
            $User = VBoxAdm::Model::User::->new(
                {
                    'dbh'      => $self->dbh,
                    'username' => $self->authen->username,
                    'force'    => 1,
                    'msgq'     => $Messages,
                    'logger'   => $Logger,
                    'config'   => $self->{'config'},
                }
            );
            $User->login('forced-login');
        };
        if ( $@ || !$User ) {
            $self->log("Could not create User Object: $@");
        }
        else {

            $self->{'User'} = $User;
            $Logger->suffix('[User: '.$User->get_name().']');
            my $arg_ref = {
                'dbh'    => $self->dbh,
                'user'   => $User,
                'msgq'   => $Messages,
                'logger' => $Logger,
                'config' => $self->{'config'},
            };
            $self->{'Alias'}             = VBoxAdm::Model::Alias::->new($arg_ref);
            $self->{'AWL'}               = VBoxAdm::Model::AWL::->new($arg_ref);
            $self->{'Domain'}            = VBoxAdm::Model::Domain::->new($arg_ref);
            $self->{'DomainAlias'}       = VBoxAdm::Model::DomainAlias::->new($arg_ref);
            $self->{'DMARCReport'}       = VBoxAdm::Model::DMARCReport::->new($arg_ref);
            $self->{'DMARCRecord'}       = VBoxAdm::Model::DMARCRecord::->new($arg_ref);
            $self->{'Mailbox'}           = VBoxAdm::Model::Mailbox::->new($arg_ref);
            $self->{'RFCNotify'}         = VBoxAdm::Model::RFCNotify::->new($arg_ref);
            $self->{'RoleAccount'}       = VBoxAdm::Model::RoleAccount::->new($arg_ref);
            $self->{'VacationBlacklist'} = VBoxAdm::Model::VacationBlacklist::->new($arg_ref);
        }
    }

    # to make perlcritic happy
    return 1;
}

sub teardown {
    my $self = shift;

    # Disconnect when done
    $self->dbh->disconnect();

    # to make perlcritic happy
    return 1;
}

#
# CGI::Application Hooks
#
# cgiapp_init is run right before setup
sub cgiapp_init {
    my $self = shift;

    # Everything should be in UTF-8!
    $self->query->charset('UTF-8');

    # Configure RequireSSL
    my $ignore_ssl_check = 0;
    if ( $self->is_shell() || $self->is_localnet() || $self->{config}{'cgi'}{'no_ssl'} ) {
        $ignore_ssl_check = 1;
    }

    $self->config_requiressl(
        'keep_in_ssl'  => 1,
        'ignore_check' => $ignore_ssl_check,
    );

    # to make perlcritic happy
    return 1;
}

#
# Template::Toolkit Hooks
#

# post processing hooks
sub tt_post_process {
    my $self    = shift;
    my $htmlref = shift;

    # nop
    return;
}

# pre processing set commonly used variables for the templates
sub tt_pre_process {
    my ( $self, $file, $vars ) = @_;

    $vars->{username}       = $self->authen->username;
    $vars->{system_domain}  = $self->{config}{'default'}{'domain'} || 'localhost';
    $vars->{long_forms}     = $self->{config}{'cgi'}{'long_forms'} || 0;
    #$vars->{version}        = $VERSION;
    $vars->{messages}       = $self->get_messages();
    $vars->{is_siteadmin}   = $self->user->is_siteadmin() if $self->user();
    $vars->{is_domainadmin} = $self->user->is_domainadmin() if $self->user();
    $vars->{product}        = 'VBoxAdm';
    $vars->{product_url}    = 'http://www.vboxadm.net/';

    return;
}

#
# Misc. private Subs
#

############################################
# Usage      : $self->log('message');
# Purpose    : Log a message to the log table and syslog
# Returns    : true on success
# Parameters : a string
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub log {
    my $self     = shift;
    my $msg      = shift;
    my $severity = shift || 'debug',

    # Get our database connection
    my $dbh = $self->dbh();

    if ($msg) {
        $self->{'logger'}->log( message => $msg, level => $severity, );
        my $query = "INSERT INTO log (ts,msg) VALUES(NOW(),?)";
        my $sth   = $dbh->prepare($query)
          or $self->{'logger'}->log( message => 'Could not prepare Query: ' . $query . ', Error: ' . DBI->errstr );
        if ( $sth->execute($msg) ) {
            $sth->finish();
            return 1;
        }
        else {
            $self->{'logger'}->log( message => 'Could not execute Query: ' . $query . ', Args: ' . $msg . ', Error: ' . $sth->errstr );
            $sth->finish();
            return;
        }
    }
    else {
        return;
    }
}

############################################
# Usage      : called by Authentication plugin after successfull login
# Purpose    : log login and setup user env.
# Returns    : always true
# Parameters : none
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub post_login_callback {
    my $self = shift;

    $self->log_login();

    return 1;
}

############################################
# Usage      : $self->log_login();
# Purpose    : convenience method for logging a user login event
# Returns    : always true
# Parameters : none
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub log_login {
    my $self = shift;
    if ( $self->authen->is_authenticated ) {
        $self->log( "User " . $self->authen->username . " logged in.", );
    }
    elsif ( $self->authen->login_attempts() && !$self->authen->is_authenticated ) {
        $self->log( "Login failed for: " . $self->query()->param('authen_username') );
        $self->add_message( 'error', 'Login failed!' );
    }
    else {

        # no-logged in user accessing the login page, don't log this ...
    }
    return 1;
}

############################################
# Usage      : $self->add_message('warning','message');
# Purpose    : Add a message to the notification message stack
# Returns    : always true
# Parameters : the type and the message
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
# add entry to notify
sub add_message {
    my $self = shift;
    my $type = shift;
    my $msg  = shift;
    return unless $type && $msg;
    return if !$self->{'Messages'};
    $self->{'Messages'}->push( $type, $msg );
    return 1;
}

############################################
# Usage      : $self->get_messages();
# Purpose    : Return all messages from the message stack and remove them
# Returns    : a hashref w/ the messages by priority
# Parameters : none
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
# get and reset notify
sub get_messages {
    my $self = shift;
    return if !$self->{'Messages'};
    my @msgs = $self->{'Messages'}->pop();
    return \@msgs;
}

############################################
# Usage      : $self->peek_message();
# Purpose    : Return the message stack w/o removing the messages
# Returns    : a hashref w/ the message by priority
# Parameters : none
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
# get notify (no reset)
sub peek_message {
    my $self = shift;
    return if !$self->{'Messages'};
    my @msgs = $self->{'Messages'}->peek();
    return \@msgs;
}

############################################
# Usage      : $self->is_shell()
# Purpose    : is the script run from a shell?
# Returns    : true if no CGI
# Parameters : none
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub is_shell {
    my $self = shift;
    if ( $ENV{'DISPLAY'} && $ENV{'PS1'} && $ENV{'SHELL'} && $ENV{'USER'} ) {
        if (   $ENV{'DOCUMENT_ROOT'}
            || $ENV{'GATEWAY_INTERFACE'}
            || $ENV{'HTTP_HOST'}
            || $ENV{'REMOTE_ADDR'}
            || $ENV{'REQUEST_METHOD'}
            || $ENV{'SERVER_SOFTWARE'} )
        {
            return;
        }
        else {
            return 1;
        }
    }
    else {
        return;
    }
}

sub user {
    my $self = shift;
    return $self->{'User'};
}

############################################
# Usage      : $self->is_localnet()
# Purpose    : tell if the user is on a local, i.e. somewhat trusted, network
# Returns    : true if localnet or shell
# Parameters : none
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub is_localnet {
    if ( !$ENV{'REMOTE_ADDR'} ) {
        return 1;    # shell, coz' local
    }
    else {
        if ( $ENV{'REMOTE_ADDR'} =~ m/^(192\.168|172\.(1[6-9]|2\d|3[0-1])|10)\./ ) {
            return 1;
        }
        else {
            return;
        }
    }
}

############################################
# Usage      :
# Purpose    : Return the domain name to a given domain id.
# Returns    :
# Parameters :
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub get_domain_byid {
    my $self      = shift;
    my $domain_id = shift;

    return $self->{'Domain'}->get_name($domain_id);
}

#
# Public
#

sub show_login {
    my $self = shift;

    $self->session_delete();

    my %params = (
        title        => $self->{lh}->maketext('VBoxAdm Login'),
        nonavigation => 1,
    );

    return $self->tt_process( 'vwebadm/login.tpl', \%params );
}

#
# Private
#

#
# General / Misc.
#
sub show_welcome {
    my $self = shift;

    my %params = (
        'title'   => $self->{lh}->maketext('VBoxAdm Overview'),
        'current' => 'welcome',
    );

    return $self->tt_process( 'vboxadm/welcome.tpl', \%params );
}

#
# Broadcast
#
# Show the broadcast form
sub show_broadcast {
    my $self = shift;

    if ( !$self->user->is_siteadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username, 'notice', );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get our database connection
    my $dbh = $self->dbh();

    my $query = "SELECT COUNT(*) FROM mailboxes WHERE is_active";
    my $sth   = $dbh->prepare($query);
    $sth->execute();
    my $count = $sth->fetchrow_array();
    $sth->finish();

    my %params = (
        'title'   => $self->{lh}->maketext('VBoxAdm Send Broadcast'),
        'current' => 'broadcast',
        'count'   => $count,
    );

    return $self->tt_process( 'vboxadm/broadcast.tpl', \%params );
}

# Send the broadcast message and show confirmation page
sub show_send_broadcast {
    my $self = shift;

    if ( !$self->user->is_siteadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username, 'notice', );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get our database connection
    my $dbh = $self->dbh();

    # Get CGI Query object
    my $q = $self->query();

    my $subject = $q->param('subject');
    my $message = $q->param('message');

    my $system_domain = $self->{config}{'default'}{'domain'} || 'localhost';

    my $query    = "SELECT m.local_part,d.name FROM mailboxes AS m LEFT JOIN domains AS d ON m.domain_id = d.id WHERE m.is_active AND d.is_active";
    my $num_sent = 0;
    if ( my $sth = $dbh->prepare($query) ) {
        if ( $sth->execute() ) {
            while ( my ( $local_part, $domain_name ) = $sth->fetchrow_array() ) {
                my $email = $local_part . '@' . $domain_name;
                my $emsg  = '';
                $emsg .= "Subject: " . $subject . "\r\n";
                $emsg .= "Auto-Submitted: auto-generated\r\n";
                $emsg .= "From: VBoxAdm <vboxadm\@" . $system_domain . ">\r\n";
                $emsg .= "To: <" . $email . ">\r\n";
                $emsg .= "\r\n";
                $emsg .= $message;
                if ( &VWebAdm::Utils::sendmail( 'vboxadm@' . $system_domain, $emsg ) ) {
                    $self->log( 'User ' . $self->authen->username . ' sent broadcast message with subject ' . $subject . ' to ' . $email, 'debug', );
                }
                else {
                    $self->log(
                        'User '
                          . $self->authen->username
                          . ' tried to send broadcast message with subject '
                          . $subject . ' to '
                          . $email
                          . ' but sendmail failed.',
                        'debug',
                    );
                }
                $num_sent++;
            }
        }
        else {
            $self->log( 'Executing SQL ' . $query . ' failed w/ error: ' . $sth->errstr, 'error', );
        }
        $sth->finish();
    }
    else {
        $self->log( 'Preparing SQL ' . $query . ' into statement failed w/ error: ' . $dbh->errstr, 'error', );
    }

    my %params = (
        'title'    => $self->{lh}->maketext('VBoxAdm Sent Broadcast'),
        'current'  => 'broadcast',
        'num_sent' => $num_sent,
    );

    return $self->tt_process( 'vboxadm/broadcast_result.tpl', \%params );
}

#
# Domains
#

sub show_domains {
    my $self = shift;

    # Get our database connection
    my $dbh = $self->dbh();

    # Get CGI Query object
    my $q = $self->query();

    my $page   = $q->param('page') || 1;
    my $search = $q->param('search');
    my %params = (
        'Search'  => $search,
        'title'   => $self->{lh}->maketext('VBoxAdm Domains'),
        'current' => 'domains',
        'search'  => $search,
    );

    my $sql_aliases = "SELECT COUNT(*) FROM aliases WHERE domain_id = ?";
    my $sth_aliases = $dbh->prepare($sql_aliases);
    if ( !$sth_aliases ) {
        $self->log( 'Preparing SQL ' . $sql_aliases . ' failed w/ error: ' . $dbh->errstr, 'error', );
        $self->add_message( 'error', 'Database error!' );
        return $self->tt_process( 'vboxadm/domain/list.tpl', \%params );
    }
    my $sql_mailboxes = "SELECT COUNT(*) FROM mailboxes WHERE domain_id = ?";
    my $sth_mailboxes = $dbh->prepare($sql_mailboxes);
    if ( !$sth_mailboxes ) {
        $self->log( 'Preparing SQL ' . $sql_mailboxes . ' failed w/ error: ' . $dbh->errstr, 'error', );
        $self->add_message( 'error', 'Database error!' );
        return $self->tt_process( 'vboxadm/domain/list.tpl', \%params );
    }
    my $sql_domainaliases = "SELECT COUNT(*) FROM domain_aliases WHERE domain_id = ?";
    my $sth_domainaliases = $dbh->prepare($sql_domainaliases);
    if ( !$sth_domainaliases ) {
        $self->log( 'Preparing SQL ' . $sql_domainaliases . ' failed w/ error: ' . $dbh->errstr, 'error', );
        $self->add_message( 'error', 'Database error!' );
        return $self->tt_process( 'vboxadm/domain/list.tpl', \%params );
    }

    my @domains = $self->{'Domain'}->list( \%params );

    foreach my $domain (@domains) {
        if ( $sth_aliases->execute( $domain->{'id'} ) ) {
            $domain->{'num_aliases'} = $sth_aliases->fetchrow_array();
        }
        if ( $sth_mailboxes->execute( $domain->{'id'} ) ) {
            $domain->{'num_mailboxes'} = $sth_mailboxes->fetchrow_array();
        }
        if ( $sth_domainaliases->execute( $domain->{'id'} ) ) {
            $domain->{'num_domainaliases'} = $sth_domainaliases->fetchrow_array();
        }
    }

    $sth_aliases->finish;
    $sth_mailboxes->finish();
    $sth_domainaliases->finish();

    $params{'domains'} = \@domains;

    return $self->tt_process( 'vboxadm/domain/list.tpl', \%params );
}

sub show_domain {
    my $self = shift;

    if ( !$self->user->is_siteadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get our database connection
    my $dbh = $self->dbh();

    # Get CGI Query object
    my $q = $self->query();

    # TT Params
    my %params = ( 'current' => 'domains', );

    my $domain_id = $q->param('domain_id') || undef;

    if ( !$domain_id || $domain_id !~ m/^\d+$/ ) {
        my $msg = "Invalid Domain-ID.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $msg );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    my $sql = undef;
    my $sth = undef;

    # Get Domain name
    $sql = "SELECT name FROM domains WHERE id = ?";
    $sth = $dbh->prepare($sql);
    if ( !$sth ) {
        $self->log( 'Preparing SQL ' . $sql . ' failed w/ error: ' . $dbh->errstr, 'error', );
        $self->add_message( 'error', 'Database error!' );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
    }
    if ( !$sth->execute($domain_id) ) {
        $self->log( 'Executing SQL ' . $sql . ' failed w/ error: ' . $sth->errstr, 'error', );
        $self->add_message( 'error', 'Database error!' );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
    }
    my $domain_name = $sth->fetchrow_array();
    $sth->finish();
    $params{'title'} = $self->{lh}->maketext( 'VBoxAdm Domain: [_1]', $domain_name );
    $params{'domain'} = $domain_name;

    # Get Aliases
    $sql = "SELECT id,local_part,goto,is_active FROM aliases WHERE domain_id = ? ORDER BY local_part";
    $sth = $dbh->prepare($sql);
    if ( !$sth ) {
        $self->log( 'Preparing SQL ' . $sql . ' failed w/ error: ' . $dbh->errstr, 'error', );
        $self->add_message( 'error', 'Database error!' );
        return $self->tt_process( 'vboxadm/domain/show.tpl', \%params );
    }
    if ( !$sth->execute($domain_id) ) {
        $self->log( 'Executing SQL ' . $sql . ' failed w/ error: ' . $dbh->errstr, 'error', );
        $self->add_message( 'error', 'Database error!' );
        return $self->tt_process( 'vboxadm/domain/show.tpl', \%params );
    }
    my @aliases = ();
    while ( my ( $id, $local_part, $goto, $is_active ) = $sth->fetchrow_array() ) {
        push( @aliases, { id => $id, local_part => $local_part, 'goto' => $goto, is_active => $is_active, } );
    }
    $sth->finish();
    $params{'aliases'} = \@aliases;

    # Get Mailboxes
    $sql = "SELECT id,local_part,name,is_active FROM mailboxes WHERE domain_id = ? ORDER BY local_part";
    $sth = $dbh->prepare($sql);
    if ( !$sth ) {
        $self->log( 'Preparing SQL ' . $sql . ' failed w/ error: ' . $dbh->errstr, 'error', );
        $self->add_message( 'error', 'Database error!' );
        return $self->tt_process( 'vboxadm/domain/show.tpl', \%params );
    }
    if ( !$sth->execute($domain_id) ) {
        $self->log( 'Executing SQL ' . $sql . ' failed w/ error: ' . $dbh->errstr, 'error', );
        $self->add_message( 'error', 'Database error!' );
        return $self->tt_process( 'vboxadm/domain/show.tpl', \%params );
    }
    my @mailboxes = ();
    while ( my ( $id, $local_part, $name, $is_active ) = $sth->fetchrow_array() ) {
        push( @mailboxes, { id => $id, local_part => $local_part, name => $name, is_active => $is_active, } );
    }
    $sth->finish();
    $params{'mailboxes'} = \@mailboxes;

    # Get Domain Aliases
    $sql = "SELECT id,name,is_active FROM domain_aliases WHERE domain_id = ? ORDER BY name";
    $sth = $dbh->prepare($sql);
    if ( !$sth ) {
        $self->log( 'Preparing SQL ' . $sql . ' failed w/ error: ' . $dbh->errstr, 'error', );
        $self->add_message( 'error', 'Database error!' );
        return $self->tt_process( 'vboxadm/domain/show.tpl', \%params );
    }
    if ( !$sth->execute($domain_id) ) {
        $self->log( 'Executing SQL ' . $sql . ' failed w/ error: ' . $dbh->errstr, 'error', );
        $self->add_message( 'error', 'Database error!' );
        return $self->tt_process( 'vboxadm/domain/show.tpl', \%params );
    }
    my @domain_aliases = ();
    while ( my ( $id, $name, $is_active ) = $sth->fetchrow_array() ) {
        push( @domain_aliases, { id => $id, name => $name, is_active => $is_active, } );
    }
    $sth->finish();
    $params{'domain_aliases'} = \@domain_aliases;

    # Render template
    return $self->tt_process( 'vboxadm/domain/show.tpl', \%params );
}

sub show_create_domain {
    my $self = shift;

    if ( !$self->user->is_siteadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    my %params = (
        'title'   => $self->{lh}->maketext('Add Domain'),
        'current' => 'domains',
    );

    # Render template
    return $self->tt_process( 'vboxadm/domain/create.tpl', \%params );
}

sub show_add_domain {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $domain             = &VWebAdm::Utils::trim( lc( $q->param('domain') ) );
    my $create_domainadmin = $q->param('create_domainadmin');

    if ( $self->{'Domain'}->create($domain) ) {
        $self->log( 'Create new domain ' . $domain );
        if ($create_domainadmin) {
            my $domain_id = $self->{'Domain'}->get_id($domain);
            if ( $self->{'Mailbox'}->create( 'domainadmin', $domain_id ) ) {
                $self->log( 'Created domainadmin mailbox for ' . $domain );
            }
            else {
                $self->log( 'Failed to create domainadmin for ' . $domain );
            }
        }
    }

    # Redirect to other page, no need to render anything
    $self->redirect( $self->{base_url} . '?rm=domains' );
    return;
}

sub show_remove_domain {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $domain_id = $q->param('domain_id');

    if ( $self->{'Domain'}->delete($domain_id) ) {
        $self->log( 'Deleted domain #' . $domain_id );
    }
    else {
        $self->log( 'Failed to delete Domain #' . $domain_id );
    }

    $self->redirect( $self->{base_url} . '?rm=domains' );
    return;
}

sub _translate_params {
    my $self  = shift;
    my $mapping = shift;
    
    my $params = {};
    foreach my $src_key ( sort keys %{$mapping}) {
        my $dst_key = $mapping->{$src_key}->{'Name'};
        my $type    = $mapping->{$src_key}->{'Type'};
        my $default = $mapping->{$src_key}->{'Default'};
        if($type eq 'Str' && $self->query()->param($src_key)) {
            $params->{$dst_key} = &VWebAdm::Utils::trim($self->query()->param($src_key));
        } elsif($type eq 'Str' && $default) {
            $params->{$dst_key} = $default;
        } elsif($type eq 'Bool') {
            my $val = $self->query()->param($src_key);
            if(defined($val) && $val =~ m/^(?:on|1)$/i) {
                $params->{$dst_key} = 1;
            } else {
                $params->{$dst_key} = 0;
            }
            #$self->log( 'Set Bool key '.$dst_key.' to '.$params->{$dst_key}, 'debug', );
        }
    }
    
    return $params;
}

sub show_update_domain {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $domain_id = $q->param('domain_id');
    my %mapping = (
        'is_active' => { 'Type' => 'Bool', 'Name' => 'IsActive', },
    );
    my $params = $self->_translate_params(\%mapping);

    if ( $self->{'Domain'}->update( $domain_id, $params ) ) {
        $self->log( 'Updated Domain #' . $domain_id );
    }
    else {
        $self->log( 'Failed to update Domain #' . $domain_id );
    }

    $self->redirect( $self->{base_url} . '?rm=domains' );
    return;
}

#
# Domain Aliases
#

sub show_domain_aliases {
    my $self = shift;

    # Get our database connection
    my $dbh = $self->dbh();

    # Get CGI Query object
    my $q = $self->query();

    my $search = $q->param('search');
    my %params = ( 'Search' => $search, );

    my @domains = $self->{'DomainAlias'}->list( \%params );

    %params = (
        'title'   => $self->{lh}->maketext('VBoxAdm Domain-Aliases'),
        'current' => 'domain_aliases',
        'domains' => \@domains,
        'search'  => $search,
    );

    return $self->tt_process( 'vboxadm/domain_alias/list.tpl', \%params );
}

sub show_create_domain_alias {
    my $self = shift;

    if ( !$self->user->is_siteadmin() && !$self->user->is_domainadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get our database connection
    my $dbh = $self->dbh();

    # TT Params
    my %params = (
        'title'   => $self->{lh}->maketext('Add Domain Alias'),
        'current' => 'domain_aliases',
    );

    my $query = "SELECT id,name,is_active FROM domains WHERE 1";
    my @args  = ();
    if ( !$self->user->is_siteadmin() && $self->user->is_domainadmin() ) {
        $query .= ' AND id = ?';
        push( @args, $self->user->get_domain_id() );
    }
    $query .= ' ORDER BY name';
    my $sth = $dbh->prepare($query);
    if ( !$sth ) {
        $self->add_message( 'error', 'Database Error!' );
        $self->log( 'Could not prepare Query: ' . $query . ', Error: ' . $dbh->errstr, 'error', );
        return $self->tt_process( 'vboxadm/domain_alias/create.tpl', \%params );
    }
    if ( !$sth->execute(@args) ) {
        $self->add_message( 'error', 'Database Error!' );
        $self->log( 'Could not execute Query: ' . $query . ', Args: ' . join( "-", @args ) . ', Error: ' . $sth->errstr, 'warning', );
        return $self->tt_process( 'vboxadm/domain_alias/create.tpl', \%params );
    }

    my @domains = ();
    while ( my @row = $sth->fetchrow_array() ) {
        push( @domains, { id => $row[0], name => $row[1], is_active => $row[2], } );
    }
    $params{'domains'} = \@domains;

    return $self->tt_process( 'vboxadm/domain_alias/create.tpl', \%params );
}

sub show_add_domain_alias {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $domain_alias = &VWebAdm::Utils::trim( lc( $q->param('domain_alias') ) );
    my $domain_id    = $q->param('domain');

    if ( $self->{'DomainAlias'}->create( $domain_alias, $domain_id ) ) {
        $self->log( 'Added Domain-Alias ' . $domain_alias . ' to base Domain #' . $domain_id );
    }
    else {
        $self->log( 'Failed to add Domain-Alias ' . $domain_alias . ' to base Domain #' . $domain_id );
        $self->add_message( 'error', 'Database Error!' );
    }

    $self->redirect( $self->{base_url} . '?rm=domain_aliases' );
    return;
}

sub show_remove_domain_alias {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $domain_alias_id = $q->param('domain_alias_id');

    if ( $self->{'DomainAlias'}->delete($domain_alias_id) ) {
        $self->log( 'Deleted Domain-Alias #' . $domain_alias_id );
    }
    else {
        $self->log( 'Failed to delete Domain-Alias #' . $domain_alias_id );
        $self->add_message( 'error', 'Database Error!' );
    }

    $self->redirect( $self->{base_url} . '?rm=domain_aliases' );
    return;
}

sub show_edit_domain_alias {
    my $self = shift;

    if ( !$self->user->is_siteadmin() && !$self->user->is_domainadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get our database connection
    my $dbh = $self->dbh();

    # Get CGI Query object
    my $q = $self->query();

    # TT Params
    my %params = (
        'title'   => $self->{lh}->maketext('Edit Domain Alias'),
        'current' => 'domain_aliases',
    );

    my $domain_alias_id = $q->param('domain_alias_id');

    $params{'domains'} = [ $self->{'Domain'}->list() ];

    my $query = 'SELECT da.id, da.name, da.domain_id, da.is_active, d.name FROM domain_aliases AS da';
    $query .= ' LEFT JOIN domains AS d ON da.domain_id = d.id WHERE da.id = ?';
    my @args = ();
    push( @args, $domain_alias_id );
    if ( !$self->user->is_siteadmin() && $self->user->is_domainadmin() ) {
        $query .= ' AND da.domain_id = ?';
        push( @args, $self->user->get_domain_id() );
    }
    my $sth = $dbh->prepare($query);
    if ( !$sth ) {
        $self->add_message( 'error', 'Database Error!' );
        $self->log( 'Could not prepare Query: ' . $query . ', Error: ' . DBI->errstr, 'warning', );
        return $self->tt_process( 'vboxadm/domain_alias/edit.tpl', \%params );
    }
    if ( !$sth->execute(@args) ) {
        $self->add_message( 'error', 'Database Error!' );
        $self->log( 'Could not execute Query: ' . $query . ', Args: ' . join( "-", @args ) . ', Error: ' . $sth->errstr, 'warning', );
        return $self->tt_process( 'vboxadm/domain_alias/edit.tpl', \%params );
    }
    my ( $da_id, $da_name, $domain_id, $is_active, $domain_name ) = $sth->fetchrow_array();
    $sth->finish();

    $params{'domain_name'}     = $domain_name;
    $params{'is_active'}       = $is_active;
    $params{'target'}          = $domain_id;
    $params{'domain_alias_id'} = $da_id;

    return $self->tt_process( 'vboxadm/domain_alias/edit.tpl', \%params );
}

sub show_update_domain_alias {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $domain_alias_id = $q->param('domain_alias_id');
    my %mapping = (
        'is_active' => { 'Type' => 'Bool', 'Name' => 'IsActive', },
        'target'    => { 'Type' => 'Str', 'Name' => 'Goto', },
    );
    my $params = $self->_translate_params(\%mapping);

    if ( $self->{'DomainAlias'}->update( $domain_alias_id, $params ) ) {
        $self->log( 'Updated Domain-Alias #' . $domain_alias_id );
    }
    else {
        $self->log( 'Failed to update Domain-Alias #' . $domain_alias_id );
        $self->add_message( 'error', 'Database Error!' );
    }

    $self->redirect( $self->{base_url} . '?rm=domain_aliases' );
    return;
}

#
# Aliases
#

sub show_aliases {
    my $self = shift;

    # Get our database connection
    my $dbh = $self->dbh();

    # Get CGI Query object
    my $q = $self->query();

    my $search = $q->param('search');
    my %params = ( 'Search' => $search, );

    my @aliases = $self->{'Alias'}->list( \%params );
    my @domains = $self->{'Domain'}->list();

    %params = (
        'title'   => $self->{lh}->maketext('VBoxAdm Aliases'),
        'current' => 'aliases',
        'aliases' => \@aliases,
        'domains' => \@domains,
        'search'  => $search,
    );

    return $self->tt_process( 'vboxadm/alias/list.tpl', \%params );
}

sub show_create_alias {
    my $self = shift;

    if ( !$self->user->is_siteadmin() && !$self->user->is_domainadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    my @domains = $self->{'Domain'}->list();

    my %params = (
        'title'   => $self->{lh}->maketext('Add Alias'),
        'current' => 'aliases',
        'domains' => \@domains,
    );

    return $self->tt_process( 'vboxadm/alias/create.tpl', \%params );
}

sub show_add_alias {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my @local_parts = ();
    my $local_part  = &VWebAdm::Utils::trim( lc( $q->param('local_part') ) );
    push(@local_parts,$local_part);
    my $domain_id  = $q->param('domain');
    my $goto       = $q->param('goto');
    my $is_mailman = $q->param('is_mailman');
    
    if($is_mailman && $is_mailman eq 'on') {
        foreach my $suffix (qw(admin bounces confirm join leave owner request subscribe unsubscribe)) {
            push(@local_parts,$local_part.'-'.$suffix);
        }
    }

    foreach my $alias (@local_parts) {
        if ( $self->{'Alias'}->create( $alias, $domain_id, $goto ) ) {
            $self->log( 'Added Alias ' . $alias . '@' . $domain_id . ' => ' . $goto );
        }
        else {
            $self->log( 'Failed to add Alias ' . $alias . '@' . $domain_id . ' => ' . $goto );
            $self->add_message( 'error', 'Database Error!' );
        }
    }

    $self->redirect( $self->{base_url} . '?rm=aliases' );
    return;
}

sub show_remove_alias {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $alias_id = $q->param('alias_id');

    if ( $self->{'Alias'}->delete($alias_id) ) {
        $self->log( 'Deleted alias #' . $alias_id );
    }
    else {
        $self->log( 'Failed to delete alias #' . $alias_id );
        $self->add_message( 'error', 'Database Error!' );
    }

    $self->redirect( $self->{base_url} . '?rm=aliases' );
    return;
}

sub show_edit_alias {
    my $self = shift;

    if ( !$self->user->is_siteadmin() && !$self->user->is_domainadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get CGI Query object
    my $q = $self->query();

    my $alias_id  = $q->param('alias_id');
    my $alias_ref = $self->{'Alias'}->read($alias_id);

    my %params = (
        'title'    => $self->{lh}->maketext('Edit Alias'),
        'alias_id' => $alias_id,
        'current'  => 'aliases',
    );

    foreach my $key ( keys %{$alias_ref} ) {
        $params{$key} = $alias_ref->{$key};
    }

    return $self->tt_process( 'vboxadm/alias/edit.tpl', \%params );
}

sub show_update_alias {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my %mapping = (
        'is_active' => { 'Type' => 'Bool', 'Name' => 'IsActive', },
        'goto'      => { 'Type' => 'Str', 'Name' => 'Goto', },
    );
    my $params = $self->_translate_params(\%mapping);

    my $alias_id = $q->param('alias_id');

    if ( $self->{'Alias'}->update( $alias_id, $params ) ) {
        $self->log( 'Updated Alias #' . $alias_id );
    }
    else {
        $self->log( 'Failed to update Alias #' . $alias_id );
        $self->add_message( 'error', 'Database Error!' );
    }

    $self->redirect( $self->{base_url} . '?rm=aliases' );
    return;
}

#
# Mailboxes
#

sub show_mailboxes {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $page   = $q->param('page') || 1;
    my $search = $q->param('search');
    my %params = ( 'Search' => $search, );

    my @mailboxes = $self->{'Mailbox'}->list( \%params );
    my @domains   = $self->{'Domain'}->list();
    
    my $show_quota = $self->{'config'}{'cgi'}{'show_quota'} || 0;

    %params = (
        'title'     => $self->{lh}->maketext('VBoxAdm Mailboxes'),
        'current'   => 'mailboxes',
        'mailboxes' => \@mailboxes,
        'domains'   => \@domains,
        'search'    => $search,
        'show_quota' => $show_quota,
    );

    return $self->tt_process( 'vboxadm/mailbox/list.tpl', \%params );
}

sub show_create_mailbox {
    my $self = shift;

    if ( !$self->user->is_admin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    my @domains = $self->{'Domain'}->list();

    my %params = (
        'title'           => $self->{lh}->maketext('Add Mailbox'),
        'domains'         => \@domains,
        'current'         => 'mailboxes',
        'max_msg_size_mb' => 25,
        'sa_kill_score'   => 6.31,
        'sa_active'       => 1,
    );

    return $self->tt_process( 'vboxadm/mailbox/create.tpl', \%params );
}

sub show_add_mailbox {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $domain_id  = $q->param('domain');
    my $local_part = &VWebAdm::Utils::trim( lc( $q->param('username') ) );
    my %mapping = (
        'new_password_1'    => { 'Type' => 'Str', 'Name' => 'Password', },
        'new_password_2'    => { 'Type' => 'Str', 'Name' => 'PasswordAgain', },
        'name'              => { 'Type' => 'Str', 'Name' => 'Name', },
        'is_active'         => { 'Type' => 'Bool', 'Name' => 'IsActive', },
        'send_welcome_mail' => { 'Type' => 'Bool', 'Name' => 'SendWelcomeMail', },
        'max_msg_size_mb'   => { 'Type' => 'Str', 'Name' => 'MaxMsgSize', 'Default' => 20, },
        'sa_active'         => { 'Type' => 'Bool', 'Name' => 'SAActive', },
        'sa_kill_score'     => { 'Type' => 'Str', 'Name' => 'SAKillScore', 'Default' => $self->{'config'}{'cgi'}{'sa_default_block_score'} || 6.31, },
    );
    my $params = $self->_translate_params(\%mapping);
    $params->{'IsSiteadmin'} = 0;
    $params->{'IsDomainadmin'} = 0;

    if ( $self->{'Mailbox'}->create( $local_part, $domain_id, $params ) ) {
        $self->log( 'Added Mailbox ' . $local_part . '@' . $domain_id );
    }
    else {
        $self->log( 'Failed to add Mailbox ' . $local_part . '@' . $domain_id );
        $self->add_message( 'error', 'Database Error!' );
    }

    $self->redirect( $self->{base_url} . '?rm=mailboxes' );
    return;
}

sub show_remove_mailbox {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $mailbox_id = $q->param('mailbox_id');

    if ( $self->{'Mailbox'}->delete($mailbox_id) ) {
        $self->log( 'Remove mailbox #' . $mailbox_id );
    }
    else {
        $self->log( 'Failed to remove Mailbox #' . $mailbox_id );
        $self->add_message( 'error', 'Database Error!' );
    }

    $self->redirect( $self->{base_url} . '?rm=mailboxes' );
    return;
}

sub show_edit_mailbox {
    my $self = shift;

    if ( !$self->user->is_admin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get our database connection
    my $dbh = $self->dbh();

    # Get CGI Query object
    my $q = $self->query();

    # TT Params
    my %params = (
        'title'             => $self->{lh}->maketext('Edit Mailbox'),
        'user_is_siteadmin' => $self->user->is_siteadmin(),
        'current'           => 'mailboxes',
    );

    my $mailbox_id = $q->param('mailbox_id');
    $params{'mailbox_id'} = $mailbox_id;
    my $mailbox_ref = $self->{'Mailbox'}->read($mailbox_id);
    $params{'mb_is_domainadmin'} = $mailbox_ref->{'is_domainadmin'};
    $params{'mb_is_siteadmin'}   = $mailbox_ref->{'is_siteadmin'};
    $params{'pw_lock'}           = $mailbox_ref->{'pw_lock'};
    my $domain_id = $mailbox_ref->{'domain_id'};

    # show aliases pointing to this mbox, don't forget domain aliases!
    # show cc (aliases w/ the same name as this mailbox)
    my $query = "SELECT id,goto FROM aliases WHERE local_part = (SELECT local_part FROM mailboxes WHERE id = ?) AND domain_id = ? ";
    my @args  = ();
    push( @args, $mailbox_id );
    push( @args, $domain_id );
    if ( !$self->user->is_siteadmin() ) {
        $query .= "AND domain_id = ?";
        push( @args, $self->user->get_domain_id() );
    }
    my $sth = $dbh->prepare($query);
    if ( !$sth ) {
        $self->add_message( 'error', 'Database Error!' );
        $self->log( 'Could not prepare Query: ' . $query . ', Error: ' . DBI->errstr, 'warning', );
        return $self->tt_process( 'vboxadm/mailbox/edit.tpl', \%params );
    }
    if ( !$sth->execute(@args) ) {
        $self->add_message( 'error', 'Database Error!' );
        $self->log( 'Could not execute Query: ' . $query . ', Args: ' . join( "-", @args ) . ', Error: ' . $sth->errstr, 'warning', );
        return $self->tt_process( 'vboxadm/mailbox/edit.tpl', \%params );
    }
    my ( $cc_id, $cc_goto ) = $sth->fetchrow_array();
    $params{'cc_id'}   = $cc_id;
    $params{'cc_goto'} = $cc_goto;
    $sth->finish();

    foreach my $key ( keys %{$mailbox_ref} ) {
        $params{$key} = $mailbox_ref->{$key};
    }

    if ( $params{'vacation_start'} && $params{'vacation_start'} =~ m/^\s*(\d\d\d\d)-(\d\d)-(\d\d)\s*$/ ) {
        $params{'vacation_start'} = "$3.$2.$1";
    }
    if ( $params{'vacation_end'} && $params{'vacation_end'} =~ m/^\s*(\d\d\d\d)-(\d\d)-(\d\d)\s*$/ ) {
        $params{'vacation_end'} = "$3.$2.$1";
    }

    return $self->tt_process( 'vboxadm/mailbox/edit.tpl', \%params );
}

sub show_update_mailbox {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $mailbox_id = $q->param('mailbox_id');

    my %mapping = (
        'new_password_1'    => { 'Type' => 'Str', 'Name' => 'Password', },
        'new_password_2'    => { 'Type' => 'Str', 'Name' => 'PasswordAgain', },
        'name'              => { 'Type' => 'Str', 'Name' => 'Name', },
        'is_active'         => { 'Type' => 'Bool', 'Name' => 'IsActive', },
        'max_msg_size_mb'   => { 'Type' => 'Str', 'Name' => 'MaxMsgSize', 'Default' => 20, },
        'sa_active'         => { 'Type' => 'Bool', 'Name' => 'SAActive', },
        'sa_kill_score'     => { 'Type' => 'Str', 'Name' => 'SAKillScore', 'Default' => $self->{'config'}{'cgi'}{'sa_default_block_score'} || 6.31, },
        'is_siteadmin'      => { 'Type' => 'Bool', 'Name' => 'IsSiteadmin', },
        'is_domainadmin'    => { 'Type' => 'Bool', 'Name' => 'IsDomainadmin', },
        'is_on_vacation'    => { 'Type' => 'Bool', 'Name' => 'IsOnVacation', },
        'vacation_msg'      => { 'Type' => 'Str', 'Name' => 'VacationMessage', },
        'vacation_subj'     => { 'Type' => 'Str', 'Name' => 'VacationSubject', },
        'vacation_start'    => { 'Type' => 'Str', 'Name' => 'VacationStart', },
        'vacation_end'      => { 'Type' => 'Str', 'Name' => 'VacationEnd', },
        'quota'             => { 'Type' => 'Str', 'Name' => 'Quota', },
    );
    my $params = $self->_translate_params(\%mapping);

    if ( $self->{'Mailbox'}->update( $mailbox_id, $params ) ) {
        $self->log( 'Updated Mailbox #' . $mailbox_id );
    }
    else {
        $self->log( 'Failed to update Mailbox #' . $mailbox_id );
        $self->add_message( 'error', 'Database Error!' );
    }
    $self->redirect( $self->{base_url} . '?rm=mailboxes' );
    return;
}

#
# Log
#

sub show_log {
    my $self = shift;

    if ( !$self->user->is_siteadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get CGI Query object
    my $q = $self->query();

    # Get our database connection
    my $dbh = $self->dbh();

    # TT Params
    my %params = (
        'title'   => $self->{lh}->maketext('VBoxAdm Log'),
        'current' => 'log',
    );

    my $search = $q->param('search') || '';
    $params{'search'} = $search;
    my $page = $q->param('page') || 1;

    my @args  = ();
    my $query = "SELECT ts,msg FROM log ";
    if ($search) {
        $query .= "WHERE msg LIKE ? ";
        $search =~ s/%//g;
        my $search_arg = "%" . $search . "%";
        push( @args, $search_arg );
    }
    $query .= "ORDER BY ts DESC";

    # Get the actual data
    my $sth = $dbh->prepare($query);
    if ( !$sth ) {
        $self->add_message( 'error', 'Database Error!' );
        $self->log( 'Could not prepare Query: ' . $query . ', Error: ' . DBI->errstr, 'warning', );
        return $self->tt_process( 'vwebadm/log.tpl', \%params );
    }
    if ( !$sth->execute(@args) ) {
        $self->add_message( 'error', 'Database Error!' );
        $self->log( 'Could not execute Query: ' . $query . ', Args: ' . join( "-", @args ) . ', Error: ' . $sth->errstr, 'warning', );
        return $self->tt_process( 'vwebadm/log.tpl', \%params );
    }

    my @log = ();
    while ( my @row = $sth->fetchrow_array() ) {
        push( @log, { ts => $row[0], msg => $row[1], } );
    }
    $sth->finish();
    $params{'log'} = \@log;

    return $self->tt_process( 'vwebadm/log.tpl', \%params );
}

#
# Vacation Blacklist
#
sub show_vacation_blacklist {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $page   = $q->param('page') || 1;
    my $search = $q->param('search');
    my %params = (
        'Search' => $search,
        'Order'  => 'domain',
    );

    my @blacklist = $self->{'VacationBlacklist'}->list( \%params );

    %params = (
        'title'     => $self->{lh}->maketext('VBoxAdm Vacation Blacklist'),
        'current'   => 'vacation',
        'blacklist' => \@blacklist,
        'search'    => $search,
    );

    return $self->tt_process( 'vboxadm/vacation_blacklist/list.tpl', \%params );
}

sub show_create_vacbl_entry {
    my $self = shift;

    if ( !$self->user->is_siteadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get CGI Query object
    my $q = $self->query();

    my %params = (
        'title'   => $self->{lh}->maketext('VBoxAdm Vacation Blacklist - Create Entry'),
        'current' => 'vacation',
    );

    return $self->tt_process( 'vboxadm/vacation_blacklist/create.tpl', \%params );
}

sub show_add_vacbl_entry {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $email = $q->param('email') || undef;

    if ( $self->{'VacationBlacklist'}->create($email) ) {
        $self->log( 'Created vacation blacklist entry: ' . $email );
    }
    else {
        $self->log( 'Failed to create vacation blacklist entry: ' . $email );
        $self->add_message( 'error', 'Database Error!' );
    }

    $self->redirect( $self->{base_url} . '?rm=vac_bl' );
    return;
}

sub show_remove_vacbl_entry {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $entry_id = $q->param('entry_id') || undef;

    if ( $self->{'VacationBlacklist'}->delete($entry_id) ) {
        $self->log( 'Deleted vacation blacklist entry #' . $entry_id );
    }
    else {
        $self->log( 'Failed to delete vacation blacklist entry #' . $entry_id );
        $self->add_message( 'error', 'Database Error!' );
    }

    $self->redirect( $self->{base_url} . '?rm=vac_bl' );
    return;
}

sub show_vacation_replies {
    my $self = shift;

    if ( !$self->user->is_siteadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get CGI Query object
    my $q = $self->query();

    # Get our database connection
    my $dbh = $self->dbh();

    my $search = $q->param('search') || '';

    # TT Params
    my %params = (
        'title'   => $self->{lh}->maketext('VBoxAdm Vacation Notifications'),
        'current' => 'vacation',
        'search'  => $search,
    );

    my @args  = ();
    my $query = "SELECT on_vacation,notified,notified_at FROM vacation_notify ";
    if ($search) {
        $query .= "WHERE on_vacation LIKE ? OR notified LIKE ? ";
        $search =~ s/%//g;
        my $search_arg = "%" . $search . "%";
        push( @args, $search_arg );
        push( @args, $search_arg );
    }
    $query .= "ORDER BY on_vacation,notified,notified_at";
    my $sth = $dbh->prepare($query);
    if ( !$sth ) {
        $self->add_message( 'error', 'Database Error!' );
        $self->log( 'Could not prepare Query: ' . $query . ', Error: ' . DBI->errstr, 'warning', );
        return $self->tt_process( 'vboxadm/vacation_notify/list.tpl', \%params );
    }
    if ( !$sth->execute(@args) ) {
        $self->add_message( 'error', 'Database Error!' );
        $self->log( 'Could not execute Query: ' . $query . ', Args: ' . join( "-", @args ) . ', Error: ' . $sth->errstr, 'warning', );
        return $self->tt_process( 'vboxadm/vacation_notify/list.tpl', \%params );
    }
    my @notifies = ();
    while ( my ( $on_vacation, $notified, $notified_at ) = $sth->fetchrow_array() ) {
        push(
            @notifies,
            {
                'on_vacation' => $on_vacation,
                'notified'    => $notified,
                'notified_at' => $notified_at,
            }
        );
    }
    $sth->finish();
    $params{'notifies'} = \@notifies;

    return $self->tt_process( 'vboxadm/vacation_notify/list.tpl', \%params );
}

#
# RFC Notify
#

sub show_rfc_notify {
    my $self = shift;

    if ( !$self->user->is_siteadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get CGI Query object
    my $q = $self->query();

    # Get our database connection
    my $dbh = $self->dbh();

    my $search = $q->param('search') || '';

    my $params = { 'Order' => 'ts', };
    $params->{'search'} = $search if $search;
    my @notifies = $self->{'RFCNotify'}->list();

    my %params = (
        'title'    => $self->{lh}->maketext('VBoxAdm RFC Notifications'),
        'current'  => 'notify',
        'notifies' => \@notifies,
        'search'   => $search,
    );

    return $self->tt_process( 'vboxadm/rfc_notify/list.tpl', \%params );
}

#
# Auto-Whitelist
#
sub show_awl {
    my $self = shift;

    # Get our database connection
    my $dbh = $self->dbh();

    # Get CGI Query object
    my $q = $self->query();

    my $page   = $q->param('page') || 1;
    my $search = $q->param('search');
    my %params = (
        'Search' => $search,
        'Order'  => 'email',
    );

    my @awl = $self->{'AWL'}->list( \%params );

    %params = (
        'title'   => $self->{lh}->maketext('VBoxAdm Auto-Whitelist'),
        'current' => 'awl',
        'awl'     => \@awl,
        'search'  => $search,
    );

    return $self->tt_process( 'vboxadm/awl/list.tpl', \%params );
}

sub show_update_awl {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $entry_id = $q->param('entry_id') || undef;
    my %params = ( 'Disabled' => $q->param('disabled'), );

    if ( $self->{'AWL'}->update( $entry_id, \%params ) ) {
        $self->log( 'Updated AWL entry #' . $entry_id );
    }
    else {
        $self->log( 'Failed to update AWL entry #' . $entry_id );
        $self->add_message( 'error', 'Database Error!' );
    }

    $self->redirect( $self->{base_url} . '?rm=awl' );
    return;
}

#
# Admins
#

sub show_admins {
    my $self = shift;

    if ( !$self->user->is_siteadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get our database connection
    my $dbh = $self->dbh();

    # Get CGI Query object
    my $q = $self->query();

    my $page   = $q->param('page') || 1;
    my $search = $q->param('search');
    my %params = (
        'Search'  => $search,
        'IsAdmin' => 1,
    );

    my @mailboxes = $self->{'Mailbox'}->list( \%params );

    %params = (
        'title'   => $self->{lh}->maketext('VBoxAdm Admins'),
        'current' => 'admins',
        'admins'  => \@mailboxes,
        'search'  => $search,
    );

    return $self->tt_process( 'vboxadm/mailbox/admins.tpl', \%params );
}

#
# RoleAccounts
#
sub show_role_accounts {
    my $self = shift;

    # Get our database connection
    my $dbh = $self->dbh();

    # Get CGI Query object
    my $q = $self->query();

    my $search = $q->param('search');
    my %params = (
        'Search' => $search,
        'Order'  => 'domain',
    );

    my @roleacc = $self->{'RoleAccount'}->list( \%params );

    %params = (
        'title'    => $self->{lh}->maketext('VBoxAdm Role Accounts'),
        'current'  => 'vacation',
        'roleaccs' => \@roleacc,
        'search'   => $search,
    );

    return $self->tt_process( 'vboxadm/role_account/list.tpl', \%params );
}

sub show_add_role_account {
    my $self = shift;

    if ( !$self->user->is_siteadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get CGI Query object
    my $q = $self->query();

    my $role = $q->param('role');
    my $goto = &VWebAdm::Utils::trim( lc( $q->param('goto') ) );

    $self->{'RoleAccount'}->create( $role, $goto );

    $self->redirect( $self->{base_url} . '?rm=role_accounts' );
    return;
}

sub show_create_role_account {
    my $self = shift;

    if ( !$self->user->is_siteadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    my %params = (
        'title'   => $self->{lh}->maketext('VBoxAdm Role Accounts - Create Entry'),
        'current' => 'roleacc',
    );

    return $self->tt_process( 'vboxadm/role_account/create.tpl', \%params );
}

sub show_edit_role_account {
    my $self = shift;

    if ( !$self->user->is_admin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get CGI Query object
    my $q = $self->query();

    my $roleacc_id  = $q->param('roleacc_id');
    my $roleacc_ref = $self->{'RoleAccount'}->read($roleacc_id);

    my %params = (
        'title'      => $self->{lh}->maketext('Edit Alias'),
        'roleacc_id' => $roleacc_id,
        'current'    => 'roleaccs',
    );

    foreach my $key ( keys %{$roleacc_ref} ) {
        $params{$key} = $roleacc_ref->{$key};
    }

    return $self->tt_process( 'vboxadm/role_account/edit.tpl', \%params );
}

sub show_remove_role_account {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $roleacc_id = $q->param('roleacc_id');

    if ( $self->{'RoleAccount'}->delete($roleacc_id) ) {
        $self->log( 'Deleted Role-Account #' . $roleacc_id );
    }
    else {
        $self->log( 'Failed to delete Role-Account #' . $roleacc_id );
        $self->add_message( 'error', 'Database Error!' );
    }

    $self->redirect( $self->{base_url} . '?rm=roleaccs' );
    return;
}

sub show_update_role_account {
    my $self = shift;

    # Get CGI Query object
    my $q = $self->query();

    my $roleacc_id = $q->param('roleacc_id');
    my %mapping = (
        'goto'    => { 'Type' => 'Str', 'Name' => 'Goto', },
    );
    my $params = $self->_translate_params(\%mapping);

    if ( $self->{'RoleAccount'}->update( $roleacc_id, $params ) ) {
        $self->log( 'Updated Role-Account #' . $roleacc_id );
    }
    else {
        $self->log( 'Failed to update Role-Account #' . $roleacc_id );
        $self->add_message( 'error', 'Database Error!' );
    }

    $self->redirect( $self->{base_url} . '?rm=roleaccs' );
    return;
}

#
# DMARC
#

sub show_dmarc_reports {
    my $self = shift;
    
    if ( !$self->user->is_siteadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get our database connection
    my $dbh = $self->dbh();

    # Get CGI Query object
    my $q = $self->query();

    my $search = $q->param('search');
    my %params = (
        'Search' => $search,
        'Order'  => 'tsfrom',
    );

    my @reports = $self->{'DMARCReport'}->list( \%params );

    %params = (
        'title'    => $self->{lh}->maketext('VBoxAdm DMARC Reports'),
        'current'  => 'dmarc',
        'reports'  => \@reports,
        'search'   => $search,
    );

    return $self->tt_process( 'vboxadm/dmarc_report/list.tpl', \%params );
}

sub show_dmarc_report {
    my $self = shift;
    
    if ( !$self->user->is_siteadmin() ) {
        my $msg = "You are not authorized to access this page.";
        $self->log( $msg . ". User: " . $self->authen->username );
        $self->add_message( 'error', $self->{lh}->maketext($msg) );
        $self->redirect( $self->{base_url} . '?rm=welcome' );
        return;
    }

    # Get our database connection
    my $dbh = $self->dbh();

    # Get CGI Query object
    my $q = $self->query();

    my $report_id  = $q->param('report_id');
    my $report_ref = $self->{'DMARCReport'}->read($report_id);
    
    my @records    = $self->{'DMARCRecord'}->list( {'report_id' => $report_id,} );

    my %params = (
        'title'      => $self->{lh}->maketext('Show DMARC Report'),
        'report_id'  => $report_id,
        'current'    => 'dmarc',
        'records'    => \@records,
    );

    foreach my $key ( keys %{$report_ref} ) {
        $params{$key} = $report_ref->{$key};
    }

    return $self->tt_process( 'vboxadm/dmarc_report/show.tpl', \%params );
}

1;

__END__

=head1 NAME

VBoxAdm::Controller::Frontend - Frontend for VBoxAdm

=cut