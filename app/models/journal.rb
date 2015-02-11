# coding: UTF-8
class Journal < ActiveRecord::Base
  validates_presence_of :name
  scope :list, -> { order(:name) }
  has_paper_trail

  attr_accessible :name

  def self.import name
    return unless name.present?
    journal = Journal.where('name = ?', name).first_or_create! do |new_journal|
      new_journal.name = name
    end

    raise unless journal.valid?
    journal
  end

  def self.search term = ''
    search_expression = term.split('').join('%') + '%'
    select('journals.name, COUNT(*)').
        joins('LEFT OUTER JOIN `references` ON references.journal_id = journals.id').
        where('journals.name LIKE ?', search_expression).
        group('journals.id').
        order('COUNT(*) DESC').
        map(&:name)
  end

end
