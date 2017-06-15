class PartnersPage
  include ActiveModel::Model
  attr_accessor :base_line, :section_1, :section_1_ids, :section_2, :section_2_ids, :section_3, :section_3_ids, :exergue, :aside_link_1_data, :aside_link_2_data

  def initialize(attributes={})
    super
    @base_line         ||= SingleData.partners_baseline.v
    @section_1         ||= SingleData.partners_section_1.v
    @section_1_ids     ||= SingleData.partners_section_1_ids.v
    @section_2         ||= SingleData.partners_section_2.v
    @section_2_ids     ||= SingleData.partners_section_2_ids.v
    @section_3         ||= SingleData.partners_section_3.v
    @section_3_ids     ||= SingleData.partners_section_3_ids.v
    @exergue           ||= SingleData.partners_exergue.v
    @aside_link_1_data ||= SingleData.partners_aside_link_1_data.v
    @aside_link_2_data ||= SingleData.partners_aside_link_2_data.v
  end

  def update(attributes={})
    if "base_line".in? attributes.keys
      success ||= 1
      success *= SingleData.partners_baseline.update(v: attributes[:base_line]) ? 1 : 0
    end
    if "section_1".in? attributes.keys
      success ||= 1
      success *= SingleData.partners_section_1.update(v: attributes[:section_1]) ? 1 : 0
    end
    if "section_1_ids".in? attributes.keys
      success ||= 1
      success *= SingleData.partners_section_1_ids.update(v: attributes[:section_1_ids]) ? 1 : 0
    end
    if "section_2".in? attributes.keys
      success ||= 1
      success *= SingleData.partners_section_2.update(v: attributes[:section_2]) ? 1 : 0
    end
    if "section_2_ids".in? attributes.keys
      success ||= 1
      success *= SingleData.partners_section_2_ids.update(v: attributes[:section_2_ids]) ? 1 : 0
    end
    if "section_3".in? attributes.keys
      success ||= 1
      success *= SingleData.partners_section_3.update(v: attributes[:section_3]) ? 1 : 0
    end
    if "section_3_ids".in? attributes.keys
      success ||= 1
      success *= SingleData.partners_section_3_ids.update(v: attributes[:section_3_ids]) ? 1 : 0
    end
    if "exergue".in? attributes.keys
      success ||= 1
      success *= SingleData.partners_exergue.update(v: attributes[:exergue]) ? 1 : 0
    end
    if "aside_link_1_data".in? attributes.keys
      success ||= 1
      success *= SingleData.partners_aside_link_1_data.update(v: attributes[:aside_link_1_data]) ? 1 : 0
    end
    if "aside_link_2_data".in? attributes.keys
      success ||= 1
      success *= SingleData.partners_aside_link_2_data.update(v: attributes[:aside_link_2_data]) ? 1 : 0
    end
    success = success == 1 ? true : false
    Rails.cache.delete(:partners_page) if success
    success
  end

  def save
    success = 1 
    success *= SingleData.partners_baseline.update(v: self.base_line) ? 1 : 0
    success *= SingleData.partners_section_1.update(v: self.section_1) ? 1 : 0
    success *= SingleData.partners_section_1_ids.update(v: self.section_1_ids) ? 1 : 0
    success *= SingleData.partners_section_2.update(v: self.section_2) ? 1 : 0
    success *= SingleData.partners_section_2_ids.update(v: self.section_2_ids) ? 1 : 0
    success *= SingleData.partners_section_3.update(v: self.section_3) ? 1 : 0
    success *= SingleData.partners_section_3_ids.update(v: self.section_3_ids) ? 1 : 0
    success *= SingleData.partners_exergue.update(v: self.exergue) ? 1 : 0
    success *= SingleData.partners_aside_link_1_data.update(v: self.aside_link_1_data) ? 1 : 0
    success *= SingleData.partners_aside_link_2_data.update(v: self.aside_link_2_data) ? 1 : 0
    success = success == 1 ? true : false
    Rails.cache.delete(:partners_page) if success
    success
  end
end 