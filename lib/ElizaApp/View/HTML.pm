package ElizaApp::View::HTML;
use Moose;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt2',
    INCLUDE_PATH => [
        ElizaApp->path_to( 'root', 'src' ),
    ],
    TIMER => 0,
    WRAPPER => 'wrapper.tt2',
    render_die => 1,
);

1;
