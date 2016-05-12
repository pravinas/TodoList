use warnings;
use strict;

=head1 NAME

BarnOwl::Module::TodoList

=head1 DESCRIPTION

I didn't write this.
Me neither, anonymous coder from the past.
Credits to nelhage for the ZStatus code, and pravinas for
modifying it to be a TODO List.

=cut

package BarnOwl::Module::TodoList;

our $VERSION = 0.1;


sub trim {
    my $s = shift;
    $s =~ s/^\s+//;
    $s =~ s/\s+$//;
    return $s;
}

sub got_data {
    my ($args, $data) = @_;
    my $message = "[Zephyr TODO Dashboard]\n";

    my @bars = split(/;/,$data);
    for(@bars) {
        next unless /=/;
        my ($tag,$val)  = split('=',$_,2);
        $tag = trim($tag);
        $val = trim($val);
        $message .= format_bar(sprintf('%15s',$tag), $val);
    }
    BarnOwl::zephyr_zwrite($args, $message);
}

sub got_sleep {
    my @pass = @_;
    BarnOwl::start_question('Angst [0-10]? ', sub {got_angst(@pass, @_)});
}

sub got_angst {
    my @pass = @_;
    BarnOwl::start_question('Stress [0-10]? ', sub {got_stress(@pass, @_)});
}

sub got_stress {
    my @pass = @_;
    BarnOwl::start_question('Hosage [0-10]? ', sub {got_hosage(@pass, @_)});
}

sub got_hosage {
    my ($args, $sleep, $angst, $stress, $hosage) = @_;
    my $message = "[Zephyr status dashboard]\n";
    $message .= format_bar("sleepdep ", $sleep);
    $message .= format_bar("angst    ", $angst);
    $message .= format_bar("stress   ", $stress);
    $message .= format_bar("hosage   ", $hosage);
    BarnOwl::zephyr_zwrite($args, $message);
}

sub format_bar {
    my $header = shift;
    my $num    = shift;
    my $bar = "";
    $bar .= "$header [";
    $bar .= colorize(("="x$num) . (" " x (10 - $num)), $num) . "]";
    $bar .= colorize(" ($num/10)", $num);
    $bar .= "\n";
    return $bar;
}

sub colorize {
    my $text = shift;
    my $num = shift;
    my $color;
    if($num <= 3) { $color = "green" }
    elsif($num <= 6) {$color = "yellow"}
    else {$color = "red";}

    return '@<@color(' . $color . ")$text>";
}

sub got_task {
    my ($args,$prevmsg,$data) = @_;
    
}

sub cmd_todolist{
    my $cmd = shift;
    my $args = join(" ", @_);
    BarnOwl::start_question("Task: ", sub {got_task($args,"", @_)});
}

BarnOwl::new_command(todolist => \&cmd_todolist, {
    summary => "A simple todolist application for Zephyr",
    usage   => "todolist [zephyr command-line]",
    description => "Generates a TODO list based on your responses to questions.\n" .
    "You will be asked for a task, when it's due, and whether it is done.\n\n" .
    "Use with a zephyr command line, e.g. :zstatus -c pravinas -i todo"
   });

1;
