# coding: UTF-8
Before do
  Family.destroy_all
  FactoryGirl.create :family, protonym: nil
  $ReleaseType = ProductionReleaseType.new
end

Before('@preview') do
  $ReleaseType = PreviewReleaseType.new
end

After('@preview') do
  $ReleaseType = ProductionReleaseType.new
end

After {Sunspot.remove_all!}
