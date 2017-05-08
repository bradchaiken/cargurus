class CarsController < ApplicationController

  # GET /cars/new
  def new
    @car = car.new
  end

  # POST /cars
  # POST /cars.json
  def create
    @car = car.new(car_params)
    if @car.save
      ap "Car Saved"
      # format.html { redirect_to cars_path, notice: 'car was successfully created.' }
      # format.json { render :show, status: :created, location: @car }
    else
      ap "Car failed to persist."
      # format.html { render :new }
      # format.json { render json: @car.errors, status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /cars/1
  # PATCH/PUT /cars/1.json
  def update
    respond_to do |format|
      if @car.update(car_params)
        # format.html { redirect_to @car, notice: 'car was successfully updated.' }
        # format.json { render :show, status: :ok, location: @car }
      else
        # format.html { render :edit }
        # format.json { render json: @car.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cars/1
  # DELETE /cars/1.json
  def destroy
    @car.destroy
    respond_to do |format|
      # format.html { redirect_to cars_url, notice: 'car was successfully destroyed.' }
      # format.json { head :no_content }
    end
  end

  private

    def car_params
      params.require(:car).permit(:instant_market_value, :dealer_trade_in_estimate, :dealer_trade_in_estimate, :vin, :make, :model, :year, :url)
    end

end
