use v6;

use lib $?FILE.IO.dirname.IO.add('../lib');
use Proc::Env;
use Test;

plan 3;

subtest "run a command" => {
    plan 3;
    my $env  = Proc::Env::new;
    my $proc = $env.run: « $*EXECUTABLE -e 'say "hi wo"' »;
    is $proc.exitcode , 0         , "process exits with exitcode 0";
    is $proc.stdout   , "hi wo\n" , "process stdout says 'hi wo'";
    is $proc.stderr   , ''        , "nothing emitted to stderr";
};

subtest "run a command with an env var" => {
    plan 3;
    my $env  = Proc::Env::new :kv( NAME => 'wo' );
    my $proc = $env.run: « $*EXECUTABLE -e 'say "hi %*ENV<NAME>"' »;
    is $proc.exitcode , 0         , "process exits with exitcode 0";
    is $proc.stdout   , "hi wo\n" , "process stdout says 'hi wo'";
    is $proc.stderr   , ''        , "nothing emitted to stderr";
};

subtest "make sure we're in the tmp directory" => {
    plan 5;
    my $env  = Proc::Env::new;
    my $proc = $env.run: « $*EXECUTABLE -e 'say $*CWD.Str' »;
    is   $proc.exitcode , 0                 , "process exits with exitcode 0";
    is   $proc.stderr   , ''                , "nothing emitted to stderr";
    isnt $proc.stdout   , $*TMPDIR          , "we are not in the root of the tmp dir";
    like $proc.stdout   , / "$*TMPDIR" .* / , "we are in a descendent of the tmp dir";
    nok  $proc.stdout.IO.e                  , "the directory is cleaned up after env proc exits";
};

done-testing();

