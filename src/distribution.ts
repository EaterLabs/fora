import {EventMessage, SubscribedMessage, SubscribeMessage} from './message';

type MessageHandler<T> = (message: T) => void;

class Subscription {
    id: string;
    topic: string | string[];
    match?: object;
    select?: object;

    handle: MessageHandler<EventMessage>;
}

class Distribution {
    subscriptions: [];

    subscribe(message: SubscribeMessage, handler: MessageHandler<EventMessage>): SubscribedMessage {



    }
}