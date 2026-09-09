import { Inject, Injectable } from '@nestjs/common';
import { KAFKA_PRODUCER, KafkaProducerClient } from '@grupo-eagle/lib-eagle-nest-kafka';

@Injectable()
export class KafkaProducerService {
  constructor(
    @Inject(KAFKA_PRODUCER)
    private readonly kafkaClient: KafkaProducerClient,
  ) {}

  async publish(topic: string, key: string, value: unknown): Promise<void> {
    await this.kafkaClient.producer.send({
      topic,
      messages: [{ key, value: JSON.stringify(value) }],
    });
  }
}
