unit module EaterLabs::Fora;

use UUID;
use EaterLabs::Fora::Message;

class Subscription {
  has $.topic;
  has $.id = UUID.new;

}

class Router { ... }

class Stream {
  has Hash $!subscriptions .= new;
  has Supply $.in;
  has Tap $!in-tap;
  has Supplier $.out;
  has Router $.router;
  has $.id = UUID.new;
  has $.live is rw = False;

  method subscribe($topic) {

  }

  method tap {
    return if $.live;

    $.live = True;
    $!in-tap = $.in.tap(-> $val {
      $.router.process-message(self, $val);
    }, exit => { $.close }, done => { $.close })
  }

  method close {
    return if !$.live;

    $.live = False;
    $.out.done;
    $!in-tap.close;

    $.router.remove-stream($.id);
    $.router.unsubscribe($_.topic, $.id) for $!subscriptions.elems;
  }

  method emit(Message $message) {
    $.out.emit: $message;
  }
}

class Router is export {
  has Hash $!streams .= new;
  has Hash $!topics .= new;

  method add-stream($in, $out) {
    my $stream = Stream.new(:$in, :$out, :router(self));
    $!streams{~$stream.id} = $stream;
    $stream.tap;
    return $stream.id;
  }

  method remove-stream($id) {
    $!streams{~$id}:delete;
  }

  method process-message(Stream $sender, Message $message) {
    given $message {
      when EventMessage {

      }

      when SubscribeMessage {
        my $id = $sender.subscribe($message);
        $sender.emit(SubscribedMessage.new(tid => $message.tid, id=>$id))
      }

      when SubscribeMessage {
        $sender.subscribe($message);
      }
    }
  }

  method subscribe(Str $topic, $id) {
    $!topics{$topic} //= SetHash.new;
    $!topics{$topic}{~$id} = True;
  }

  method unsubscribe(Str $topic, $id) {
    return if $!topics{$topic}:!exists;
    $!topics{$topic}{~$id} = False;
    $!topics{$topic}:delete if $!topics.elems == 0;
  }
}
