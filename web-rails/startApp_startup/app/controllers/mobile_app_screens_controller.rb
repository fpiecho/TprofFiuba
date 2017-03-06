class MobileAppScreensController < ApplicationController
  before_action :set_mobile_app_screen, only: [:show, :edit, :update, :destroy]
  before_action :set_mobile_app

  # GET /mobile_app_screens
  # GET /mobile_app_screens.json
  def index
    @mobile_app_screens = MobileAppScreen.where(mobile_app: @mobile_app)
  end

  # GET /mobile_app_screens/1
  # GET /mobile_app_screens/1.json
  def show
  end

  # GET /mobile_app_screens/new
  def new
    # Aca deberia validar que si no vino con cierto campo (el mobile app id), no puede entrar a la pantalla
    # Y si viene, validar que exista la mobile app
    @mobile_app_screen = MobileAppScreen.new
  end

  # GET /mobile_app_screens/1/edit
  def edit
  end

  # POST /mobile_app_screens
  # POST /mobile_app_screens.json
  def create
    @mobile_app_screen = MobileAppScreen.new(mobile_app_screen_params)
    @mobile_app_screen.mobile_app = @mobile_app

    @raw_html = params[:raw_html]
    @raw_html = @raw_html.gsub(/[\r\n\t]/,'')
    @mobile_app_screen.raw_html = @raw_html

    @editor_html = params[:editor_html]
    @editor_html = @editor_html.gsub(/[\r\n\t]/,'')
    @mobile_app_screen.editor_html = @editor_html

    @mobile_app_screen.wsURL = params[:wsURL]

    respond_to do |format|
      
      if @mobile_app_screen.save
        puts "-------------why????------------"
        format.html { redirect_to @mobile_app_screen, notice: 'Mobile app screen was successfully created.' }
        format.json { render :show, status: :created, location: @mobile_app_screen }
      else
        puts "--------good------------"
        format.html { render :new }
        format.json { render json: @mobile_app_screen.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mobile_app_screens/1
  # PATCH/PUT /mobile_app_screens/1.json
  def update
    @raw_html = params[:raw_html]
    @raw_html = @raw_html.gsub(/[\r\n\t]/,'')
    @mobile_app_screen.raw_html = @raw_html

    @editor_html = params[:editor_html]
    @editor_html = @editor_html.gsub(/[\r\n\t]/,'')
    @mobile_app_screen.editor_html = @editor_html

    @mobile_app_screen.wsURL = params[:wsURL]

    respond_to do |format|
      if @mobile_app_screen.update(mobile_app_screen_params)
        format.html { redirect_to @mobile_app_screen, notice: 'Mobile app screen was successfully updated.' }
        format.json { render :show, status: :ok, location: @mobile_app_screen }
      else
        format.html { render :edit }
        format.json { render json: @mobile_app_screen.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mobile_app_screens/1
  # DELETE /mobile_app_screens/1.json
  def destroy
    @mobile_app_screen.destroy
    respond_to do |format|
      format.html { redirect_to mobile_app_screens_url, notice: 'Mobile app screen was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mobile_app_screen
      @mobile_app_screen = MobileAppScreen.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mobile_app_screen_params
      params.require(:mobile_app_screen).permit(:mobile_app, :name, :raw_html, :editor_html, :wsURL)
    end

    def set_mobile_app
      if (session[:mobile_app_current_id])
        @mobile_app_id = session[:mobile_app_current_id]
        if (MobileApp.exists?(@mobile_app_id))
          @mobile_app = MobileApp.find(@mobile_app_id)
          ## TODO: verificar que sea de este user
          return
        end
      end
                  
      redirect_to mobile_apps_path, alert: 'Debes seleccionar una aplicación.'
    end

end
