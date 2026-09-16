# Imagem base oficial da AWS para Node.js 22 — já inclui o Runtime Interface
# Emulator (RIE) e o entrypoint correto para Lambda container image.
FROM public.ecr.aws/lambda/nodejs:22

COPY package.json ./
RUN npm install --omit=dev

COPY src/ ${LAMBDA_TASK_ROOT}/

CMD ["handler.handler"]
