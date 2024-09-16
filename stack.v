struct Stack {
mut:
	head &Node = unsafe { nil }
	tail &Node = unsafe { nil }
	pool &Node = unsafe { nil }
}

@[heap]
struct Node {
mut:
	next &Node = unsafe { nil }
	val  Value
}

fn (mut s Stack) push(val Value) {
	unsafe {
		if s.pool == nil {
			s.head = &Node{
				next: s.head
				val:  val
			}
		} else {
			this := s.pool
			s.pool = this.next
			this.next = s.head
			s.head = this
			this.val = val
		}
		if s.tail == nil {
			s.tail = s.head
		}
	}
}

fn (mut s Stack) pop() !Value {
	val := s.head()!
	unsafe {
		this := s.head
		s.head = this.next
		this.next = s.pool
		s.pool = this
		if s.head == nil {
			s.tail = nil
		}
	}
	return val
}

fn (mut s Stack) swap() ! {
	val1 := s.pop()!
	val2 := s.pop()!
	s.push(val1)
	s.push(val2)
}

fn (mut s Stack) head() !Value {
	unsafe {
		if s.head == nil {
			return error('stack empty')
		} else {
			return s.head.val
		}
	}
}

fn (mut s Stack) purge() {
	unsafe {
		if s.head != nil {
			s.tail.next = s.pool
			s.pool = s.head
			s.head = nil
			s.tail = nil
		}
	}
}

fn (s Stack) len() u64 {
	mut len := u64(0)
	unsafe {
		for node := s.head; node != nil; node = node.next {
			len++
		}
	}
	return len
}

fn (s Stack) pool_len() u64 {
	mut len := u64(0)
	unsafe {
		for node := s.pool; node != nil; node = node.next {
			len++
		}
	}
	return len
}
