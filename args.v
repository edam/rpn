import edam.ggetopt

@[heap]
pub struct Args {
pub mut:
	run    ?string
	files  ?[]string
	quiet  bool
	prompt string
}

const options = [
	ggetopt.text('Usage: ${ggetopt.prog()} [OPTION] [FILE]...'),
	ggetopt.text('   or: ${ggetopt.prog()} [OPTION] -c COMMAND...'),
	ggetopt.text(),
	ggetopt.text('Options:'),
	ggetopt.opt('commands', `c`)
		.help('execute command-line arguments as commands, not scripts'),
	ggetopt.opt('quiet', `q`)
		.help('do not dump the stack on exit'),
	ggetopt.opt_help(),
	ggetopt.opt_version(),
	ggetopt.text(),
	ggetopt.text('A simple Reverse Polish Notation (RPN) calculator.  ' +
		'Running ${ggetopt.prog()} without any arguments starts a REPL.  ' +
		'For a list of commands, start the REPL and type "h".'),
]

fn (mut a Args) process_arg(arg string, val ?string) ! {
	match arg {
		'help' {
			ggetopt.print_help(options, columns: 80)
			exit(0)
		}
		'version' {
			ggetopt.print_version('0.1', [
				'Simple Reverse Polish Notation (RPN) interpreter',
				'Copyright 2024 Tim Marston <tim@ed.am>',
			])
			exit(0)
		}
		'commands', 'c' {
			a.run = ''
		}
		'quiet', 'q' {
			a.quiet = true
		}
		else {}
	}
}

fn Args.from_cli() Args {
	mut args := Args{}
	rest := ggetopt.getopt_long_cli(options, args.process_arg) or { ggetopt.die_hint(err) }
	if _ := args.run {
		if rest.len < 1 {
			ggetopt.die('missing commands')
		}
		args.run = rest.join(' ')
	} else if rest.len > 0 {
		args.files = rest
	} else {
		args.prompt = ggetopt.prog()
	}
	return args
}
