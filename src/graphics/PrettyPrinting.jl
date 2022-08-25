module PrettyPrinting

using ...Catlab
using Catlab.Theories


# # Pretty Printing
# #################


# # """ Specialize object/arrow display """
makestring(x) = string(x)

makestring(f::Hom2Expr) = "$(makename(f)):$(makename(dom(f)))=>$(makename(codom(f)))"
makestring(f::HomExpr) = "$(makename(f)):$(makename(dom(f)))->$(makename(codom(f)))"
makestring(f::AttrExpr) = "$(makename(f)):$(makename(dom(f)))->$(makename(codom(f)))"

makename(X::GATExpr) = begin
  b = IOBuffer()
  show_unicode(IOContext(b),X)
  String(take!(b))
end

# """ Create a string with separators """
makestring(iter,sep;init="") = if isempty(iter)
	string(init)
else
	mapreduce(makestring,(x,y)->x*string(sep)*y,iter)
end
makestring(dict::AbstractDict,sep;init="") = makestring(collect(dict),sep,init=init)

# """ Remove module from syntax name """
function get_syntax_name(P::Presentation)
  long_name = string(P.syntax)
  dot = findlast('.',long_name)
  isnothing(dot) ? long_name : long_name[dot+1:end]
end

function Base.show(io::IO,P::Presentation)
  syntax_name = get_syntax_name(P)
  hom2s = haskey(P.generators,:Hom2) ? P.generators.Hom2 : []
  homs = haskey(P.generators,:Hom) ? P.generators.Hom : []
  attrs = haskey(P.generators,:Attr) ? P.generators.Attr : []
  obs = haskey(P.generators,:Ob) ? P.generators.Ob : []
  eqs = ["$(makename(eq.first))==$(makename(eq.second))" for eq in P.equations]
  if !isempty(homs) || !isempty(hom2s) || !isempty(attrs)
    hom_obs = filter(x -> x isa ObExpr,vcat(generators.(homs)...))
    attr_obs = filter(x -> x isa ObExpr,vcat(generators.(attrs)...))
    hom2_obs = filter(x -> x isa ObExpr,vcat(generators.(hom2s)...))
    orphan_obs = setdiff(obs,hom_obs,attr_obs,hom2_obs)
    print(io,"$syntax_name($(makestring(vcat(orphan_obs,homs,attrs,hom2s,eqs),",")))")
  else
    gens = [ k => v for (k,v) in pairs(P.generators) if !isempty(v)]
    gen_strings = vcat(["$k => [$(makestring(v,","))]" for (k,v) in gens],eqs) 
    print(io,"$syntax_name($(makestring(gen_strings,"; ")))")
  end
end




# # # For schemas
# # # function Base.show(io::IO,P::Presentation{Catlab.Theories.ThSchema})
# # #   homs = Theories.generators(P,:Hom) ∪ Theories.generators(P,:Attr)
# # #   hom_string = makestring(homs,",")

# # #   obs = Theories.generators(P,:Ob)∪Theories.generators(P,:AttrType)
# # #   discrete_obs = setdiff(obs,Theories.dom.(homs)∪Theories.codom.(homs))
# # #   if isempty(discrete_obs)
# # #     print(io,"Schema($hom_string)")
# # #   else
# # #     ob_string = makestring(discrete_obs,",")
# # #     print(io,"Schema($ob_string,$hom_string)")
# # #   end
# # # end





end # module PrettyPrinting