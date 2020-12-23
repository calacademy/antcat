# frozen_string_literal: true

module DatabaseScripts
  class ReferencesByNumberOfHistoryItems < DatabaseScript
    LIMIT = 100

    def statistics
    end

    def results
      Reference.joins(:history_items).
        group(:id).order("COUNT(history_items.id) DESC").limit(LIMIT).
        select("`references`.*, COUNT(history_items.id) AS history_item_count")
    end

    def render
      as_table do |t|
        t.header 'ID', 'Reference', 'History item count'
        t.rows do |reference|
          [
            reference.id,
            link_to(reference.key_with_suffixed_year, reference_path(reference)),
            reference.history_item_count
          ]
        end
      end
    end
  end
end

__END__

title: References by number of history items

section: list
category: References
tags: [new!]

description: >

related_scripts:
  - ReferencesByNumberOfHistoryItems
