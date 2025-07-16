require 'csv'

CSV.foreach('db/csv/good_ans.csv', headers: true) do |row|
  AnsTheme.find_or_create_by!(text: row['text']) # textカラムにデータを投入
  # find_or_create_by! は、textが同じデータが既にDBにあれば作成せず、なければ新しく作成します。
  # 重複を許すなら Item.create!(text: row['text']) でもOK
end

puts "CSVデータが投入されました"
