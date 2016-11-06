class ReferenceObserver < ActiveRecord::Observer
  def before_update reference
    reference.invalidate unless reference.new_record?
  end
end
