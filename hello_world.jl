n = 5
println(n^5)

# LOOPS
while n < 10
    println("$n is such a nice number")
    global n += 1
end

friends = ["Nastya", "Vanya", "Zhenya"]

for friend in friends
    println("Hello $friend")
end

A = zeros(5,5)
println(A)

for i in 1:5, j in 1:5
    A[i,j] = i+j
end
println(A)

# array comprehension
C = [i+j for i in 1:5, j in 1:5]
display(C)

for n in 1:10
    C = [i+j for i in 1:n, j in 1:n]
    display(C)
end

# CONDITIONS
#=
if *condiiton1*
    *option1*
elseif *condition2*
    *option2*
else
    *option3*
end

a ? b : c equals
if a
    b
else
    c
end

execute b only if a is true:
a && b
else julia returns false
=#


# FUNCTIONS
function sayhi(person)
    println("Hi $person")
end
sayhi("Rob")

function square_num(number)
    number^2
end
display(square_num(5))

# One-liner option
sayhi(person) = println("Hi $person")
sayhi("Rob")

square_num(number) = number^2
display(square_num(5))

# Anonymous (lambda) functions
# and why is it so special?
 sayhi3 = person -> println("Hi $person")
 sayhi("Rob")
 # square_num = number -> number^2
 # display(quare_num(5))

# Julia functions work on whatever inputs make sense
# Duck-typing: "If it quacks like a duck, it's a duck"
A = rand(3,3)
display(square_num(A)) # square of matrix is defined

v = rand(3)
# display(square_num(v)) # square of vector is not defined

# Mutating vs non-mutating functions
#=
Functions followed by ! alter their contents and functions lacking ! do not
Example: sort! vs sort
=#

v = [3,2,1]

sort(v)
display(v)

sort!(v)
display(v)

# Broadcasting
#=
By placing . between any function name and its argument list,
we tell that function to broadcast over the elements of the input objects
f. is broadcasting
f is not broadcasting
Broadcasting: array is treated as disected into elements
=#

display(A)
display(square_num.(A))
display(square_num(A))

display(v)
display(square_num.(v)) # works since the function becomes broadcasting


# PACKAGES
# Julia has over 2000 registered packages, making packages a huge part of the Julia
# ecosystem.
#
# Even so, the package ecosystem still has some growing to do. Notably, we have first class
# function calls  to other languages, providing excellent foreign function interfaces. We
# can easily call into python or R, for example, with `PyCall` or `Rcall`.
#
# This means that you don't have to wait until the Julia ecosystem is fully mature, and that
# moving to Julia doesn't mean you have to give up your favorite package/library from
# another language!
#
# To see all available packages, check out
#
# https://pkg.julialang.org/
# or
# https://juliaobserver.com/
#
# For now, let's learn how to use a package.

# the first time you use a package on a given Julia installation,
# you need to explicitly add it:
# Pkg.add("Example")

# every time you use Julia, you load the package with the using keyword
using Example

display(hello("it's me. I was wondering if after all these years you'd like to meet."))

# Pkg.add("Colors")
using Colors

palette = distinguishable_colors(100) # palette of 100 different colors

rand(palette, 3,3)


# PLOTTING
# one may use PyPlot
# Pkg.add("Plots")
using Plots

x = -3:0.1:3
y = square_num.(x)

# with GR backend
gr()
plot(x, y, label="line")
scatter!(x,y, label="points") # use ! since the plot has already been created
xlabel!("x")
ylabel!("y")
title!("function plot")

# only scatter here
plot(x, y, label="line")
scatter(x,y, label="points")

# with plotlyjs backend
# using ORCA # needed for plotlyjs()
# plotlyjs()
# plot(x, y, label="line")
# scatter!(x,y, label="points")


# MULTIPLE DISPATCH
#=
This is a key feature of Julia!
Multiple dispatches make software:
- fast
- extensible
- programmable
- fun to play with
=#

