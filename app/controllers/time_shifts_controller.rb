class TimeShiftsController < ApplicationController
  inherit_resources

  def index
    @time_sheet_form = TimeSheetForm.new params[:time_sheet_form]

    query = TimeSheetQuery.new @time_sheet_form

    # TODO Устанвливать доступные проекты исходя их уровня доступа
    query.available_projects = current_user.projects unless current_user.is_root?
    query.available_users = [current_user] unless current_user.is_root?

    @groups = query.perform
  end

  def new
    super
    @time_shift.user_id = current_user.id
  end

  protected

  def permitted_params
    # TODO Проверить что проект разрешен для добавления времени
    params[:time_shift] ||= {}
    params[:time_shift][:user_id] = current_user.id unless current_user.is_root?
    params.permit :time_shift => [:project_id, :hours, :date, :user_id]
  end

  def collection
    if current_user.is_root?
      @time_shifts = TimeShift.ordered.includes(:project, :user)
    else
      @time_shifts = current_user.time_shifts.ordered.includes(:project, :user)
    end
  end
end
