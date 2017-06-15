class PartnersPage
  include ActiveModel::Model

  ATTR_ACCESSOR_LIST = :main_gallery_id,
    :resource_id,
    :subtitle,
    :section_1,
    :section_1_ids,
    :section_2,
    :section_2_ids,
    :section_3,
    :section_3_ids,
    :exergue,
    :aside_link_1_data,
    :aside_link_2_data
  ATTR_ACCESSOR_LIST.map{ |attribute| attr_accessor attribute }

  def initialize(attributes={})
    super
    ATTR_ACCESSOR_LIST.each do |attribute|
      self.send("#{attribute.to_s}=", SingleData.send("partners_#{attribute.to_s}".to_sym).v) if self.send("#{attribute.to_s}").nil?
    end
  end

  def update(attributes={})
    ATTR_ACCESSOR_LIST.each do |attribute|
      if attribute.to_s.in? attributes.keys
        @success ||= 1
        attributes[attribute] = attributes[attribute] - [""] if attributes[attribute].is_a? Array
        @success *= SingleData.send("partners_#{attribute.to_s}".to_sym).update(v: attributes[attribute]) ? 1 : 0
      end
    end
    Rails.cache.delete(:partners_page)
    @success == 1 ? true : false
  end

  def save
    @success = 1
    ATTR_ACCESSOR_LIST.each do |attribute|
      @success *= SingleData.send("partners_#{attribute.to_s}".to_sym).update(v: self.send(attribute)) ? 1 : 0
    end
    Rails.cache.delete(:partners_page)
    @success == 1 ? true : false
  end
end 