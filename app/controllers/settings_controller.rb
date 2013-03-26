class SettingsController < ApplicationController
  authorize_resource

  def update
    errors = 0

    unless params[:setting][:max_level].blank?
      begin
        max_level = Integer(params[:setting][:max_level])
        Setting.find_by_key("MAX_LEVEL") { |s| s.value = max_level }.save
      rescue ArgumentError
        errors += 1
        flash[:alert_max_level] = "Kidding? The level you tell me is not a number!"
      end
    end

    Setting.find_by_key("SHOW_ANNOUNCEMENT") { |s| s.value = params[:setting][:show_announcement] }.save
    if Setting.where(:key => "ANNOUNCEMENT").last.value != params[:setting][:announcement]
      Setting.new(:key => "ANNOUNCEMENT", :value => params[:setting][:announcement]).save
    end

    if errors == 0
      redirect_to edit_setting_path, :notice => "Update settings successfully!"
    else
      render :action => :edit
    end
  end
end
