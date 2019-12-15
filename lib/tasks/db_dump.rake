namespace :db_dump do
  desc "Download and import latest db dump from EngineYard"
  task import_latest: [:environment]  do
    sh "RAILS_ENV=#{Rails.env} ./script/db_dump/import_latest"
  end
end
