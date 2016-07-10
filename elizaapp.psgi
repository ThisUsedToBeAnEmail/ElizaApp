use strict;
use warnings;

use ElizaApp;

my $app = ElizaApp->apply_default_middlewares(ElizaApp->psgi_app);
$app;

