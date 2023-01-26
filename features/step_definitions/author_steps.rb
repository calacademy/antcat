# frozen_string_literal: true

def an_author_name_exists_with_a_name_of name
  create :author_name, name: name
end

def the_following_names_exist_for_an_author *author_name_strings
  author = create :author
  Array.wrap(author_name_strings).each do |author_name_string|
    author.names.create!(name: author_name_string)
  end
end

def i_set_author_to_merge_id_to_the_id_of author_name
  author = AuthorName.find_by!(name: author_name).author
  find('#author_to_merge_id', visible: false).set author.id # HACK: For when JavaScript is disabled.
end
