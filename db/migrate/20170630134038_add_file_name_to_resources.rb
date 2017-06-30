class AddFileNameToResources < ActiveRecord::Migration[5.0]
  def up
    add_column :resources, :file_name, :string
    total = Resource.all.size
    puts "\n====> #{total} resources to update. Please wait ...\n\n"
    n = 0
    i = 0
    Resource.all.find_each do |r|
      i += 1
      n += 1 if r.update(file_name: r.handle_identifier)
      print "\r----> Resource #{i}/#{total} updated."
    end
    puts "\n====> Done. #{n}/#{total} resources updated.\n\n"
  end

  def down
    remove_column :resources, :file_name
  end
end
