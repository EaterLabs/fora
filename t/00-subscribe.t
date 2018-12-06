use v6.c;
use Test;
use lib 'lib';
use EaterLabs::Fora;
use EaterLabs::Fora::Message;

my $supplier-out = Supplier.new;
my $supplier-in = Supplier.new;

my \dist = Router.new;

dd dist;

plan 6;

my $supply-in = $supplier-in.Supply;
my $supply-out = $supplier-out.Supply.Channel;
my $id = dist.add-stream($supply-in, $supplier-out);
$supplier-in.emit: SubscribeMessage.new(tid => "1", topic => "icemen");
my $reply = $supply-out.poll;
ok $reply ~~ SubscribedMessage, "Should have received subscribed message reply";
ok $reply.tid eq "1", "Thread Id should be 1";

$id = $supplier-in.emit: EventMessage.new(tid => "2", topic => "icemen", body => "😌");
$reply = $supply-out.poll;
ok $reply ~~ EventMessage, "Should have received event message";
ok (not $reply.tid or $reply.tid ne "2"), "Thread Id shouldn't be 2";
$reply = $supply-out.poll;
ok $reply ~~ AckMessage, "Should have received ack message";
ok $reply.tid eq "2", "Thread Id should be 2";
