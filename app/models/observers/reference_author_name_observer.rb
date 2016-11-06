class ReferenceAuthorNameObserver < ActiveRecord::Observer
  def before_save reference_author_name
    reference_author_name.reference.invalidate_cache
  end

  def before_destroy reference_author_name
    reference_author_name.reference.invalidate_cache
  end
end
