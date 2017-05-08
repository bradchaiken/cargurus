class CreateCars < ActiveRecord::Migration[5.0]
  def change
    create_table :cars do |t|
      t.string :instant_market_value
      t.string :dealer_trade_in_estimate
      t.string :profit_over_trade_in
      t.string :vin
      t.string :make
      t.string :model
      t.string :year
      t.string :url
    end
  end
end
