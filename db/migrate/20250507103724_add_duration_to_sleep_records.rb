class AddDurationToSleepRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :sleep_records, :duration, :integer
  end
end
