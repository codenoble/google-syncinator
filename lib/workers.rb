module Workers
  require './lib/workers/change_error'
  require './lib/workers/change_finish'
  require './lib/workers/create_trogdir_email'
  require './lib/workers/handle_change'
  require './lib/workers/handle_changes'
  require './lib/workers/insert_into_legacy_email_table'
  require './lib/workers/update_legacy_email_table'
end
