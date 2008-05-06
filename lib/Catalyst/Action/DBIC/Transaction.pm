{   package Catalyst::Action::DBIC::Transaction;
    use strict;
    use warnings;
    use base 'Catalyst::Action';
    use Class::C3;
    use Sub::Name 'subname';

    sub execute {
        my $self = shift;
        my ( $controller, $c ) = @_;

        my $schema_class = $controller->_dbic_transaction_schemas->{$self->name}
          or die 'No schema class defined for DBIC::Transaction ActionClass';

        my $wantarray = wantarray;
        my ($return, @return, $success);

        my $sub = subname 'Catalyst::Action::DBIC::Transaction::execute' => sub {
            if ($wantarray) {
                @return = $self->next::method($self,@_);
            } else {
                $return = $self->next::method($self,@_);
            }
        };

        $schema_class->txn_do($sub);

        if ($wantarray) {
            return @return;
        } else {
            return $return;
        }
    }

};
1;

=head1 NAME

Catalyst::Action::DBIC::Transaction - Encloses actions into transactions

=head1 SYNOPSIS

  use base qw(Catalyst::Controller::DBIC::Transaction);
  sub foo :DBICTransaction('DB::Schema') {
     do $something or die $!;
  }

=head1 DESCRIPTION

This module enables the use of automatic transaction support into
Catalyst Actions, it will associate a given action with the
appropriate action class and save the DBIx::Class::Schema class name
for later use.

The action will be executed inside a txn_do, and a die inside that
method will cause the transaction to be rolled back, as documented in
DBIx::Class::Schema.

This method will not, on the other hand, handle that exception, since
txn_do will rethrow it. This means that this handling is not much
intrusive in the action processing flow.

=head1 AUTHORS

Daniel Ruoso <daniel@ruoso.com>

=head1 BUG REPORTS

Please submit all bugs regarding C<Catalyst::Controller::DBIC::Transaction> to
C<bug-catalyst-controller-dbic-transaction@rt.cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
