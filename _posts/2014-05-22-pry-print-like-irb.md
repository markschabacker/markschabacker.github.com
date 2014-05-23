---
layout: post
title: "IRB Like Output in Pry"
---
Lately, I've been working through the excellent [Understanding Computation](http://computationbook.com/) book.  It's been fun.  However, I am using [Pry](http://pryrepl.org/) and the author's examples use IRB so my REPL output is just different enough to get on my nerves.  Luckily, Pry is extremely configurable through its `.pryrc` file.  The following `.pryrc` line will make Pry output an object's `inspect` method results, just like IRB.

```
Pry.config.print = proc { |output, value| output.puts "=> #{value.inspect}" }
```

Even better, Pry supports loading a per-directory `.pryrc` file so I can make this change in my project folder and avoid changing my settings globally.

### Default Output
```
[1] pry(main)> Add.new(
[1] pry(main)*   Multiply.new(Number.new(1), Number.new(2)),
[1] pry(main)* Multiply.new(Number.new(3), Number.new(4)) )
=> #<struct Add
 left=
  #<struct Multiply
   left=#<struct Number value=1>,
   right=#<struct Number value=2>>,
 right=
  #<struct Multiply
   left=#<struct Number value=3>,
   right=#<struct Number value=4>>>
[2] pry(main)> Number.new(5)
=> #<struct Number value=5>
```

### With `inspect` Output
```
[1] pry(main)> Add.new(
[1] pry(main)*   Multiply.new(Number.new(1), Number.new(2)),
[1] pry(main)* Multiply.new(Number.new(3), Number.new(4)) )
=> «1 * 2 + 3 * 4»
[2] pry(main)> Number.new(5)
=> «5»
```

Much better, right?
