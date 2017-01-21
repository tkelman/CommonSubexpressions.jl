using Base.Test
using CombinedSubexpressions

@testset "basic usage" begin
    f_count = 0
    function f(x)
        f_count += 1
        1
    end

    g_count = 0
    function g(x)
        g_count += 1
        2
    end

    @test f_count == 0
    @test g_count == 0

    x = 1
    @cse [f(g(x)) for i in 1:10]
    @test f_count == 1
    @test g_count == 1

    f_count = 0
    g_count = 0
    [f(g(x)) for i in 1:10]
    @test f_count == 10
    @test g_count == 10

    h_count = 0
    function h(x, y)
        h_count += 1
        3
    end

    @cse function foo(x)
        [h(h(f(g(x)), g(x)), i) == i for i in 1:5]
    end
    f_count = 0
    g_count = 0
    h_count = 0
    @test foo(1) == [false, false, true, false, false]
    @test f_count == 1
    @test g_count == 1
    @test h_count == 6
end

@testset "function definition" begin
    f_count = 0
    function f(x)
        f_count += 1
        1
    end

    @cse function foo(x)
        [f(x) == i for i in 1:5]
    end

    @test foo(1) == [true, false, false, false, false]
    @test f_count == 1
end

@testset "algebra" begin
    H = [1 2; 3 4]
    W = [2 3; 4 5]
    G = [4 5; 6 7]

    @test (@cse inv(H) * G + W * (inv(H) + W)) == begin
        invH = inv(H)
        invH * G + W * (inv(H) + W)
    end
end

@testset "dict" begin
    @test (@cse begin
        x = Dict("foo" => sin(pi), "bar" => 2 + 2)
        x["bar"] = 100
        x["foo"], x["bar"]
    end) == begin
        x = Dict("foo" => sin(pi), "bar" => 2 + 2)
        x["bar"] = 100
        x["foo"], x["bar"]
    end
end
