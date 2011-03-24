Rake.application.options.trace = true

$BOLTON_DATA_DIRECTORY = 'data/bolton/2011-01'

namespace :bolton do

  namespace :import do
    desc "Import HTML files of references from Bolton"
    task :references => :environment do
      Bolton::Reference.delete_all
      Bolton::Bibliography.new(true).import_files Dir.glob "#{$BOLTON_DATA_DIRECTORY}/NGC-REFS(*.htm"
    end
    desc "Import Bolton subfamily catalog"
    task :subfamilies => :environment do
      Bolton::SubfamilyCatalog.new(true).import_files Dir.glob "#{$BOLTON_DATA_DIRECTORY}/*.htm"
    end
    desc "Import Bolton genus catalog documents"
    task :genera => :environment do
      Bolton::GenusCatalog.new(true).import_files Dir.glob "#{$BOLTON_DATA_DIRECTORY}/NGC-GEN*.htm"
    end
    desc "Import Bolton species catalog documents"
    task :species => :environment do
      Bolton::SpeciesCatalog.new(true).import_files Dir.glob "#{$BOLTON_DATA_DIRECTORY}/NGC-Sp*.htm"
    end
    desc "Import all taxa"
    task :taxa => ['bolton:import:subfamilies', 'bolton:import:species']
  end

  namespace :match do
    desc 'Match Bolton references to ours'
    task :references => :environment do
      Bolton::ReferencesMatcher.new(true).find_matches_for_all
    end
  end

  namespace :import_and_match do
    desc 'Import and match Bolton references'
    task :references => ['bolton:import:references', 'bolton:match:references']
  end

end
