class CreateFestivalEventLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :festival_event_links do |t|
      t.belongs_to :festival, index: true, foreign_key: true
      t.belongs_to :event, index: true, foreign_key: true
    end
  end
end
