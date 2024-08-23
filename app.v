module main

import edam.greadline
import os
import prantlf.pcre2

const rcfile = os.join_path(os.home_dir(), '.calcrc')

struct App {
	args  &Args = unsafe { nil }
	tokre pcre2.RegEx
mut:
	stack Stack
	debug bool
}

fn App.new() !&App {
	return &App{
		tokre: pcre2.pcre2_compile(r'\s*(' + //
		 r'[-+]?(?:[0-9]*\.)?[0-9]+(?:e[-+]?[0-9]+)?|' + // number
		 r'"(?:\\.|[^"])*"|' + // string
		 r'nil|' + // nil
		 r'[^"]' + // any other single char (including commands)
		 r')\s*', pcre2.opt_caseless | pcre2.opt_utf)!
	}
}

fn (mut app App) repl(prompt string) ! {
	greadline.history_file_read(rcfile)!
	greadline.set_history_file_limit(1000)!
	defer {
		greadline.history_file_write() or { println('greadline: ${err}') }
	}

	println("type 'h' for help")
	repl: for {
		line := greadline.readline(prompt) or { return }
		app.repl_exec(line) or {
			app.exec_line(line) or {
				if err.msg() == '' {
					return
				}
				println('${err.msg()}')
			}
		}
	}
}

fn (mut app App) repl_exec(line string) ! {
	match line.trim(' ') {
		'h' { app.print_help() }
		'D' { app.debug_info() }
		else { return error('') }
	}
}

fn (mut app App) run(line string) (bool, bool) {
	app.exec_line(line) or {
		if err.msg() == '' {
			return false, false
		} else {
			println('${err.msg()}')
			return false, true
		}
	}
	return true, false
}

struct Tok {
	off int
	len int
}

fn (mut app App) exec_line(line string) ! {
	mut toks := []Tok{}
	for pos := 0; pos < line.len; {
		next, part := app.next_token(line, pos)!
		if part == '#' {
			break
		}
		toks << Tok{pos, part.len}
		pos = next
	}
	for tok in toks {
		app.exec(line[tok.off..tok.off + tok.len]) or {
			if err.str() == 'quit' {
				return error('')
			}
			return Err{
				msg: err.str()
				inp: line
				off: tok.off
			}
		}
	}
}

struct Err {
	msg string
	inp string
	off int
}

fn (e Err) msg() string {
	return '${e.msg}: ' + e.inp + '\n' + ` `.repeat(e.msg.len + 2 + e.off) + '^'
}

fn (e Err) code() int {
	return 0
}

fn (mut app App) next_token(inp string, off int) !(int, string) {
	if app.debug {
		println('scan at ${off} in [${inp}]')
	}
	m := app.tokre.exec_within(inp, u32(off), inp.len, 0) or {
		return Err{
			msg: 'syntax error'
			inp: inp
			off: off
		}
	}
	defer {
		m.free()
	}
	_, end := m.group_bounds(0) or { 0, 0 }
	if app.debug {
		println('tok [${m.group_text(inp, 1)}], next ${end}')
	}
	return end, m.group_text(inp, 1)!
}

fn (mut app App) exec(inp string) ! {
	match inp {
		'd' { app.print_stack()! }
		'p' { println(app.stack.pop()!.disp()) }
		'P' { println(app.stack.pop()!.str()) }
		't' { println(app.stack.head()!.typ()) }
		'e' { app.exec(app.stack.pop()!.str())! }
		'x' { app.stack.purge() }
		'+' { app.stack.push(app.stack.pop()!.add(app.stack.pop()!)!) }
		'-' { app.stack.push(app.stack.pop()!.sub(app.stack.pop()!)!) }
		'*' { app.stack.push(app.stack.pop()!.mul(app.stack.pop()!)!) }
		'/' { app.stack.push(app.stack.pop()!.div(app.stack.pop()!)!) }
		'!' { app.stack.push(app.stack.pop()!.neg()!) }
		'.' { app.stack.push(app.stack.head()!) }
		'_' { app.stack.pop()! }
		'q' { return error('quit') }
		else { app.stack.push(Value.parse(inp) or { return error('bad command') }) }
	}
}

fn (mut app App) print_help() {
	println('Commands:')
	println('  d  dump stack')
	println('  p  pop and print top of stack ("P" displays raw values)')
	println('  t  print type of top of stack')
	println('  +  add last two stack values, push result to stack')
	println('  -  subtract last stack values from the one before, push result to stack')
	println('  *  multiply last two stack values, push result to stack')
	println('  /  divide last stack value by the one before, push result to stack')
	println('  !  negate value at top of stack (0=false)')
	println('  .  duplicate top of stack')
	println('  _  pop and discard top of stack')
	println('  e  pop and execute top of stack')
	println('  x  clear stack')
	println('  q  quit')
	println('All other values are pushed to stack as integers, floats, strings or nil.')
}

fn (mut app App) debug_info() {
	println('stack ${app.stack.len()} (pool ${app.stack.pool_len()})')
	app.debug = !app.debug
	println('print debug [${if app.debug { 'on' } else { 'off' }}]')
}

fn (mut app App) print_stack() ! {
	mut printed := false
	unsafe {
		for node := app.stack.head; node != nil; node = node.next {
			if printed {
				print(' ')
			} else {
				printed = true
			}
			print(node.val.disp())
		}
	}
	if printed {
		println('')
	}
}
