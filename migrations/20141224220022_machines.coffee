
exports.up = (knex, Promise) ->
  knex.schema.createTable 'machines', (table) ->
    table.string 'uuid'
    table.string 'pnpId'
    table.string 'name'
    table.string 'type'
    table.boolean 'hasImage'
    table.json 'details'



exports.down = (knex, Promise) ->
  knex.schema.dropTable 'machines'
