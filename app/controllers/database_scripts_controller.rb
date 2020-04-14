# frozen_string_literal: true

# TODO: Implement pagination for lists inside scripts.

class DatabaseScriptsController < ApplicationController
  FLUSH_QUERY_CACHE_DEBUG = false
  SECTIONS_SORT_ORDER = [
    DatabaseScript::UNGROUPED_SECTION,
    DatabaseScript::MAIN_SECTION,
    DatabaseScript::REGRESSION_TEST_SECTION,
    DatabaseScript::LIST_SECTION
  ]

  before_action :authenticate_user!

  def index
    @grouped_database_scripts = DatabaseScript.all.group_by(&:section).
      sort_by { |section, _scripts| SECTIONS_SORT_ORDER.index(section) || 0 }
    @check_if_empty = params[:check_if_empty]
  end

  def show
    # :nocov:
    if FLUSH_QUERY_CACHE_DEBUG && Rails.env.development?
      ActiveRecord::Base.connection.execute('FLUSH QUERY CACHE;')
    end
    # :nocov:

    @database_script = find_database_script
    @rendered, @render_duration = timed_render
  end

  private

    def find_database_script
      DatabaseScript.new_from_filename_without_extension params[:id]
    rescue DatabaseScript::ScriptNotFound
      raise ActionController::RoutingError, "Not Found"
    end

    def timed_render
      start = Time.current
      rendered = @database_script.render
      render_duration = Time.current - start

      [rendered, render_duration]
    end
end
