package ElizaApp::Controller::Bot;
use Moose;
use namespace::autoclean;
use Chatbot::Eliza;
use LWP::UserAgent;
use HTTP::Request;
use JSON;

BEGIN { extends 'ElizaApp::Controller' }
use feature qw/say/;
#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

ElizaApp::Controller::Eliza

=head1 DESCRIPTION

=head1 METHODS

Attempt to render a view, if needed.

=cut

sub base :Chained('/') :PathPart('bot') :CaptureArgs(0) {
    my ($self, $c) = @_;
    # used when setting up the fb bot.
    my $params = $c->req->params;
    if ($params->{'hub.verify_token'} && $params->{'hub.verify_token'} =~ m{'this_seems_like_fun'}xms) {
        return $c->response->body($params->{'hub.challend'});
    }
}

sub eliza :Chained('base') :PathPart('eliza') :Args(0) {
    my ($self, $c) = @_;

    my $body = $c->request->body_data;
    my $fb = $body->{entry}[0]->{messaging}[0];
    my $text = $fb->{message}->{text};

    my $eliza = Chatbot::Eliza->new();
    my $message = $eliza->instance($text);
    $self->send_fb_message({text => $message}, $fb);
}

# use what I know first - LWP::UserAgent
# then I'll look at switching to Catalyst::ActionRole::HTTPMethods - never used,
# I also saw POST mentioned in Catalyst::Controller but again currently I have not investigated.
sub send_fb_message {
    my ($self, $message, $fb) = @_;

    my $sender = $fb->{sender}->{id};
    my $fb_token = '';

    # ssl_opts stops fb crying
    my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 1 });
    my $post = 'https://graph.facebook.com/v2.6/me/messages?access_token=' . $fb_token;

    my $content = { recipient => { id => $sender }, message => $message };
    my $req = HTTP::Request->new(POST => $post);
    $req->header('content-type' => 'application/json');
    $req->content(to_json($content));

    my $resp = $ua->request($req);
    if ($resp->is_success) {
        my $success = $resp->decoded_content;
        say "Recieved replay: $success";
        return 1;
    }
    else {
        say "HTTP POST error code: $resp->code";
        say "HTTP POST error message $resp->message";
    }
}

=head1 AUTHOR

LNATION

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
