class MobileAppsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mobile_app, only: [:show, :edit, :update, :destroy]

  # GET /mobile_apps
  # GET /mobile_apps.json
  def index
    @mobile_apps = MobileApp.all
  end

  # GET /mobile_apps/1
  # GET /mobile_apps/1.json
  def show
  end

  # GET /mobile_apps/new
  def new
    @mobile_app = MobileApp.new
  end

  # GET /mobile_apps/1/edit
  def edit
  end

  # POST /mobile_apps
  # POST /mobile_apps.json
  def create
    @mobile_app = MobileApp.new(mobile_app_params)

    respond_to do |format|
      if !mobile_app_params[:title].blank?
        if @mobile_app.save
          name = @mobile_app.title;
          appsPath = Rails.root.join('mobileApps');
          appType = @mobile_app.apptype.downcase;
          appPath = appsPath.join(name);
          %x[cd #{appsPath} && ionic start #{name} #{appType}]
          %x[cd #{appPath} && ionic platform add android]

          system("cd #{appPath} && ionic serve --nobrowser --address localhost &");
          format.html { redirect_to @mobile_app, notice: 'Mobile app ' + name +' was successfully created.' }
          format.json { render :show, status: :created, location: @mobile_app }
        else
          format.html { render :new }
          format.json { render json: @mobile_app.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /mobile_apps/1
  # PATCH/PUT /mobile_apps/1.json
  def update
    respond_to do |format|
      if @mobile_app.update(mobile_app_params)
        format.html { redirect_to @mobile_app, notice: 'Mobile app was successfully updated.' }
        format.json { render :show, status: :ok, location: @mobile_app }
      else
        format.html { render :edit }
        format.json { render json: @mobile_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mobile_apps/1
  # DELETE /mobile_apps/1.json
  def destroy
    @mobile_app.destroy
    respond_to do |format|
      format.html { redirect_to mobile_apps_url, notice: 'Mobile app was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mobile_app
      @mobile_app = MobileApp.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mobile_app_params
      params.require(:mobile_app).permit(:title, :description, :apptype)
    end
end
