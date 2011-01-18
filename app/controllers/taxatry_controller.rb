class TaxatryController < ApplicationController
  def index
    @subfamilies = Subfamily.all :order => :name
    set_selected_taxon 'subfamily'

    if @selected_subfamily
      @tribes = @selected_subfamily == 'all' ? Tribe.all(:order => :name) : @selected_subfamily.children
      set_selected_taxon 'tribe'
    end

    @genera = @selected_tribe.genera if @selected_tribe
  end

  def set_selected_taxon rank
    param = params[rank]
    instance_variable_set("@selected_#{rank}", param == 'all' ? 'all' : Taxon.find(param.to_i)) if param
  end
end

