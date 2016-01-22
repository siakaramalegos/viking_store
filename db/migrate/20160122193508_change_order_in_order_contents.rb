class ChangeOrderInOrderContents < ActiveRecord::Migration
  def change
    change_column_null :order_contents, :order_id, true
  end
end
