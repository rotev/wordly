class Post < ActiveRecord::Base
  attr_protected :author_id
  acts_as_taggable_on :tags
  before_save :set_slug

  belongs_to :author
  has_many :comments
  has_and_belongs_to_many :categories

  private

  def set_slug
    self.slug = self.title.downcase.parameterize if self.slug.blank?
  end
end
