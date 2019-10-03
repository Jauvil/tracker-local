i = 0
#Give broader unicode support by adding fonts (must be .ttf files).
#To include the font family in the pdf, font files must be added 
#to the tracker/app/assets/fonts directory. 
font_families.update("Amiri" => { #Amiri: Arabic font
    :normal => "#{Rails.root}/app/assets/fonts/Amiri/Amiri-Regular.ttf",
    :italic => "#{Rails.root}/app/assets/fonts/Amiri/Amiri-Italic.ttf",
    :bold => "#{Rails.root}/app/assets/fonts/Amiri/Amiri-Bold.ttf",
    :bold_italic => "#{Rails.root}/app/assets/fonts/Amiri/Amiri-BoldItalic.ttf"
  }, 
  # M_PLUS_1p: Supports Cyrillic (extended), Greek (extended), Hebrew, Japanese, Latin (Extended), Vienamese
  "M_PLUS_1p" => {
    :normal => "#{Rails.root}/app/assets/fonts/M_PLUS_1p/MPLUS1p-Regular.ttf",
    :italic => "#{Rails.root}/app/assets/fonts/M_PLUS_1p/MPLUS1p-Light.ttf",
    :bold => "#{Rails.root}/app/assets/fonts/M_PLUS_1p/MPLUS1p-Bold.ttf",
    :bold_italic => "#{Rails.root}/app/assets/fonts/M_PLUS_1p/MPLUS1p-ExtraBold.ttf"
  },
  # ZCOOL_XiaoWei: Chinese (simplified) font
  "ZCOOL_XiaoWei" => {
    :normal => "#{Rails.root}/app/assets/fonts/ZCOOL_XiaoWei/ZCOOLXiaoWei-Regular.ttf",
    :italic => "#{Rails.root}/app/assets/fonts/ZCOOL_XiaoWei/ZCOOLXiaoWei-Regular.ttf",
    :bold => "#{Rails.root}/app/assets/fonts/ZCOOL_XiaoWei/ZCOOLXiaoWei-Regular.ttf",
    :bold_italic => "#{Rails.root}/app/assets/fonts/ZCOOL_XiaoWei/ZCOOLXiaoWei-Regular.ttf"
})

#Set fallback fonts to use if Prawn's default font does not recognize a unicode character.
pdf.fallback_fonts ["Amiri", "M_PLUS_1p", "ZCOOL_XiaoWei"]
@students.each do |student|
  if params[:student_id].include? student.id.to_s
    pdf.start_new_page unless i == 0
    pdf.text "#{student.last_name_first}", size: 13
    pdf.text "#{@section.subject.school.name}", size: 12
    pdf.text "#{@section.subject.name}, taught by #{@section.teacher_names}", size: 11
    pdf.move_down 4
    pdf.text "<b>Progress Report: <i>Marking Period(s) #{params[:marking_periods].to_sentence}</i></b>", inline_format: true, align: :center
    pdf.move_down 4
    pdf.horizontal_rule
    pdf.move_down 3
    pdf.horizontal_rule
    pdf.move_down 4
    pdf.stroke
    ratings_count = student.hash_of_section_outcome_rating_counts(marking_periods: params[:marking_periods])
    data = [
      ["Rating", "Count"],
      ["High Performance", ratings_count[@section.id][:H]],
      ["Proficient", ratings_count[@section.id][:P]],
      ["Not Yet Proficient", ratings_count[@section.id][:N]],
      ["Total Ratings", (ratings_count[@section.id][:H] + ratings_count[@section.id][:P] + ratings_count[@section.id][:N])]
    ]
    pdf.table(data, :position => :center, :header => true, :cell_style => {:vertical_padding => '2', :size => 11})
    pdf.horizontal_rule
    pdf.stroke
    pdf.move_down 12
    if params[:message].present?
        pdf.text "<b>Message from Teacher</b>", inline_format: true, align: :center
        pdf.move_down 12
        pdf.text "<i>#{params[:message]}</i>", inline_format: true, size: 11
        pdf.move_down 12
        pdf.horizontal_rule
        pdf.stroke
        pdf.move_down 12
    end
    @section.section_outcomes.each do |section_outcome|
      if (section_outcome.marking_period_array & params[:marking_periods]).length > 0
      section_outcome_rating = @section_outcome_ratings[section_outcome.id][student.id][0]
      if section_outcome_rating != "U" || (section_outcome.evidence_section_outcomes.count > 0 && params[:print_unrated] == 1) || (params[:print_unrated] == 2)
          pdf.text "<b>#{long_section_outcome_rating section_outcome_rating}</b>: <i>#{section_outcome.name}</i>", inline_format: true, size: 11
          pdf.text "<i>Marking Period(s) #{section_outcome.marking_period_array.to_sentence}</i>", inline_format: true, size: 8
          data = []
          if params[:summary].blank?
            section_outcome.evidence_section_outcomes.each do |evidence_section_outcome|
              data << ["#{evidence_section_outcome.name}", "#{evidence_section_outcome.evidence_type.name}", "#{@evidence_ratings[section_outcome.id][evidence_section_outcome.evidence_id][student.id][0]}", "#{@evidence_ratings[section_outcome.id][evidence_section_outcome.evidence_id][student.id][1]}"]
            end
            pdf.indent 20 do
              if data.length > 0
                pdf.table(data, :column_widths => { 0 => 170, 1 => 100, 2 => 30, 3 => 200 }, :cell_style => {size: 10})
              end
            end
          end
          pdf.move_down 10
        end
      end
    end
    i += 1
  end
end