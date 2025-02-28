class CarePlansController < ApplicationController
  before_action :set_fhir_client
  before_action :set_care_plan, only: [:show, :edit, :update, :destroy]

  # GET /care_plans
  # GET /care_plans.json
  def index
    bundle = @fhir_client.read_feed(FHIR::CarePlan).resource
    @care_plans = []
    bundle.entry.each do |entry|
      fhir_care_plan = entry.resource
      @care_plans << CarePlan.new(fhir_care_plan, @fhir_client)
    end
  end

  # GET /care_plans/1
  # GET /care_plans/1.json
  def show
  end

  # GET /care_plans/new
  def new 
    file = File.read('app/controllers/careplan1.json')
    fhir_care_plan = JSON.parse(file, object_class: OpenStruct) # Use OpenStruct to enable dot synthax
    @care_plan = CarePlan.new(fhir_care_plan, @fhir_client)
  end

  # GET /care_plans/1/edit
  def edit
  end

  # POST /care_plans
  # POST /care_plans.json
  def create
    file = File.read('app/controllers/careplan1.json')
    fhir_care_plan = JSON.parse(file, object_class: OpenStruct)
    @care_plan = CarePlan.new(fhir_care_plan, @fhir_client)
    respond_to do |format|
      if @care_plan.id
        format.html { redirect_to care_plan_path(@care_plan.id), notice: 'Care plan was successfully created.' }
        format.json { render :show, status: :created, location: @care_plan }
      else
        format.html { render :new }
        format.json { render json: @care_plan&.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /care_plans/1
  # PATCH/PUT /care_plans/1.json
  def update
    respond_to do |format|
      if @care_plan&.update(care_plan_params)
        format.html { redirect_to care_plan_path(@care_plan.id), notice: 'Care plan was successfully updated.' }
        format.json { render :show, status: :ok, location: @care_plan }
      else
        format.html { render :edit }
        format.json { render json: @care_plan&.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /care_plans/1
  # DELETE /care_plans/1.json
  def destroy
    #@care_plan&.destroy
    @fhir_client.destroy(FHIR::CarePlan, @care_plan.id) if @care_plan
    respond_to do |format|
      format.html { redirect_to care_plans_url, notice: 'Care plan was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fhir_client
      @fhir_client = SessionHandler.fhir_client(session.id)
    end
    
    def set_care_plan
      # @care_plan = CarePlan.find(params[:id])
      fhir_response = @fhir_client.read(FHIR::CarePlan, params[:id])
      fhir_care_plan = fhir_response.resource
      @care_plan = CarePlan.new(fhir_care_plan, @fhir_client) unless fhir_care_plan.nil?
      @fhir_queries = [ "#{fhir_response.request[:method].upcase} #{fhir_response.request[:url]}"]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def care_plan_params
      params.permit!
    end
end
