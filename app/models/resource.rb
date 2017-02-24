class Resource < ApplicationRecord
  belongs_to :user

  mount_uploader :handle, ResourceUploader

  enum category: { gallery: 0, global: 1 }

  validates :handle, :presence => true
  validate :handle_size_validation

  attr_reader :url, :title

  before_save :set_size

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

    def set_size
      if File.exist? handle.path
        image = MiniMagick::Image.open(handle.path)
        self.width = image[:width]
        self.height = image[:height]
      elsif handle.width.present? and handle.height.present?
        self.width = self.handle.width
        self.height = self.handle.height
      end
    end
end