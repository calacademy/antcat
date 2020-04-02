# frozen_string_literal: true

class DatabaseScriptDecorator < Draper::Decorator
  GITHUB_MASTER_URL = "https://github.com/calacademy-research/antcat/blob/master"

  delegate :tags, :filename_without_extension

  def self.format_tags tags
    tags.map do |tag|
      h.content_tag :span, class: tag_css_class(tag) do
        h.raw tag.html_safe
      end
    end.join(" ").html_safe
  end

  def format_tags
    self.class.format_tags tags
  end

  def github_url
    "#{GITHUB_MASTER_URL}/#{DatabaseScript::SCRIPTS_DIR}/#{filename_without_extension}.rb"
  end

  def empty_status
    return '??' unless database_script.respond_to?(:results)
    return 'Excluded (slow/list)' if database_script.tags.include?('list') || database_script.slow?

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
end
