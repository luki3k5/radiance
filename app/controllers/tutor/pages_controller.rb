class Tutor::PagesController < ApplicationController
  before_filter :require_tutor

  before_filter :get_stitch_unit

  def get_stitch_unit
    @stitch_unit = StitchUnit.find(params[:stitch_unit_id])
    @course = @stitch_unit.course
  end
  
  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = @stitch_unit.pages.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def ajax_show
    @page = @stitch_unit.pages.find(params[:id])
    respond_to do |format|
      format.html { render :layout => false}
    end
  end
  
  def edit
    @page = @stitch_unit.pages.find(params[:id])
    @groups = current_user.role.groups.where(:course_id => @course.id)
  end

  def update
    @page = @stitch_unit.pages.find(params[:id])
    @page.create_page_deadline(params[:deadline], @page )
    redirect_to tutor_stitch_unit_page_path(@stitch_unit, @page)
  end

end