class Message {
    type: string;
}

class SubscriptionDefinition {
    topic: string[] | string;
    match?: object;
    select?: object;
}

export class SubscribeMessage extends Message {
    type = "subscribe";
    subscribe: SubscriptionDefinition[];
}

class SubscriptionDefinitionWithId extends SubscriptionDefinition {
    id: string;
}

export class SubscribedMessage extends Message {
    type = "subscribed";
    subscriptions: SubscriptionDefinitionWithId[];
}

export class UnsubscribeMessage extends Message {
    type = "unsubscribe";
    topic?: string | string[];
    ids?: string | string[];
}

export class UnsubscribedMessage extends Message {
    type = "unsubscribed";
    ids: string[];
}

export class PublishMessage extends Message {
    type = "publish";
    topic: string[] | string;
    body: object;
}

export class PublishedMessage extends Message {
    type = "published";
}

export class EventMessage extends Message {
    type = "event";
    id: string;
    topic: string;
    body: object;
}