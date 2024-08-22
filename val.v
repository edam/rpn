import strings
import strconv

type Value = Nil | f64 | i64 | string

struct Nil {}

fn Value.parse(input string) !Value {
	if v := strconv.common_parse_int(input, 0, 64, true, true) {
		return v // i64
	} else if v := strconv.atof64(input) {
		return v // f64
	} else if input == 'nil' {
		return Nil{}
	} else {
		quote := input[0..1]
		if input.len >= 2 && quote in ['"', "'"] && input#[-1..] == quote {
			mut str := []rune{}
			mut esc := false
			for ch in input#[1..-1].runes() {
				if esc {
					match ch {
						`n` { str << `\n` }
						`t` { str << `\t` }
						`r` { str << `\r` }
						else { str << ch }
					}
					esc = false
				} else if ch == `\\` {
					esc = true
				} else {
					str << ch
				}
			}
			if !esc {
				return str.string()
			}
		}
	}
	return error('invalid input')
}

fn (v Value) disp() string {
	return match v {
		string { '"' + v.replace('\\', '\\\\').replace('"', '\\"') + '"' }
		i64, f64 { v.str() }
		Nil { 'nil' }
	}
}

fn (v Value) str() string {
	return match v {
		string { v }
		i64, f64 { v.str() }
		Nil { '' }
	}
}

fn (v Value) i64() i64 {
	return match v {
		string { v.i64() }
		i64 { v }
		f64 { i64(v) }
		Nil { 0 }
	}
}

fn (v Value) f64() f64 {
	return match v {
		string { v.f64() }
		i64 { f64(v) }
		f64 { v }
		Nil { 0 }
	}
}

fn (v Value) typ() string {
	return match v {
		string { 'string' }
		i64 { 'integer' }
		f64 { 'float' }
		Nil { 'nil' }
	}
}

fn (v Value) add(o Value) !Value {
	match true {
		v is Nil, o is Nil { return Nil{} }
		v is string, o is string { return v.str() + o.str() }
		v is f64, o is f64 { return v.f64() + o.f64() }
		else { return v.i64() + o.i64() }
	}
}

fn (v Value) sub(o Value) !Value {
	match true {
		v is Nil, o is Nil { return Nil{} }
		v is string, o is string { return error('bad type: ${v.typ()}') }
		v is f64, o is f64 { return v.f64() - o.f64() }
		else { return v.i64() - o.i64() }
	}
}

fn (v Value) mul(o Value) !Value {
	match true {
		v is Nil, o is Nil {
			return Nil{}
		}
		v is string {
			match o {
				i64 { return strings.repeat_string(v as string, int(o)) }
				else { return error('bad type: ${v.typ()}') }
			}
		}
		v is f64, o is f64 {
			return v.f64() * o.f64()
		}
		else {
			return v.i64() * o.i64()
		}
	}
}

fn (v Value) div(o Value) !Value {
	match true {
		v is Nil, o is Nil { return Nil{} }
		v is string, o is string { return error('bad type: ${v.typ()}') }
		v is f64, o is f64 { return v.f64() / o.f64() }
		else { return v.i64() / o.i64() }
	}
}

fn (v Value) neg() !Value {
	match v {
		Nil {
			return Nil{}
		}
		string, f64 {
			return error('bad type: ${Value(v).typ()}')
		}
		i64 {
			// bug: fails to cast int to Value: if v == 0 { 1 } else { 0 }
			return if v == 0 { i64(1) } else { 0 }
		}
	}
}
