class Resource < ApplicationRecord
  belongs_to :user
  has_many :image_ships
  has_many :galleries, through: :image_ships

  mount_uploader :handle, ResourceUploader

  enum category: { gallery: 0, global: 1 }

  validates :handle, :presence => true
  validate :handle_size_validation

  attr_reader :url, :title

  def title
    @title || get_title
  end

  def url
    @url || get_url
  end

  private
    def handle_size_validation
      errors[:handle] << "doit peser moins de 2 Mo" if handle.size > 2.megabytes
    end

    def get_title
      self.name || "#{self.id} (sans nom)"
    end

    def get_url
      self.handle.url
    end

    def get_version_url(version)
      if self.handle.send(version).present?
        self.handle.send(version).url
      elsif self.handle.content_type.start_with? 'image'
        self.handle.url
      else
        # file icon
        # ActionController::Base.helpers.image_url 'file_icon.svg'
      end
    end
end