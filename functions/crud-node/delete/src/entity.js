'use strict';

// Entidade do CRUD (TypeORM EntitySchema — sem decorators, JS puro).
// Equivalente ao DbContext/Entity do EF Core nos repos .NET.

const { EntitySchema } = require('typeorm');

module.exports = {
  Item: new EntitySchema({
    name: 'Item',
    tableName: 'crud_itens',
    columns: {
      id: { type: 'uuid', primary: true, generated: 'uuid' },
      nome: { type: 'varchar', length: 255 },
      criado_em: { type: 'timestamptz', createDate: true },
      atualizado_em: { type: 'timestamptz', updateDate: true },
    },
  }),
};
