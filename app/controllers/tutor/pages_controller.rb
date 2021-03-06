class Tutor::PagesController < ApplicationController
  before_filter :require_tutor

  before_filter :get_stitch_unit, :except => [:show_answers]
  before_filter :get_group, :only => [:show_answers]

  def get_stitch_unit
    @stitch_unit = StitchUnit.find(params[:stitch_unit_id])
    @course = @stitch_unit.course
  end
  
  def get_group
    @group = Group.find(params[:group_id])
    @student = Student.find(params[:student_id])
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
  
  def show_answers
    @page = Page.find(params[:id]) 
    @grade = Grade.where(:student_id => @student, :tutor_id => current_user.role, :gradable_id => @page.stitch_unit, :gradable_type => @page.stitch_unit.class.name ).first
    respond_to do |format|
      format.html
    end   
  end
  
end
