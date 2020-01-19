$functions = {}
class Scope
  def initialize
    @@scope_counter = 1
    @@scope_container = Hash.new
  end

  def Scope.get_scope
    @@scope_container
  end

  def Scope.get_counter
    @@scope_counter
  end

  def Scope.set_scope(scope_in)
    @@scope_container = scope_in
  end

  def Scope.one_down
    @@scope_counter += 1
    return @@scope_container
  end

  def Scope.one_up(scope)
    Scope.set_scope(scope)
    @@scope_counter -= 1
  end
end
#make first scope here!!
Scope.new
#----------------------------------------------------
# dont move anything over this line!

def find_var(var, hash)
  count = Scope.get_counter
  if hash == Scope.get_scope
    while(count > 0)
      if hash[count] != nil and hash[count][var] != nil
        return hash[count][var]
      end
      count -= 1
    end
    if hash[count] == nil
      return hash[var]
    end
  end
end

class RunProgram
    def initialize(statements)
      @statements = statements
    end

    def eval
      @statements.each do |statement|
        statement.eval
      end
    end
  end

class Break
  def eval
    'break'
  end
end

class Return
  def initialize(input)
    @thing = input
    end

  def eval
    if(@thing.class == Array)
      #puts @thing[-1].eval
      return @thing[0].eval
    else
     return @thing.eval
   end
   end
end

class Logical_obj
  def initialize(op_a, op, op_b)
    @op_a = op_a
    @op = op
    @op_b = op_b
  end

  def eval
    if (@op_a.class == Boolie) and (@op_b.class == Boolie)
      if @op == 'or'
        return (@op_a.value or @op_b.value)
      elsif @op == 'and'
        return (@op_a.value and @op_b.value)
      end
    elsif (@op_a.class == TruthStatement) and (@op_b.class == TruthStatement)
      if @op == 'or'
        return (@op_a.eval or @op_b.eval)
      elsif @op == 'and'
        return (@op_a.eval and @op_b.eval)
      end

    else
      puts "--------------------------------"
      puts "!Those objects do not evaluate to Boolies!"
      puts "(#{@op_a.eval.class} and #{@op_b.eval.class})"
      puts "--------------------------------"
    end
  end
end


class Fun
  def initialize(name, *params, statements)
    @name = name
    @params = params
    @stmts = statements
  end

  def eval
    if not $functions.has_key?(@name.to_s)
     $functions[@name.var] = self
    else
      puts "This is already a function"
      return nil
    end
  end

  def values
    return @name,@params,@stmts
  end
end

class Call_fun
  def initialize(function, *params)
    @f_name = function
    @args = params
  end

  def eval
    if $functions.has_key?(@f_name.var.to_s)
      func = $functions[@f_name.var.to_s]
      arg = func.values[1]
      arg = arg.flatten
      args = @args
      if args.class == Array
        args = @args.flatten
      end
      @lscope = Scope.one_down
      if arg.length == args.length
        for i in 0..(arg.length-1)
          @lscope[arg[i].var] = args[i].eval
        end
      else
        puts "Wrong number of arguments"
        return nil
      end
      sts = func.values[2]
      sts.each do |stmt|
        if stmt.class == Return
          value = stmt.eval
          puts value
          break
        else
          stmt.eval
        end
      end
      @lscope.delete(Scope.get_counter)
      Scope.one_up(@lscope)
    end
  end
end

class If
  def initialize(expr, multi_stmt, else_stmt)
    @expr = expr
    @multi_stmt = multi_stmt
    @else_stmt = else_stmt
    @lscope = Hash.new
  end

  def eval
    @lscope = Scope.one_down
    if @expr.eval
      @multi_stmt.each do |stmt|
        if(stmt.class == Return)
          value = stmt.eval
          break
        else
          stmt.eval
        end
      end
    else
      @else_stmt.each do |stmt|
        if(stmt.class == Return)
          value = stmt.eval
          return value
        else
          stmt.eval
        end
      end
    end
    @lscope.delete(Scope.get_counter)
    Scope.one_up(@lscope)
  end
end

class While
  def initialize(exp,stmts)
    @exp = exp
    @stmts = stmts
    @lscope = Hash.new
  end

  def eval
    @lscope = Scope.one_down
    not_break = false
    while @exp.eval and not_break == false do
      @stmts.each do |stmt|
        if(stmt.class == Return)
          value = stmt.eval
          puts value
          not_break = true
          break
        elsif(stmt.class == Break)
          not_break = true
          break
        else
          stmt.eval
        end
      end
    end
    @lscope.delete(Scope.get_counter)
    Scope.one_up(@lscope)
  end
