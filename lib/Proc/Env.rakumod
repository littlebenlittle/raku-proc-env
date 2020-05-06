
unit package Proc::Env:auth<littlebenlittle>:ver<0.0.0>;

use Mkdir::Recursive;

class Env {
    has $.kv;
    has $.directory-template;
    has $.timeout;

    method run(*@cmd) {
        PRE  my $dir = create-directory($.directory-template);
        POST rmdir $dir;
        my $proc = Proc::Async.new: @cmd;
        my $stdout = '';
        my $stderr = '';
        my $exitcode;
        react {
            whenever $proc.stdout { $stdout ~= $_ }
            whenever $proc.stderr { $stderr ~= $_ }
            whenever $proc.start( :ENV($.kv), :cwd($dir) ) { $exitcode = .exitcode; done }
            whenever Promise.in($.timeout) { $proc.kill: SIGKILL }
        }
        return class {
            has Str $.stdout   = $stdout;
            has Str $.stderr   = $stderr;
            has Int $.exitcode = $exitcode;
        }.new
    }
}

our sub new(:$kv = {}, :$directory-template = (), :$timeout = 1) {
    my $env = Env.new(
        kv => $kv,
        directory-template => $directory-template,
        timeout => $timeout,
    );
    return $env;
}

sub create-directory($structure -->IO) {
    my $uuid = now.Int;
    my $dir  = "$*TMPDIR/$uuid".IO;
    Mkdir::Recursive::populate $dir, $structure;
    return $dir;
}

