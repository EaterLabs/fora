use v6.c;
use JSON::Fast;

role Serializable {
    method serialize {
      my Hash $obj .= new;

      for self.^attributes -> $attr {
        my $attr-name = $attr.name.substr(2);

        if $attr.has_accessor {
          $obj{$attr-name} //= $attr.get_value(self);

          if $obj{$attr-name} ~~ Serializable {
            $obj{$attr-name} = $obj{$attr-name}.serialize;
          }
        }
      }

      return $obj;
    }
}

role Deserializable {
  method deserialize(Hash $obj) {
    my Hash $creation .= new;
    for self.^attributes -> $attr {
      my $attr-name = $attr.name.substr(2);

      if $attr.has_accessor and !$attr.readonly and $creation{$attr-name}:!exists and $obj{$attr-name}:exists {
        if $attr.type ~~ Deserializable {
          $creation{$attr-name} = $attr.type.deserialize($obj{$attr-name});
        } else {
          $creation{$attr-name} = $obj{$attr-name};
        }
      }
    }

    self.new(|$creation)
  }
}

role Serde does Deserializable does Serializable {}

class Message does Serde {
  has Str $.type = "none";
  has Str $.tid;

  method to-json() returns Str {
    to-json self.serialize;
  }

  method from-json(Str \json) {
    self.deserialize(from-json json)
  }
}

class SubscribeMessage is Message {
  has Str $.type = "subscribe";
  has Str $.topic is rw;
}

class SubscribedMessage is Message {
  has Str $.type = "subscribed";
  has Str $.topic is rw;
}

class UnsubscribeMessage is Message {
  has Str $.type = "unsubscribe";
  has Str $.id is rw;
}

class EventMessage is Message {
  has Str $.type = "event";
  has Str $.topic is rw;
  has Str $.event-id is rw = UUID.new;
  has Hash $.body is rw;
}
