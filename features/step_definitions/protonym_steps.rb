# frozen_string_literal: true

Given("there is a subfamily protonym {string}") do |name_string|
  there_is_a_subfamily_protonym name_string
end
def there_is_a_subfamily_protonym name_string
  name = create :subfamily_name, name: name_string
  create :protonym, :family_group, name: name
end

Given("there is a genus protonym {string}") do |name_string|
  there_is_a_genus_protonym name_string
end
def there_is_a_genus_protonym name_string
  name = create :genus_name, name: name_string
  create :protonym, :genus_group, name: name
end

Given("there is a species protonym {string} with pages and form 'page 9, dealate queen'") do |name_string|
  there_is_a_species_protonym_with_pages_and_form_page_9_dealate_queen name_string
end
def there_is_a_species_protonym_with_pages_and_form_page_9_dealate_queen name_string
  name = create :species_name, name: name_string
  citation = create :citation, pages: 'page 9'
  create :protonym, :species_group, name: name, authorship: citation, forms: 'dealate queen'
end
