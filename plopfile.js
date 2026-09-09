// Plopfile: gera novas functions Lambda em functions/<nome>/
// seguindo o padrao da POC (estrutura do crud-node).
// Uso: npm run gen

module.exports = (plop) => {
  plop.setHelper('eq', (a, b) => a === b);

  plop.setGenerator('function', {
    description: 'Cria uma nova function Lambda',
    prompts: [
      {
        type: 'input',
        name: 'name',
        message: 'Nome da function (kebab-case, ex.: minha-rota):',
        validate: (value) =>
          /^[a-z0-9]+(-[a-z0-9]+)*$/.test(value) ||
          'Use kebab-case (letras minusculas e hifens).',
      },
      {
        type: 'list',
        name: 'type',
        message: 'Tipo da function:',
        choices: [
          { name: 'http — rota de API (responde HTTP)', value: 'http' },
          { name: 'integracao — chama API de terceiros (fetch)', value: 'integracao' },
          { name: 'crud — banco com TypeORM (padrao crud-node)', value: 'crud' },
        ],
      },
      { type: 'input', name: 'description', message: 'Descricao:' },
    ],
    actions: (data) => {
      const actions = [
        {
          type: 'add',
          path: 'functions/{{name}}/Dockerfile',
          templateFile: 'infra/templates/function/Dockerfile.hbs',
        },
        {
          type: 'add',
          path: 'functions/{{name}}/package.json',
          templateFile: 'infra/templates/function/package.json.hbs',
        },
        {
          type: 'add',
          path: 'functions/{{name}}/src/handler.js',
          templateFile: 'infra/templates/function/handler.hbs',
        },
        {
          type: 'add',
          path: 'functions/{{name}}/README.md',
          templateFile: 'infra/templates/function/README.md.hbs',
        },
      ];

      if (data.type === 'crud') {
        actions.push({
          type: 'add',
          path: 'functions/{{name}}/src/entity.js',
          templateFile: 'infra/templates/function/entity.hbs',
        });
      }

      // Insere o bloco terraform no main.tf (antes do marcador de functions geradas).
      actions.push({
        type: 'modify',
        path: 'terraform/environments/dev-local/main.tf',
        pattern: /# --- Functions geradas \(npm run gen\) ---/,
        template: `\n{{> terraformBlock}}\n# --- Functions geradas (npm run gen) ---`,
      });

      // Insere o output no outputs.tf (antes do marcador de outputs gerados).
      actions.push({
        type: 'modify',
        path: 'terraform/environments/dev-local/outputs.tf',
        pattern: /# --- Outputs gerados \(npm run gen\) ---/,
        template: `output "api_gateway_{{name}}_invoke_url" {
  description = "URL de invocacao da function {{name}} no floci (localhost:4566)."
  value       = "http://localhost:4566/restapis/\${module.api_gateway_{{name}}.rest_api_id}/\${module.api_gateway_{{name}}.stage_name}/_user_request_"
}

# --- Outputs gerados (npm run gen) ---`,
      });

      return actions;
    },
  });

  // Partial reutilizado para o bloco terraform (sem comentarios inuteis).
  plop.setPartial('terraformBlock', `module "ecr_{{name}}" {
  source = "../../modules/ecr"

  repository_name = "futurosign-{{name}}"
}

module "lambda_{{name}}" {
  source = "../../modules/lambda"

  function_name = "futurosign-{{name}}"
  image_uri     = "localhost:4566/futurosign-{{name}}:latest"

  environment_variables = {
    STAGE = var.stage
{{#if (eq type 'crud')}}
    SECRET_NAME = module.app_secret.name
{{/if}}
  }
{{#if (eq type 'crud')}}
  secret_arns = [module.app_secret.arn]
{{/if}}
}

module "api_gateway_{{name}}" {
  source = "../../modules/api-gateway"

  api_name             = "futurosign-{{name}}-api"
  stage_name           = var.api_gateway_stage
  lambda_invoke_arn    = module.lambda_{{name}}.invoke_arn
  lambda_function_name = module.lambda_{{name}}.function_name
}`);
};
