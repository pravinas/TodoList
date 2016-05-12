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

sub cmd_todolist{
    my $cmd = shift;
    my $args = join(" ", @_);
    BarnOwl::start_question("Task: ", sub {got_task($args,"[Zephyr TODO Dashboard]\n", @_)});
}

sub got_task {
    #my ($args,$prevmsg,$task) = @_;
    my @pass = @_;
    BarnOwl::start_question("Due: ", sub {got_due(@pass, @_)});
}

sub got_due {
    my @pass = @_;
    BarnOwl::start_question("Done? (y/n): ", sub{got_done(@pass, @_)});
}

sub got_done {
    my @pass = @_;
    BarnOwl::start_question("Was that the last item on your TODO List? (y/n): ", sub{got_finished(@pass, @_)});
}

sub got_finished{
    # TODO
}

BarnOwl::new_command(todolist => \&cmd_todolist, {
    summary => "A simple todolist application for Zephyr",
    usage   => "todolist [zephyr command-line]",
    description => "Generates a TODO list based on your responses to questions.\n" .
    "You will be asked for a task, when it's due, and whether it is done.\n\n" .
    "Use with a zephyr command line, e.g. :zstatus -c pravinas -i todo"
   });

1;
