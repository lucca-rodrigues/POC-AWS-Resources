import { Module } from '@nestjs/common';
import { LibEagleNestKafkaProducerModule } from '@grupo-eagle/lib-eagle-nest-kafka';
import { KafkaProducerService } from './kafka.producer';

// Mesmo formato de config do pld-ftp-api (src/kafka/modules/app.kafka.module.ts).
const kafkaOptions = {
  appName: 'futurosign-kafka',
  allowAutoTopicCreation: true,
  clientId: 'futurosign-kafka',
  groupId: 'futurosign-kafka',
  postfixId: '-server',
  rebalanceTimeout: 10000,
  sessionTimeout: 10000,
  brokers: (process.env.KAFKA_BROKERS ?? 'localhost:9092').split(','),
  nodeEnv: process.env.STAGE ?? 'dev',
};

@Module({
  imports: [LibEagleNestKafkaProducerModule.forRoot(kafkaOptions)],
  providers: [KafkaProducerService],
})
export class AppModule {}
