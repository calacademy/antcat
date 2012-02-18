# coding: UTF-8

class ReleaseType 
  def title; 'AntCat' end
  def user_can_edit?(user) user || preview? end
  def user_can_not_edit?(user); !user_can_edit user end
  def method_missing(*) end
end

class ProductionReleaseType < ReleaseType
  def production?; true end
end

class PreviewReleaseType < ReleaseType
  def title; 'Preview of AntCat' end
  def preview?; true end
  def user_can_edit?(_); true end
end

$ReleaseType = PreviewReleaseType.new

