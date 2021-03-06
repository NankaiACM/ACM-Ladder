class SubmissionsController < ApplicationController
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    begin
      @current_page = Integer(params[:page])
      if @current_page < 1
        flash[:alert] = "Kidding? The page you tell me is non-positive!"
        @current_page = 1
      end
    rescue ArgumentError
      flash[:alert] = "Kidding? The page you tell me is not a number!"
      @current_page = 1
    end
    if params[:user_id]
      user = User.find_by_handle(params[:user_id])
      if user_signed_in? && current_user.has_role?(:admin)
        @submissions = user.submissions.offset((@current_page - 1) * 10).last(10).reverse
      else
        @submissions = user.submissions.joins(:problem).where("`problems`.`level` != -1").offset((@current_page - 1) * 10).last(10).reverse
      end
    else
      if user_signed_in? && current_user.has_role?(:admin)
        @submissions = Submission.offset((@current_page - 1) * 10).last(10).reverse
      else
        @submissions = Submission.joins(:problem).where("`problems`.`level` != -1").offset((@current_page - 1) * 10).last(10).reverse
      end
    end
  end

  def new
    @problem = Problem.find(params[:problem_id])
    @submission.language = session[:lang]
  end

  def create
    @problem = Problem.find(params[:problem_id])
    @submission.problem = @problem
    @submission.user = current_user

    if @submission.save
      session[:lang] = @submission.language
      OJ.submit(@submission)	# delayed job
      redirect_to user_submissions_path(current_user), :notice => "Submit successfully."
    else
      flash[:alert] = "Failed to submit."
      render :action => :new
    end
  end

  def update
    @submission = Submission.new(params[:submission])
    create
  end

  def show
    if @submission.user_id != current_user.id && !current_user.has_role?(:admin)
      redirect_to submissions_path, :alert => "It's not for you..."
    end
    @problem = @submission.problem
  end
end
