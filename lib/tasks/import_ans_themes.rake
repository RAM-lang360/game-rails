namespace :import do
  desc 'Import ans themes from CSV'
  task ans_themes: :environment do
    require 'csv'
    csv_path = Rails.root.join('db/csv/good_ans.csv')
    CSV.foreach(csv_path, headers: false) do |row|
      text = row[0].to_s.strip
      next if text.blank?
      AnsTheme.create!(text: text)
    end
    puts 'Import completed!'
  end
end
