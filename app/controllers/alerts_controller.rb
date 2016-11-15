class AlertsController < ApplicationController
  before_action :set_alert, only: [:show, :edit, :update, :destroy]

  # GET /alerts
  def index
    @alerts = Alert.all
  end

  # GET /alerts/1
  def show
  end

  # GET /alerts/new
  def new
    @alert = Alert.new
    @alert.ticker = Order.where(id: params[:order_id]).last.try(:ticker)
    @orders = Order.where(user: current_user).order("updated_at DESC")
  end

  # GET /alerts/1/edit
  def edit
  end

  # POST /alerts
  def create
    @alert = Alert.new(alert_params)
    @alert.update(user: current_user, status: "active")

    if @alert.save
      redirect_to @alert, notice: 'Alert was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /alerts/1
  def update
    if @alert.update(alert_params)
      redirect_to @alert, notice: 'Alert was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /alerts/1
  def destroy
    @alert.destroy
    redirect_to alerts_url, notice: 'Alert was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_alert
      @alert = Alert.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def alert_params
      params.require(:alert).permit(:ticker, :exchange, :comparison_logic, :price, :order_id)
    end
end
