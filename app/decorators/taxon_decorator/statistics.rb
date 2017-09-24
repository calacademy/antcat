class TaxonDecorator::Statistics
  include ActionView::Helpers
  include ActionView::Context
  include Service
  include ApplicationHelper # For `#pluralize_with_delimiters` and `#number_with_delimiter`.

  # TODO: Push include_invalid/include_fossil to the taxa models.
  # This method is cheap, but Taxon#statistics is very slow and it always
  # fetches all statistics and then this method removes invalid/fossil taxa.
  def initialize statistics, include_invalid: true, include_fossil: true
    @statistics = statistics
    @include_invalid = include_invalid
    @include_fossil = include_fossil
  end

  def call
    return '' unless @statistics.present?

    strings = [:extant, :fossil].reduce({}) do |strings, extant_or_fossil|
      extant_or_fossil_stats = @statistics[extant_or_fossil]

      if extant_or_fossil_stats
        string = [:subfamilies, :tribes, :genera, :species, :subspecies].reduce([]) do |rank_strings, rank|
          rank_strings << rank_statistics(extant_or_fossil_stats[rank], rank)
        end.compact.join(', ')
        strings[extant_or_fossil] = string
      end

      strings
    end

    strings = if strings[:extant] && strings[:fossil] && include_fossil
                strings[:extant].insert 0, 'Extant: '
                strings[:fossil].insert 0, 'Fossil: '
                [strings[:extant], strings[:fossil]]
              elsif strings[:extant]
                [strings[:extant]]
              elsif include_fossil
                ['Fossil: ' + strings[:fossil]]
              else
                []
              end

    strings.map do |string|
      content_tag :p, string
    end.join.html_safe
  end

  private
    attr_reader :include_invalid, :include_fossil

    def rank_statistics rank_stats, rank
      return unless rank_stats

      valid_string = valid_statistics rank_stats.delete('valid'), rank
      return valid_string unless include_invalid

      invalid_string = invalid_statistics rank_stats
      if invalid_string && valid_string.blank?
        valid_string = "0 valid #{rank}"
      end

      [valid_string, invalid_string].compact.join ' '
    end

    def valid_statistics valid_rank_stats, rank
      return unless valid_rank_stats
      rank_status_count(rank, 'valid', valid_rank_stats, include_invalid)
    end

    def invalid_statistics rank_stats
      sorted_keys = rank_stats.keys.sort_by do |key|
        Status.ordered_statuses.index key
      end

      status_strings = sorted_keys.map do |status|
        rank_status_count(:genera, status, rank_stats[status])
      end

      if status_strings.present?
        "(#{status_strings.join(', ')})"
      else
        nil
      end
    end

    def rank_status_count rank, status, count, label_statuses = true
      count_and_status =
        if label_statuses
          pluralize_with_delimiters count, status, Status[status].to_s(:plural)
        else
          number_with_delimiter count
        end

      if status == 'valid'
        # We must first singularize because rank may already be pluralized.
        count_and_status << " #{rank.to_s.singularize.pluralize(count)}"
      end
      count_and_status
    end
end
