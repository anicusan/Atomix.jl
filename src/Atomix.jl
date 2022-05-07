baremodule Atomix

macro atomic end
macro atomicreplace end
macro atomicswap end

struct IndexableRef{Indexable,Indices}
    data::Indexable
    indices::Indices
end

function asstorable end

# Maybe it's useful to make `pointer` customizable for those who want to
# dispatch at the level of UnsafeAtomics?
function pointer end

function gcroot end

function get end
function set! end
function modify! end
function swap! end
function replace! end

module Internal

import ..Atomix: @atomic, @atomicswap, @atomicreplace, IndexableRef
using ..Atomix

using Base.Meta: isexpr
using Base: @propagate_inbounds
using UnsafeAtomics:
    Ordering, UnsafeAtomics, monotonic, acquire, release, acq_rel, seq_cst, right

include("utils.jl")
include("accessrecorder.jl")
include("generic.jl")
include("core.jl")
include("sugar.jl")

function define_docstring()
    path = joinpath(@__DIR__, "..", "README.md")
    include_dependency(path)
    doc = read(path, String)
    doc = replace(doc, r"^```julia"m => "```jldoctest README")
    # Setting `LineNumberNode` to workaround an error from logging(?) `no method
    # matching getindex(::Nothing, ::Int64)`:
    ex = :($Base.@doc $doc Atomix)
    ex.args[2]::LineNumberNode
    ex.args[2] = LineNumberNode(1, Symbol(path))
    Base.eval(Atomix, ex)
end

end  # module Internal

const Ordering = Internal.Ordering

const acquire = Internal.acquire
const release = Internal.release
const acq_rel = Internal.acq_rel
const seq_cst = Internal.seq_cst

# Julia names
const acquire_release = acq_rel
const sequentially_consistent = seq_cst

const right = Internal.UnsafeAtomics.right

Internal.define_docstring()

end  # baremodule Atomix
