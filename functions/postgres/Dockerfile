# Imagem base oficial da AWS para Node.js 22 — já inclui o Runtime Interface
# Emulator (RIE) e o entrypoint correto para Lambda container image.
FROM public.ecr.aws/lambda/nodejs:22

# Instala as dependencias antes de copiar o codigo.
COPY package.json ./
RUN npm install --omit=dev

# Copia o handler para o diretorio de runtime da Lambda.
COPY src/handler.js ${LAMBDA_TASK_ROOT}/

# Aponta o runtime para o handler exportado.
CMD ["handler.handler"]
