import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { KafkaProducerService } from './kafka.producer';

const STAGE = process.env.STAGE ?? 'dev';
const KAFKA_TOPIC = process.env.KAFKA_TOPIC ?? 'futurosign.integracao.status.tpc';

// App NestJS reutilizado entre invocacoes (warm start).
let app: ReturnType<typeof NestFactory.createApplicationContext> | null = null;

async function getApp() {
  if (!app) {
    app = await NestFactory.createApplicationContext(AppModule);
  }
  return app;
}

exports.handler = async (event: { body?: string }) => {
  const body = JSON.parse(event.body ?? '{}');
  const { id, tipo } = body;

  const appContext = await getApp();
  const producer = appContext.get(KafkaProducerService);
  await producer.publish(KAFKA_TOPIC, id, { id, tipo, status: 'publicado', stage: STAGE });

  console.log(JSON.stringify({
    message: 'kafka.evento.publicado',
    data: { id, tipo, topico: KAFKA_TOPIC, stage: STAGE },
  }));

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ status: 'publicado', topico: KAFKA_TOPIC, id }),
  };
};
