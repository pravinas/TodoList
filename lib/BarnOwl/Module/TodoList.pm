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

sub is_yes {
    my $stringy = shift;
    return (index($stringy, "y") > -1 or index($stringy, "Y") > -1);
}

sub format_line {
    my $task = shift;
    my $due  = shift;
    my $done = shift;
    my $is_done = is_yes($done);
    my $line = "";
    $line .= colorize("$task [$due] ", $is_done);
    $line .= ($is_done) ? "DONE!" : "";
    $line .= "\n";
    return $line;
}

sub colorize {
    my $text = shift;
    my $is_done = shift;
    
    unless ($is_done) {return $text}
    else {return '@<@color(blue)'."$text>";}
}

sub cmd_todolist{
    my $cmd = shift;
    my $args = join(" ", @_);
    BarnOwl::start_question("Task: ", sub {got_task($args,"[Zephyr TODO Dashboard]\n", @_)});
}

sub got_task {
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
    my ($args, $prevmsg, $task, $due, $done, $finished) = @_;
    my $message .= format_line($task, $due, $done);

    if(is_yes($finished)){
        # Terminate and write output
        BarnOwl::zephyr_zwrite($args, $message);
    }else{
        # Keep asking about things
        BarnOwl::start_question("Task: ", sub{got_task($args, $message, @_)});
    }
}

BarnOwl::new_command(todolist => \&cmd_todolist, {
    summary => "A simple todolist application for Zephyr",
    usage   => "todolist [zephyr command-line]",
    description => "Generates a TODO list based on your responses to questions.\n" .
    "You will be asked for a task, when it's due, and whether it is done.\n\n" .
    "Use with a zephyr command line, e.g. :zstatus -c pravinas -i todo"
   });

1;
