use v6.c;
use Test;
use lib 'lib';
use EaterLabs::Fora;
use EaterLabs::Fora::Message;

my $supplier-out = Supplier.new;
my $supplier-in = Supplier.new;

my \dist = Router.new;

dd dist;

plan 2;

my $supply-in = $supplier-in.Supply;
my $supply-out = $supplier-out.Supply.Channel;
my $id = dist.add-stream($supply-in, $supplier-out);
$supplier-in.emit: SubscribeMessage.new(tid => "1", topic => "icemen");
my $reply = $supply-out.poll;
ok $reply ~~ SubscribedMessage, "Should have received subscribed message reply";
ok $reply.tid == "1", "Thread Id should be 1";

$id = $supplier-in.emit: EventMessage.new(tid => "2", topic => "icemen", body => "😌");
