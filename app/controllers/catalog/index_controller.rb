# coding: UTF-8
class Catalog::IndexController < CatalogController

  def show
    super

    #@current_path = index_catalog_path

    @subfamilies = ::Subfamily.ordered_by_name

    if params[:id].blank?
      @taxon = Family.first
      @subfamily = params[:subfamily]
      @tribe = params[:tribe]
      if @subfamily == 'none'
        @genera = Genus.without_subfamily
        @genus = nil
      elsif @tribe == 'none'
        @subfamily = Taxon.find @subfamily
        @taxon = @subfamily
        @tribes = @subfamily.tribes
        @genera = @subfamily.genera.without_tribe
        @genus = nil
      else
        @tribe = nil
        @tribes = nil
        @genus = nil
        @genera = nil
      end
      @specieses = nil
      @species = nil

    else
      @taxon = Taxon.find params[:id]
      case @taxon

      when Subfamily
        @subfamily = @taxon
        @tribe = nil
        @tribes = @subfamily.tribes
        @genus = nil
        @genera = nil
        @species = nil
        @specieses = nil

      when Tribe
        @tribe = @taxon
        @subfamily = @tribe.subfamily
        @tribes = @tribe.siblings
        @genus = nil
        @genera = @tribe.genera
        @species = nil
        @specieses = nil

      when Genus
        @genus = @taxon
        @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
        @tribe = @genus.tribe ? @genus.tribe : 'none'
        @tribes = @genus.tribe ? @tribe.siblings : nil
        @genera = @genus.siblings
        @species = nil
        @specieses = @genus.species

      when Species
        @species = @taxon
        @genus = @species.genus
        @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
        @tribe = @genus.tribe ? @genus.tribe : 'none'
        @tribes = @genus.tribe ? @tribe.siblings : nil
        @genera = @genus.siblings
        @specieses = @species.siblings
      end

    end

    @column_selections = {
      subfamily: @subfamily, tribe: @tribe, genus: @genus, species: @species,
      q: params[:q], search_type: params[:search_type]
    }

    #case @taxon
    #when 'no_subfamily', Subfamily
      if @subfamily == 'none'
      #elsif params[:hide_tribes]
        #@genera = @selected_subfamily.genera
      #else
        #@tribes = @selected_subfamily.tribes
      end

    #when 'no_tribe', Tribe
      #@selected_tribe = @taxon
      #if params[:hide_tribes] && @selected_tribe == 'no_tribe'
        #@taxon = ::Subfamily.find params[:subfamily]
        #@selected_subfamily = @taxon
        #@genera = @selected_subfamily.genera
      #elsif params[:hide_tribes]
        #@taxon = @selected_tribe.subfamily
        #@selected_subfamily = @taxon
        #@genera = @selected_subfamily.genera
      #elsif @selected_tribe == 'no_tribe'
        #@selected_subfamily = ::Subfamily.find params[:subfamily]
        #@tribes = @selected_subfamily.tribes
        #@genera = @selected_subfamily.genera.without_tribe
      #else
        #@tribes = @selected_tribe.siblings
        #@genera = @selected_tribe.genera
        #@selected_subfamily = @selected_tribe.subfamily
      #end

    #when Species
      #@selected_species = @taxon
      #@selected_genus = @selected_species.genus
      #@species = @selected_species.siblings
      #select_subfamily_and_tribes
      #select_genera

    #when nil
    #end

    #@column_selections[:subfamily] = @selected_subfamily

  end

  #def select_subfamily_and_tribes
    #@selected_subfamily = @selected_genus.subfamily || 'no_subfamily'
    #unless params[:hide_tribes] || @selected_subfamily == 'no_subfamily'
      #@selected_tribe = @selected_genus.tribe || 'no_tribe'
      #@tribes = @selected_subfamily.tribes
    #end
  #end

  #def select_genera
    #if @selected_subfamily == 'no_subfamily'
      #@genera = Genus.without_subfamily
    #elsif params[:hide_tribes]
      #@genera = @selected_subfamily.genera
    #else
      #@genera = @selected_genus.siblings
    #end
  #end

end

