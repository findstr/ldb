# ldb
a simple lua debugger for lua5.3.0

###normal command

------

> ldb.b "filename:linenumber"

add a break point on the linenumber of the file

> ldb.d

delete all the break point

####debug command

----------

> p param

print a variable value(include local and upvalues)

> s

run the next line

> c

continue the function until it occurs break point



