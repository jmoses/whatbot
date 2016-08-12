package Whatbot::Command::Blackjack::Hand;
use Moose;
use namespace::autoclean;

has 'player'    => ( is => 'rw', isa => 'Str' );
has 'cards'     => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );
has 'last_draw' => ( is => 'rw', isa => 'Int', default => 0 );

sub clone {
    my ( $self ) = @_;
    
    return Whatbot::Command::Blackjack::Hand->new(
        'player' => $self->player
    );
}

sub fingerprint {
    my ( $self ) = @_;
    
    return join( '',
        $self->player,
        $self->first->value,
        $self->first->suit,
        $self->second->value,
        $self->second->suit
    );
}

sub ircize {
    my ( $self ) = @_;
    
    my $output = $self->player . ': ';
    foreach my $card ( @{ $self->cards } ) {
        $output .= $card->ircize . '  ';
    }
    $output .= '(' . $self->score . ').';
    
    return $output;
}

sub first {
    my ( $self ) = @_;
    
    return $self->cards->[0];
}

sub second {
    my ( $self ) = @_;
    
    return $self->cards->[1];
}

sub give {
    my ( $self, $card ) = @_;
    
    push( @{ $self->cards }, $card );
}

sub busted {
    my ( $self ) = @_;
    
    return ( $self->score > 21 ? 1 : 0 );
    return;
}

sub blackjack {
    my ( $self ) = @_;
    
    return 1 if ( $self->score == 21 and $self->card_count == 2 );
    return;
}

sub card_count {
    my ( $self ) = @_;
    
    return scalar( @{ $self->cards } );
}

sub has_ace {
    my ( $self ) = @_;
    
    foreach my $card ( @{ $self->cards } ) {
        return 1 if ( $card->value eq 'A' );
    }
    return;
}

sub can_double {
    my ( $self ) = @_;
    
    return ( $self->card_count == 2 and $self->score > 8 and $self->score < 12 ? 1 : 0 );
}

sub can_split {
    my ( $self ) = @_;
    
    return ( $self->card_count == 2 and $self->first->value eq $self->second->value ? 1 : 0 );
}

sub score {
    my ( $self ) = @_;
    
    my $score = 0;
    my @aces;
    foreach my $card ( @{ $self->cards } ) {
        if ( $card->value =~ /[KQJ]/ ) {
            $score += 10;
        } elsif ( $card->value eq 'A' ) {
            push( @aces, $card );
        } else {
            $score += $card->value
        }
    }
    foreach my $ace ( @aces ) {
        $score += 1;
    }
    foreach my $ace ( @aces ) {
        if ( $score + 10 <= 21 ) {
            $score += 10;
        }
    }
    
    return $score;
}

__PACKAGE__->meta->make_immutable;

1;