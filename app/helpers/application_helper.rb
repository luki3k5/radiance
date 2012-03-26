module ApplicationHelper
  def filter_local_links(html)

    #replace local page links
    @page_links = html.scan(/intern:\/\/page\/\d*/)
    @page_links.each do |link|
      target_page = Page.find_by_id(link.scan(/intern:\/\/page\/(\d*)/))
      if current_user.role.class == Developer
        if controller.action_name == 'edit'
          target_link = edit_developer_stitch_unit_page_path(target_page.stitch_unit,target_page)
        else
          target_link = developer_stitch_unit_page_path(target_page.stitch_unit,target_page)
        end
      elsif current_user.role.class == Tutor
        target_link = tutor_stitch_unit_page_path(target_page.stitch_unit,target_page)
      elsif current_user.role.class == Student
        target_link = student_stitch_unit_page_path(target_page.stitch_unit,target_page)
      end
      html.gsub!(link, target_link)
    end

    @biblio_links = html.scan(/intern:\/\/biblio/)
    @biblio_links.each do |link|
      target_page = @page.stitch_module.last_page
      if current_user.role.class == Developer        
        if controller.action_name == 'edit'
          target_link = edit_developer_stitch_unit_page_path(target_page.stitch_unit,target_page)
        else
          target_link = developer_stitch_unit_page_path(target_page.stitch_unit,target_page)
        end
      elsif current_user.role.class == Tutor
        target_link = tutor_stitch_unit_page_path(target_page.stitch_unit,target_page)
      elsif current_user.role.class == Student
        target_link = student_stitch_unit_page_path(target_page.stitch_unit,target_page)
      end
      html.gsub!(link, target_link)
    end
    
    @faq_links = html.scan(/intern:\/\/faq/)
    @faq_links.each do |link|
      target_link = faqs_path
      html.gsub!(link, target_link)      
    end

    html
  end
  
  def avatar_url(user)
    gravatar_id = Digest::MD5::hexdigest(user.profile.email).downcase
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=mm"
  end
  
  def show_deadline_course(course, student)
    deadline_group = student.groups.map {|g| g if g.course_id == course.id}
    deadline_id = Deadline.where(:deadlinable_id => deadline_group)
    unless deadline_id.empty?
      deadline = Deadline.find(deadline_id)
      return deadline.due_date #.strftime('%d.%m.%Y - %H:%M')
    end
  end
  
  def show_deadline_page(page, student)
    unless page.deadlines.empty?
      deadline_group = student.groups.map {|g| g if g.course_id == page.course.id}
      deadline_id = Deadline.where(:group_id => deadline_group[0], :deadlinable_id => page.id)
      unless deadline_id.empty?
        deadline = Deadline.find(deadline_id)
        return deadline.due_date #.strftime('%d.%m.%Y - %H:%M')
      end
    else
      show_deadline_course(page.course, student)
    end
  end
  
  def find_answer(content)
    element = content.element
    if content.element_type == "Question"
      if element.answers.empty?
        new_student_content_element_answer_path(content, element)
      else        
        a = Answer.where(:student_id => current_user.role.id, :question_id => element.id)
        answer = Answer.find(a)
        edit_student_content_element_answer_path(content, element, answer)
      end
    end
  end
  
  def show_answer(element, student)
    unless element.answers.empty?
      a = Answer.where(:student_id => student.id, :question_id => element.id)
      answer = Answer.find(a)
      return answer
    end
  end
  
  def show_score(element, user)
    unless element.question_scores.empty?
      s = QuestionScore.where(:tutor_id => user.id, :question_id => element.id)
      score = QuestionScore.find(s)
      return score.value
    end
  end
  
  def find_question_score(content, student=nil)
    element = content.element
    if content.element_type == "Question"
      if student
        a = Answer.where(:student_id => student.id, :question_id => element.id)
        answer = Answer.find(a)
        edit_tutor_content_element_student_answer_path(content, element, student, answer)
      elsif element.question_scores.empty?
        new_tutor_content_element_question_score_path(content, element)
      else        
        qs = QuestionScore.where(:tutor_id => current_user.role.id, :question_id => element.id)
        question_score = QuestionScore.find(qs)
        edit_tutor_content_element_question_score_path(content, element, question_score)
      end
    end
  end
  
  def show_grade(gradable, student, tutor)
    g = Grade.where(:student_id => student.id, :tutor_id => tutor.id, :gradable_id => gradable.id, :gradable_type => gradable.class.name)
    grade = Grade.find(g)
    return grade
  end
  
  def show_national_assesment(value=0)
    unless value.nil?
      da = DefaultAssesment.where("lower_treshold <= ? AND upper_treshold >= ?", value, value)
      default_assesment = DefaultAssesment.find(da)
      return default_assesment.name
    end
  end
  
  def find_assignment_page(stitch_unit, group, student, tutor=nil)
    all_assignment_pages = Page.where(:assignment => true)
    unit_assignment_page = all_assignment_pages.where(:stitch_unit_id => stitch_unit.id)
    if unit_assignment_page.empty?
      return ""
    else
      page = Page.find(unit_assignment_page)
      tutor ? show_answers_tutor_group_student_page_path(group.id, student.id, page) : student_stitch_unit_page_path(stitch_unit, page)
        
    end
  end
  
  def find_default_assesment(course, tutor)
    def_assesment = DefaultAssesment.where(:course_id => course.id, :tutor_id => tutor.id)
    if def_assesment.empty?
      new_tutor_course_default_assesment_path(course)
    else
      da = DefaultAssesment.find(def_assesment[0].id)
      tutor_course_default_assesment_path(course, da)
    end
  end
    
end
