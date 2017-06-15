class AddEventAlertToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :event_alert, :integer, default: 0
  end
end
