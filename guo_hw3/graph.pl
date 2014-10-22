% graph G = (V, E) where V = {k, m, p, q} and E is defined below.
arc(m,p,8).
arc(q,p,11).
arc(q,m,5).
arc(k,q,3).


% graph G = (V, E) where V = {a, b, c, d, e, f}
% and E is defined below. Note that there is a
% loop f->c, c->f in G.
arc(a,b,7).
arc(a,c,9).
arc(a,f,14).
arc(b,c,10).
arc(b,d,15).
arc(c,d,11).
arc(c,f,2).
arc(d,e,6).
arc(f,c,2).
arc(f,e,9).
