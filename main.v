module main

import os

fn main() {
	args, rest := Args.from_cli()
	mut app := App.new()!
	if args.run {
		if !app.run(rest.join(' ')) {
			app.stack.purge()
		}
	} else if rest.len > 0 {
		all: for file in rest {
			lines := os.read_lines(file)!
			for i := 0; i < lines.len; i++ {
				if !app.run(lines[i]) {
					// can't display this, because it displays on quit!
					// TODO: handle quit better than silent error...
					// println('in ${file}:${i + 1}')
					app.stack.purge()
					break all
				}
			}
		}
	} else {
		app.repl('${args.prompt}> ')!
		app.stack.purge()
	}
	if args.quiet {
		app.stack.purge()
	}
	app.print_stack()!

	// TODO exit code
}
