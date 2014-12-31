
exports.up = (knex, Promise) ->
  knex.schema.table 'machines', (table) ->
    table.dropColumn('hasImage')
    table.string('image')


exports.down = (knex, Promise) ->
  knex.schema.table 'machines', (table) ->
    table.dropColumn('image')
    table.boolean('hasImage')