end

class For
  def initialize(a, b, c, d = nil)
    @dec_var = a
    @n = a
    @tar_var = b
    @stmts = c
    @statements = d
    @lscope = Hash.new
  end

  def eval
    #puts
    @dec_var.eval
    @lscope = Scope.one_down
    if @statements == nil and @tar_var.eval.class == Strin
      stri = @tar_var.eval
      str = stri.value.gsub("\"", "").split("")
      h = @n.var
      str.each{|element|
        @stmts.prepend(MakeVar.new(Variable.new(h), Strin.new(element)))
        @stmts.each do |stmt|
          if(stmt.class == Return)
            value = stmt.eval
            puts value
            not_break = true
            break
          elsif(stmt.class == Break)
            not_break = true
            break
          else
            stmt.eval
          end
        end
        @stmts = @stmts.drop(1)
      }

    elsif @tar_var.eval.class == Array
      h = @dec_var.var
      iter = @tar_var.eval
      iter.each{|element|
        @stmts.prepend(MakeVar.new(Variable.new(h), element))
        @stmts.each do |stmt|
          if(stmt.class == Return)
            value = stmt.eval
            puts value
            not_break = true
            break
          elsif(stmt.class == Break)
            not_break = true
            break
          else
            stmt.eval
          end
        end
        @stmts = @stmts.drop(1)
      }

    else
      @dec_var.eval
      while @tar_var.eval do
        @statements.each do |stmt|
          if(stmt.class == Return)
            value = stmt.eval
            puts value
            not_break = true
            break
          elsif(stmt.class == Break)
            not_break = true
            break
          else
            stmt.eval
          end
        end
        @stmts[0].eval
      end
    end
    @lscope.delete(Scope.get_counter)
    Scope.one_up(@lscope)
    return nil
  end
end

class MakeVar
  attr_reader :name, :exp
  def initialize(name, exp, type = nil)
     @name = name
     @exp = exp
     @type = type
   end

   def eval
    value = @exp.eval

    @lscope = Scope.get_scope
    count = Scope.get_counter
    if @lscope[count] != nil
      if @lscope[count].has_key?(@name.var)
        @lscope[count][@name.var] = value
      else
        @lscope[count][@name.var] = value
        Scope.set_scope(@lscope)
      end
    else
      @lscope[count] = Hash.new
      @lscope[count][@name.var] = value
      Scope.set_scope(@lscope)
    end
   end
end

class List
  attr_accessor :list
  def initialize (list)
    @list = list
  end
  def eval()
    size = @list.size
    while(size <= 0)
      @list[size-1] = @list[size-1].eval
      --size
    end
    return @list
  end
end

class List_size
  attr_accessor :var
  def initialize (var)
    @var = var
  end

  def eval
    #find where the var is in the scope and then just take length
    #of the array that was found.
    ret = find_var(@var.var,Scope.get_scope)
    return ret.length
  end
end

class List_at
  def initialize (var,index)
    @var = var
    @index = index
  end

  def eval
    #same thing as list_size..
    ret = find_var(@var.var,Scope.get_scope)
    return ret[@index.value]
  end
end

class List_push_back
  def initialize (var,to_add)
    @var = var
    @to_add = to_add
  end

  def eval
    ret = find_var(@var.var,Scope.get_scope)
    ret.push(@to_add)
    return ret
  end
end

class List_push_front
  def initialize (var,to_add)
    @var = var
    @to_add = to_add
  end

  def eval
    ret = find_var(@var.var,Scope.get_scope)
    ret.insert(0,@to_add)
    return ret
  end
end

class List_remove_at
  def initialize (var,to_remove)
    @var = var
    @to_remove = to_remove
  end

  def eval
    ret = find_var(@var.var,Scope.get_scope)
    ret.delete_at(@to_remove.value)
    return ret
  end
end

class Output
  def initialize(obj)
    @o = obj
  end

  def eval
    out = ''
    which = 0
    @o.each do |stmt|
      if stmt.eval.respond_to? :each
        stmt.eval.each do |x|
          out += "#{x}, "
          which = 1
        end
      else
        out += "#{stmt.eval} "
      end
    end
    if which == 1
      to_out = out[0...-2]
      puts '['+to_out+']'
    else
      puts out
    end
  end
