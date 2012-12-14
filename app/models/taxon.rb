# coding: UTF-8
class Taxon < ActiveRecord::Base

  set_table_name :taxa

  before_save :set_name_caches

  def set_name_caches
    self.name_cache = name.name
    self.name_html_cache = name.name_html
  end

  ###############################################
  # name
  belongs_to :name; validates :name, presence: true
  scope :with_names, joins(:name).readonly(false)
  scope :ordered_by_name, with_names.order('names.name').includes(:name)

  def self.find_by_name name
    taxon = with_names.where(['name = ?', name]).first
    taxon && Taxon.find_by_id(taxon.id)
  end

  def self.find_all_by_name name
    with_names.where ['name = ?', name]
  end

  def self.find_by_epithet epithet
    joins(:name).readonly(false).where ['epithet = ?', epithet]
  end

  def self.find_epithet_in_genus target_epithet, genus
    for epithet in Name.make_epithet_set target_epithet
      results = with_names.where(['genus_id = ? AND epithet = ?', genus.id, epithet])
      return results unless results.empty?
    end
    nil
  end

  def self.find_name name, search_type = 'matching'
    name = name.dup.strip
    query = ordered_by_name
    column = name.split(' ').size > 1 ?  'name' : 'epithet'
    types_sought = ['Subfamily', 'Tribe', 'Genus', 'Subgenus', 'Species', 'Subspecies']
    case search_type
    when 'matching'
      query = query.where ["names.#{column} = ?    AND taxa.type IN (?)", name, types_sought]
    when 'beginning with'
      query = query.where ["names.#{column} LIKE ? AND taxa.type IN (?)", name + '%', types_sought]
    when 'containing'
      query = query.where ["names.#{column} LIKE ? AND taxa.type IN (?)", '%' + name + '%', types_sought]
    end
    query.all
  end

  def self.names_and_authorships letters_in_name
    search_term = letters_in_name.split('').join('%') + '%'
    query = Taxon.select('taxa.id AS taxon_id, name_cache, name_html_cache, principal_author_last_name_cache, year').
      joins(:protonym).
      joins('JOIN citations ON protonyms.authorship_id = citations.id').
      joins('JOIN `references` ON `references`.id = citations.reference_id').
      where("name_cache LIKE '#{search_term}' AND name_html_cache IS NOT NULL AND principal_author_last_name_cache IS NOT NULL AND year IS NOT NULL")
    query.map do |e|
      result = {}
      result[:label] = "<b>#{e.name_html_cache}</b> <span class=authorship>#{e.principal_author_last_name_cache}, #{e.year}</span>"
      result[:value] = "#{e.name_cache}"
      result
    end.sort_by do |a|
      a[:value]
    end
  end

  ###############################################
  # synonym
  def synonym?; status == 'synonym' end
  def synonym_of? taxon; senior_synonyms.include? taxon end
  has_many :synonyms_as_junior, foreign_key: :junior_synonym_id, class_name: 'Synonym'
  has_many :synonyms_as_senior, foreign_key: :senior_synonym_id, class_name: 'Synonym'
  has_many :junior_synonyms, through: :synonyms_as_senior
  has_many :senior_synonyms, through: :synonyms_as_junior

  def become_junior_synonym_of senior
    Synonym.where(junior_synonym_id: senior, senior_synonym_id: self).destroy_all
    Synonym.where(senior_synonym_id: senior, junior_synonym_id: self).destroy_all
    Synonym.create! junior_synonym: self, senior_synonym: senior
    senior.update_attribute :status, 'valid'
    update_attribute :status, 'synonym'
  end

  def become_not_a_junior_synonym_of senior
    Synonym.where('junior_synonym_id = ? AND senior_synonym_id = ?', id, senior).destroy_all
    update_attribute :status, 'valid' if senior_synonyms.empty?
  end

  ###############################################
  # homonym
  belongs_to  :homonym_replaced_by, class_name: 'Taxon'
  has_one     :homonym_replaced, class_name: 'Taxon', foreign_key: :homonym_replaced_by_id
  def homonym?; status == 'homonym' end
  def homonym_replaced_by? taxon; homonym_replaced_by == taxon end

  ###############################################
  # other associations
  belongs_to  :protonym, dependent: :destroy
  belongs_to  :type_name, class_name: 'Name', foreign_key: :type_name_id
  has_many    :history_items, class_name: 'TaxonHistoryItem', order: :position, dependent: :destroy
  has_many    :reference_sections, order: :position, dependent: :destroy

  ###############################################
  # statuses, fossil
  scope :valid,               where(status: 'valid')
  scope :extant,              where(fossil: false)
  def unavailable?;           status == 'unavailable' end
  def available?;             !unavailable? end
  def invalid?;               status != 'valid' end
  def unidentifiable?;        status == 'unidentifiable' end
  def ichnotaxon?;            status == 'ichnotaxon' end
  def unresolved_homonym?;    status == 'unresolved homonym' end
  def excluded?;              status == 'excluded' end
  def incertae_sedis_in?      rank; incertae_sedis_in == rank end
  def collective_group_name?; status == 'collective group name' end

  ###############################################
  def rank
    Rank[self].to_s
  end

  def children
    raise NotImplementedError
  end

  #def inspect
    #string = "#{name} (#{status} #{type.downcase} #{id})"
    #string << " incertae sedis in #{incertae_sedis_in}" if incertae_sedis_in.present?
    #string
  #end

  ###############################################
  # statistics

  def get_statistics ranks
    statistics = {}
    ranks.each do |rank|
      count = send(rank).count :group => [:fossil, :status]
      self.class.massage_count count, rank, statistics
    end
    statistics
  end

  def self.massage_count count, rank, statistics
    count.keys.each do |fossil, status|
      value = count[[fossil, status]]
      extant_or_fossil = fossil ? :fossil : :extant
      statistics[extant_or_fossil] ||= {}
      statistics[extant_or_fossil][rank] ||= {}
      statistics[extant_or_fossil][rank][status] = value
    end
  end

  def child_list_query children_selector, conditions = {}
    children = send children_selector
    children = children.where fossil: !!conditions[:fossil] if conditions.key? :fossil
    incertae_sedis_in = conditions[:incertae_sedis_in]
    children = children.where incertae_sedis_in: incertae_sedis_in if incertae_sedis_in
    children = children.where hong: !!conditions[:hong] if conditions.key? :hong
    children = children.where "status = 'valid' OR status = 'unresolved homonym'"
    children = children.ordered_by_name
    children
  end

  ###############################################
  # import

  def import_synonyms senior
    Synonym.create! junior_synonym: self, senior_synonym: senior if senior
  end

  def self.get_type_attributes key, data
    attributes = {}
    if data[key]
      attributes[:type_name] = Name.import data[key]
      attributes[:type_fossil] = data[key][:fossil]
      attributes[:type_taxt] = Importers::Bolton::Catalog::TextToTaxt.convert data[key][:texts]
    end
    attributes
  end

end
