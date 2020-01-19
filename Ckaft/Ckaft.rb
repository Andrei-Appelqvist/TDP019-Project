require './rdparse'
require './code'

class Ckaft
  def initialize
    @ckaft = Parser.new("Ckaft") do
      #@var_table = Hash.new()
      token(/\s+/) #whitespace (ignorera)
      token(/\/\*(.|\n)*\*\//) #multiline comments
      token(/\#.*/) #Comments
      token(/\d+[.]\d+/) {|m| m.to_f} #pos float
      token(/-(\d+[.]\d+)/) {|m|m.to_f} #neg float
      token(/\d+/) {|m| m.to_i} #Integer
      token(/-\d+/) {|m| m.to_i} #neg int
      token(/[a-z]+/) {|m| m.to_s} #Chars
      token(/"[^\"]*"/) {|m| m }#string ""
      token(/'[^\']*'/) {|m| m }#strin ''
      token(/if/){|m| m.to_s}
      token(/else/){|m| m.to_s}
      token(/while/){|m| m.to_s}
      token(/return/){|m| m.to_s}
      token(/break/){|m| m.to_s}
      token(/def/){|m| m.to_s}
      token(/print/){|m| m.to_s}
      #equal operations
      token(/\=\=/) {|m| m}
      token(/\!\=/) {|m| m}
      token(/\<\=/) {|m| m}
      token(/\>\=/) {|m| [m]}
      token(/./) {|m| m} #The rest of tokens.
      #array tokens
    #  token(/[\.size\(\)]/){|m| m}

      start :program do
        match(:multi_statements) { |statements| RunProgram.new(statements) }
      end

      rule :multi_statements do
        match(:multi_statements,',', :statement) do |statements, _ , statement|
          statements += statement
          statements
        end
        match(:multi_statements, :statement) do |statements, statement|
          statements += statement
          statements
        end
        match(:statement) { |statement| statement }
      end


      rule :statement do
        match(:return){|m| [m]}
        match(:break){|m| [m]}
        match(:if_statement){|m| [m]}
        match(:loop){|m| [m]}
        match(:print){|m| [m]}
        match(:declare_function) {|m| [m]}
        match(:call_function) {|m| [m]}
        match(:assign){|m| [m]}
        match(:expr){|m| [m]}
      end

      rule :print do
        match('print','(', :multi_statements, ')') {|_,_,a,_| Output.new(a)}

      end
      rule :assign do
        match(:var, '=', :expr) {|a, _, c| MakeVar.new(a, c)}
      end

      rule :declare_function do
        match('def', :var, '(', :parameters,')','{', :multi_statements,'}'){|_,a,_,b,_,_,c,_| Fun.new(a,b,c)}
      end

      rule :call_function do
        match(:var,'(', :parameters,')'){|a,_,b| Call_fun.new(a,b)}
      end

      rule :parameters do
        match(:expr) {|a| [a] }
        match(:parameters, ',', :var){|a,_,b| [a,b] }
        match(:parameters, ',', :digit){|a,_,b| [a,b] }
        match(:parameters, ',', :string){|a,_,b| [a,b] }
        match(:var)
      end

      rule :loop do
        match(:while_loop)
        match(:for_loop)
      end

      rule :if_statement do
        match('if', '(', :expr, ')', '{', :multi_statements, :else_statement){|_, _,a, _, _, b, c|
          If.new(a, b, c)}
      end

      rule :else_statement do
        match('}','else','{', :multi_statements, '}') {|_,_,_,c, _| c}
        match('}')
      end

      rule :while_loop do
        match('while','(',:expr,')','{', :multi_statements,'}'){|_,_,exp,_,_,stmts,_|
          While.new(exp,stmts)}
      end

      rule :for_loop do
        match('for','(', :assign, ';', :comp_expr, ';', :statement, ')',
        "{",:multi_statements, "}") {|_,_,a,_,b,_,c,_,_,d,_| For.new(a,b,c,d)}

        match('for', '(', :var, 'in', :var, ")","{", :multi_statements,"}"){|_,_,
          a,_,b,_,_,c,_| For.new(a,b,c)}
        match('for','(', :var, "in", :var, ")","{", :multi_statements,"}"){|_,_,
            a,_,b,_,_,c,_|For.new(MakeVar.new(a, ""),b,c)}


      end

      rule :expr do
        match(:list)
        match(:list_size)
        match(:list_at_index)
        match(:list_push_back)
        match(:list_push_front)
        match(:List_remove_at)
        match(:or_expr)
        match(:return)
      end

      rule :list do
        match('[',:elements,']'){|_,a,_|
          List.new(a)}
      end

      rule :elements do
        #samma tänk som statements vi smäller allting till en lista och skickar
        #upp det till Program eller List i detta fallet.
        match(:elements, ',', :factor){|a,_,b|
          a+[b]}
        match(:factor){|a|
          [a]}
      end

      rule :list_size do
        match(:var, '.', 'size', '(', ')'){|a,_,_,_,_| List_size.new(a)}
      end

      rule :list_at_index do
        match(:var, '.', 'at', '(', :digit,')') {|a,_,_,_,b,_| List_at.new(a,b)}
      end

      rule :list_push_back do
        match(:var, '.', 'push', '_', 'back', '(', :factor, ')'){|a,_,_,_,_,_,b,_|
          List_push_back.new(a,b)}
      end

      rule :list_push_front do
        match(:var, '.', 'push', '_', 'front', '(', :factor, ')'){|a,_,_,_,_,_,b,_|
          List_push_front.new(a,b)}
      end

      rule :List_remove_at do
        match(:var, '.', 'remove', '_', 'at', '(', :digit, ')'){|a,_,_,_,_,_,b,_|
          List_remove_at.new(a,b)}
      end

      rule :or_expr do
        match(:or_expr, 'or', :comp_expr){|a, b, c| Logical_obj.new(a,b,c)}
        match(:and_expr)
      end
      rule :and_expr do
        #and stuff
        match(:and_expr, 'and', :comp_expr){|a, b, c| Logical_obj.new(a,b,c)}
        match(:comp_expr)
      end

      rule :comp_expr do
        match(:comp_expr, :real_op, :a_expr) {|a,b,c| TruthStatement.new(a,b,c)}
        match(:a_expr)
      end

      rule :a_expr do
        match(:a_expr, :add_op, :term){|a,b,c| AddObj.new(a,b,c)}
        match(:term)
      end

      rule :term do
        match(:term, :multi_op, :factor){|a,b,c| MultObj.new(a,b,c)}
        match(:factor)
      end

      rule :factor do
        match('(', :expr, ')') {|_,e,_| e }
        match(:boo){|i| Boolie.new(i)}
        match(:digit)
        match(:float)
        match(:string)
        match(:identifier)
      end

      rule :boo do
        match("false")
        match("true")
      end

      rule :add_op do
        match('+')
        match('-')
      end

      rule :multi_op do
        match('*')
        match('/')
      end

      rule :mod_op do
        match('%')
      end

      rule :real_op do
        match('==')
        match('!=')
        match('>')
        match('<')
        match('>=')
        match('<=')
      end

      rule :string do
        match(/"[^\"]*"/) {|str| Strin.new(str.slice(1,str.length-2))}
        match(/'[^\']*'/) {|str| Strin.new(str.slice(1,str.length-2))}
      end

      rule :digit do
        match(Integer) {|i| Digit.new(i)}
      end

      rule :float do
        match(Float) {|f| Floats.new(f.to_f)}
      end

      rule :identifier do
        match(:var)
        match(:var, (:var or :digit))
        match(:var, :identifier)
      end

      rule :var do
        match(/^[a-zA-Z]+/) {|i| Variable.new(i)}
      end

      rule :break do
        match('break') {Break.new}
      end

      rule :return do
        match('return', :statement) {|_, ex| Return.new(ex)}
        #match('return', :expr) {|_, ex| Return.new(ex)}
      end

    end
  end


  def done(str)
    ["quit","exit","bye",""].include?(str.chomp)
  end


  def start_manually
    print "[ckaft] "
    str = gets
    if done(str) then
      puts "Bye."
    else
      result = @ckaft.parse(str)
      result.eval
      start_manually
    end
  end

  def start_with_file(file)
    result = Array.new()
    if(File.empty?(file))
      puts "----------------------------------------------------"
      puts "Your file is empty, should probably write some code!"
      puts "----------------------------------------------------"
      return nil
    end
    file = File.read(file)
    result = @ckaft.parse(file)
    #puts result
    result.eval
  end


  def log(state = true)
    if state
      @ckaft.logger.level = Logger::DEBUG
    else
      @ckaft.logger.level = Logger::WARN
    end
  end
end

b = Ckaft.new
b.log(true)
#b.start_with_file("tesfile2.ck")
if ARGV.length == 1
  filename = ARGV[0]
  p = Ckaft.new
  p.log(false)
  p.start_with_file(filename)
else
  p = Ckaft.new
  p.log(false)
  p.start_manually
end
#puts Scope.get_scope
#b.start_manually
=begin
=end