end

class Boolie
  def initialize(bool)
    if bool == "true"
      @v = true
    elsif bool == "false"
      @v = false
    end
  end

  def eval
    return self
  end

  def value
    return @v
  end

  def ==(rhs)
    return @v == rhs.eval
  end

  def !=(rhs)
    return @v != rhs.eval
  end

  def to_s
    return @v.to_s
  end

end

class ModObj
  def initialize(lhs, rhs)
    @expr_left = lhs
    @expr_right = rhs
  end
end


class AddObj
  def initialize(lhs,op,rhs)
    @expr_left = lhs
    @expr_op = op
    @expr_right = rhs
  end
  def eval
    if (@expr_right.eval.class == @expr_left.eval.class or Floats) and @expr_right.class != Boolie
      if @expr_op == '+'
        return @expr_left.eval + @expr_right.eval
      elsif @expr_op == '-'
        return @expr_left.eval - @expr_right.eval
      end
    else
      puts "--------------------------------"
      puts "!You cannot add those types!"
      puts "(#{@expr_left.eval.class} and #{@expr_right.eval.class})"
      puts "--------------------------------"
    end
  end

  def value
    return self
  end
end



class MultObj
  def initialize(lhs,op,rhs)
    @expr_left = lhs
    @expr_right = rhs
    @expr_op = op
  end

  def eval
    if @expr_op == '*'
      return @expr_left.eval * @expr_right.eval
    elsif @expr_op == '/'
      return @expr_left.eval / @expr_right.eval
    end
  end
end

class ModObj
  def initialize(lhs, op, rhs)
    @expr_left = lhs
    @expr_right = rhs
    @expr_op = op
  end

  def eval
    return @expr_left.eval % @expr_right.eval
  end
end


class TruthStatement
  def initialize(l, op, r)
    @expr_left = l
    @expr_op = op
    @expr_right = r
  end

  def eval
    if @expr_op == '=='
      return @expr_left.eval.value == @expr_right.eval.value
    elsif @expr_op == '!='
      return @expr_left.eval.value != @expr_right.eval.value
    elsif @expr_op == '>'
      return @expr_left.eval.value > @expr_right.eval.value
    elsif @expr_op == '<'
      return @expr_left.eval.value < @expr_right.eval.value
    elsif @expr_op == '>='
      return @expr_left.eval.value >= @expr_right.eval.value
    elsif @expr_op == '<='
      return @expr_left.eval.value <= @expr_right.eval.value
    end
  end
end

class Floats
  def initialize(i)
    @d_value = i
  end

  def value
    return @d_value
  end

  def +(rhs)
    return Floats.new(@d_value + rhs.eval.value)
  end

  def -(rhs)
    return Floats.new(@d_value - rhs.eval.value)
  end

  def *(rhs)
    return Floats.new(@d_value * rhs.eval.value)
  end

  def /(rhs)
    return Floats.new(@d_value / rhs.eval.value)
  end

  def %(rhs)
    return Floats.new(@d_value % rhs.eval.value)
  end

  def eval
    return self
  end

  def to_s
    return @d_value.to_s
  end
end

class Digit
  def initialize(i)
    @d_value = i
  end

  def value
    return @d_value
  end

  def +(rhs)
    return Digit.new(@d_value + rhs.eval.value)
  end

  def -(rhs)
    return Digit.new(@d_value - rhs.eval.value)
  end

  def *(rhs)
    return Digit.new(@d_value * rhs.eval.value)
  end

  def /(rhs)
    return Digit.new(@d_value / rhs.eval.value)
  end

  def %(rhs)
    return Digit.new(@d_value % rhs.eval.value)
  end

  def eval
    return self
  end

  def to_s
    return @d_value.to_s
  end
end


class Strin
  def initialize(s)
    @str = s
  end

  def value
    return @str
  end

  def eval
    return self
  end

  def +(rhs)
    return Strin.new("'" + (@str + rhs.value).gsub("\'","")+ "'")
  end

  def to_s
    str = @str.gsub("\"","")
    return str
  end
end

class Variable
  attr_reader :var
  def initialize(var)
    @var = var
  end

  def eval
    count = Scope.get_counter
    return find_var(@var, Scope.get_scope)
  end

end
