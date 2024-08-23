module main

import os

fn main() {
	args := Args.from_cli()

	mut app := App.new()!

	mut cont, mut err := true, false
	if line := args.run {
		cont, err = app.run(line)
	} else if files := args.files {
		all: for file in files {
			lines := os.read_lines(file) or {
				println(err.msg())
				exit(1)
			}
			for i := 0; i < lines.len; i++ {
				cont, err = app.run(lines[i])
				if err {
					println('in ${file}:${i}')
				}
				if !cont {
					break all
				}
			}
		}
	} else {
		app.repl('${args.prompt}> ')!
		cont = false
	}

	if cont && !args.quiet {
		app.print_stack()!
	}

	exit(if err { 1 } else { 0 })
}
