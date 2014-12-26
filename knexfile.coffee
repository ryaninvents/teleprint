# Update with your config settings.

module.exports =
  development:
    client: 'sqlite3'
    connection:
      filename: './.machines/machines.sqlite'
    migrations:
      tableName: 'knex_migrations'
