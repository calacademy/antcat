# frozen_string_literal: true

class DatabaseScriptDecorator < Draper::Decorator
  GITHUB_MASTER_URL = "https://github.com/calacademy-research/antcat/blob/master"

  delegate :section, :tags, :filename_without_extension

  def self.format_tags tags
    html_spans = tags.map { |tag| h.content_tag :span, tag, class: tag_css_class(tag) }
    h.safe_join(html_spans, " ")
  end

  def format_tags
    tags_and_sections = ([section] + tags).compact - [DatabaseScript::MAIN_SECTION]
    self.class.format_tags(tags_and_sections)
  end

  def github_url
    "#{GITHUB_MASTER_URL}/#{DatabaseScript::SCRIPTS_DIR}/#{filename_without_extension}.rb"
  end

  def empty_status
    return '??' unless database_script.respond_to?(:results)
    return 'Excluded (slow/list)' if list_or_slow?

    if database_script.results.any?
      'Not empty'
    else
      'Empty'
    end
  end

  private

    def self.tag_css_class tag
      case tag
      when DatabaseScript::SLOW_TAG          then "warning-label"
      when DatabaseScript::VERY_SLOW_TAG     then "warning-label"
      when DatabaseScript::SLOW_RENDER_TAG   then "warning-label"
      when DatabaseScript::NEW_TAG           then "label"
      when DatabaseScript::UPDATED           then "label"
      when DatabaseScript::HAS_QUICK_FIX_TAG then "green-label"
      when DatabaseScript::HIGH_PRIORITY_TAG then "high-priority-label"
      else                                        "white-label"
      end + " rounded-badge"
    end
    private_class_method :tag_css_class

    def list_or_slow?
      database_script.tags.include?('list') ||
        database_script.section == DatabaseScript::LIST_SECTION ||
        database_script.slow?
    end
end
