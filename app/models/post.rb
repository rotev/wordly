class Post < ActiveRecord::Base

  include ActionView::Helpers::SanitizeHelper

  attr_protected :author_id
  acts_as_taggable_on :tags
  after_create :set_uid
  before_save :set_slug

  belongs_to :author
  has_many :comments
  has_and_belongs_to_many :categories

  validates :title,    :presence => true,  :length => { :minimum => 2 }
  validates :content,  :presence => true,  :length => { :minimum => 10 }
  validates :excerpt,                      :length => { :minimum => 2 }, :allow_blank => true
  validates :slug,     :uniqueness => true, :allow_nil => false

  # published posts
  scope :published, where(:published => 1).includes(:categories, :author)

  # posts in category
  scope :in_category, lambda {|category_id|
    where(["posts.published = 1 and categories_posts.category_id = ?", category_id]).joins(:categories, :author).includes(:categories, :author)
  }

  scope :latest_by_author, lambda { |author_id|
    where(['author_id = ?', author_id]).order('created_at desc').limit(10)
  }

  def post_excerpt
    excerpt || strip_tags(content.gsub(/<\/([^>]+)>/,"</$1> ")).split(' ')[0..30].join(' ') + '...'
  end

  def self.id_from_uid(uid)
    Base64::decode64(uid)[8..-1].to_i
  end

  private

  def set_uid
    salt = rand(36**8).to_s(36)
    str = [salt,self.id].join('')
    self.uid = Base64::encode64(str).gsub(/\n/,'')
    self.save
  end

  def set_slug
    self.slug = self.title.downcase.parameterize if self.slug.blank?
  end
end