# to understand and illustrate multiple dispath in Julia,
# let's take a look at + operator

# by calling methods(+) you can see the definition of + operator
display(methods(+))

# we can use @which macro to learn which method
# we are using when calling +
# we can see different methods below
println(@which 3+3)
println(@which 3.0 + 3.0)
println(@which 3 + 3.0)

# we can extend + by defining new methods for it
# first we need to import + from Base
import Base: +

# let's say we want to be able to
# concatenate strings using +
# w/o extension this does not work!
# println("hello" + "world")
# println(@which "hello" + "world")

# so we add a method for +
# that takes two strings as inputs
# and concatenates them

+(x::String, y::String) = string(x,y)
println("hello" + "world")
println(@which "hello" + "world")
# it works!

# another example: foo
foo(x,y) = println("duck-typed foo!") # generic version
foo(x::Int, y::Float64) = println("foo with an integer and a float!")
foo(x::Float64, y::Float64) = println("foo with two floats!")
foo(x::Int, y::Int) = println("foo with two integers!")

foo(1,1)
foo(1., 1.)
foo(1, 1.0)
foo("cat", false) # for generic version


# JULIA IS FAST!

# let's benchmark sum function in Julia, C and Python

# Julia has a BenchmarkTools package for easy and accurate benchmarking
# runs the code multiple times and averages the runtime
Pkg.add("BenchmarkTools")
using BenchmarkTools

a = rand(10^7)
display(sum(a))
# 1. C language
# C is often considered the gold standard:
# difficult for the human, nice for the machine

# 2. Python
# Pkg.add("PyCall")
using PyCall

#=
call a low-level PyCall function
to get a Python list,
because by default PyCall will
convert to a NumPy array instead
=#
# apy_list = PyCall.array2py(a,1,1)

pysum = pybuiltin("sum")
println(pysum(a))
display(pysum(a) ≈ sum(a))

# py_list_bench = @benchmark $pysum($apy_list)

# 3. Python numpy
# numpy is an optimized C library,
# callable from Python
# Pkg.add("Conda")
using Conda
# Conda.add("numpy")

numpy_sum = pyimport("numpy")."sum"
apy_numpy = PyObject(a) # convert to numpy array

py_numpy_bench = @benchmark $numpy_sum($apy_numpy)
display(py_numpy_bench)

display(numpy_sum(apy_numpy))
display(numpy_sum(apy_numpy) ≈ sum(a))

# numpy is a lot faster than Python version
# and is faster than C function


# Julia
j_bench = @benchmark sum($a)
display(j_bench)

# Julia function is faster than Python numpy and C

# Julia hand-written function is faster
# than Python built in (more than 10 times!)

# BASIC LINEAR ALGEBRA
A = rand(1:4, 3,3) # random matrix with values from 1:4
display(A)

B = A # B refers to the same place in the memory
C = copy(A)
display([B C])

A[1] = 17
display([B C]) # B changed, C did not

x = ones(3)

# multiplication
b = A*x
display(b)

# transpose
display(A') # conjugate transpose
display(transpose(A)) # just the transpose

display(A + A')

# Julia allows to write matrix transpose multiplication without *
display(A'A)

# solving linear systems
# Ax = b for square A
display(A\b)

# overdetermined systems
# when A is tall the \ function calculates the least squares solution!
# keep all roows and only first 2 columns
Atall = A[:,1:2]
display(Atall)
display(Atall\b)

# the \ function also works for
# rank deficient LS problems
# in this case, the LS solution
# is not unique and Julia returns the solution
# with the smallest norm
A = randn(3,3)
# outer product of a vector results in a singual matrix!
display([A[:,1] A[:,1]]\b)

# underdetermined systems
# when A is short the \ function resturns the minimum norm solution
Ashort = A[1:2,:]
display(Ashort)
display(Ashort\(b[1:2]))


# FACTORIZATIONS
