# Multi-stage: compila o TypeScript e instala as libs (incl. lib interna do
# GitHub Packages via secret do BuildKit) no estagio build; o runtime so copia
# o JS compilado e as dependencias.

FROM public.ecr.aws/lambda/nodejs:22 AS build
WORKDIR /build

COPY package.json tsconfig.json ./
# Secret do BuildKit: ~/.npmrc do host (token do GitHub Packages).
RUN --mount=type=secret,id=npmrc,target=/root/.npmrc npm install

COPY src/ ./src/
RUN npx tsc

FROM public.ecr.aws/lambda/nodejs:22
COPY --from=build /build/dist ${LAMBDA_TASK_ROOT}/
COPY --from=build /build/node_modules ${LAMBDA_TASK_ROOT}/node_modules
CMD ["handler.handler"]
