class BookReference < Reference
  belongs_to :publisher

  validates_presence_of :publisher, :pagination

  def self.import base_class_data, data
    create! base_class_data.merge(
      :pagination => data[:pagination],
      :publisher => Publisher.import(data[:publisher])
    )
  end

end
