class Link < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:title, :url, :content, :description]

  has_many :link_interactions, dependent: :destroy
  has_many :link_tags, dependent: :destroy
  has_many :tags, through: :link_tags
  belongs_to :user

  before_validation :normalize_url

  validates :title, length: { maximum: 120 }, presence: true
  validates :url, length: { maximum: 200 }, format: { with: URI::regexp(%w(http https)), message: "should be a valid address" }

  def save_and_publish
    save.tap do |save_succeeded|
      link_interactions.each { |li| li.perform_or_schedule! if save_succeeded }
    end
  end

  def default_tag
    link_tags.default.present? ? link_tags.default.first.tag : nil
  end

  protected
  def normalize_url
    self.url = "http://#{url}" unless url.blank? || url.start_with?("http")
  end
end
