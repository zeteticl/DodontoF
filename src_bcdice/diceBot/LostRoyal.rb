# -*- coding: utf-8 -*-

class LostRoyal < DiceBot
  
  def initialize
    super
    @sendMode = 2
    @sortType = 1
    @d66Type = 1
  end
  
  def gameName
    'ロストロイヤル'
  end
  
  def gameType
    "LostRoyal"
  end
  
  def prefixs
    ['LR\[[0-5],[0-5],[0-5],[0-5],[0-5],[0-5]\]', 'FC']
  end
  
  def getHelpMessage
    return <<INFO_MESSAGE_TEXT
・D66ダイスあり

行為判定
　LR[x,x,x,x,x,x]
　　x の並びには【判定表】の数値を順番に入力する。
　　（例： LR[1,3,0,1,2] ）

ファンブル表
　FC
INFO_MESSAGE_TEXT
  end
  
  def rollDiceCommand(command)
    
    case command
      when /LR\[([0-5]),([0-5]),([0-5]),([0-5]),([0-5]),([0-5])\]/i
        return check_lostroyal([$1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i,])
      when /FC/
        return roll_fumble_chart
    end
    
    return nil
  end
  
  def check_lostroyal(checking_table)
    keys = []
    
    for i in 0...3
      key, = roll(1, 6)
      keys << key
    end
    
    scores = (keys.map do |k| checking_table[k - 1] end).to_a
    total_score = scores.inject(:+)
    
    chained_sequence = find_sequence(keys)
    
    text = "3D6 => [#{keys.join(",")}] => (#{scores.join("+")}) => #{total_score}"
    
    unless chained_sequence.nil? || chained_sequence.empty? then
      text += " | #{chained_sequence.size} chain! (#{chained_sequence.join(",")}) => #{total_score + chained_sequence.size}"
      
      if chained_sequence.size >= 3 then
        text += " [スペシャル]"
      end
      
      if is_fumble?(keys, chained_sequence) then
        text += " [ファンブル]"
      end
    end
    
    return text
  end
  
  def find_sequence(keys)
    keys = keys.sort
    
    sequence = (1...6).map do |start_key|
      find_sequence_from_start_key(keys, start_key)
    end.find_all do |x|
      x.size > 1
    end.sort do |a, b|
      a.size <=> b.size
    end.last
    
    sequence
  end
  
  def find_sequence_from_start_key(keys, start_key)
    chained_keys = []
    
    key = start_key
    
    while keys.include? key
      chained_keys << key
      key += 1
    end
    
    if chained_keys.size > 0 && chained_keys[0] == 1 then
      key = 6
      while keys.include? key
        chained_keys.unshift key
        key -= 1
      end
    end
    
    return chained_keys
  end
  
  def is_fumble?(keys, chained_sequence)
    for k in chained_sequence
      if keys.count(k) >= 2 then
        return true
      end
    end
    
    false
  end
  
  def roll_fumble_chart
    key, = roll(1, 6)
    
    text = [
      "何かの問題で言い争い、主君に無礼を働いてしまう。あなたは主君の名誉点を１点失うか、【時間】を１点消費して和解の話し合いを持つか選べる。",
      "見過ごせば人々を不幸にする危険に遭遇する。あなたは逃げ出して冒険の名誉点を１点失うか、これに立ち向かい【命数】を２点減らすかを選べる。",
      "あなたが惹かれたのは好意に付け込む人だった。あなたはその場を去って恋慕の名誉点を１点失うか【正義】を１点減らして礼を尽くすかを選べる。",
      "金銭的な問題で、生命と魂の苦しみを背負う人に出会う。あなたは庇護の名誉点を１点失うか出費を３点増やすかを選べる。",
      "襲撃を受ける。苦もなく叩き伏せると、卑屈な態度で命乞いをしてきた。容赦なく命を奪い寛容の名誉点を１点失うか、密告によって【血路】が１Ｄ６点増えるかを選ぶことができる。",
      "風聞により、友が悪に身を貶めたと知る。共に並んだ戦場が色褪せる想いだ。戦友の名誉点を１点減らすか、【酒と歌】すべてを失うかを選べる。",
    ][key - 1]
    
    return "1D6 => [#{key}] #{text}"
  end
end
