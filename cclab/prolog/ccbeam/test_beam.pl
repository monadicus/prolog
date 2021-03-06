:- module(test_prob, []).

:- use_module(library(data/pair), [pair/3]).
:- use_module(library(ccstate),  [run_nb_state/3, app/1, run_ref/1, run_env/1, env_new/2, env_app/2, env_upd/3, env_get/2]).
:- use_module(library(lambda2)).
:- use_module(ccbeam2).

:- set_prolog_flag(back_quotes, symbol_char).


:- initialization module(test_prob), 
                  set_prolog_flag(back_quotes, symbol_char).

% ---- test programs -----
choose(Xs,X) :-
   length(Xs,N), P is 1/N,
   maplist(pair(P),Xs,Dist),
   dist(Dist,X).
dist(Ps,Xs,X) :-
   maplist(pair,Ps,Xs,PXs),
   dist(PXs,X).

test0(r(X)) :- choose([1,2,3],X).

test(Z) :-
   dist([0.2,0.5,0.3], [1,2,3],X),
   dist([0.4,0.4,0.2], [a(X),b(X),c(X)],Y),
   dist([0.1,0.5,0.4], [Y-x, Y-y, Y-z],Z1),
   dist([0.3,0.4,0.3], [Z1-u, Z1-v, Z1-w],Z).

markov(0,_,[]).
markov(N,Y,[X|Xs]) :-
   succ(M,N),
   trans(Y,X),
   markov(M,X,Xs).

hmm(_,0-_,[]).
hmm(HMM,N-Y,[X|Xs]) :-
   succ(M,N),
   trans(Y,Z),
   obs(Z,X),
   call(HMM,M-Z,Xs).

trans(_,X) :- choose([a,b],X).
obs(_,X) :- choose([x,y,z],X).

link(a,X) :- choose([b,c],X).
link(b,d).
link(c,X) :- choose([d,m],X).
link(d,X) :- choose([e,f],X).
link(e,g).
link(f,X) :- choose([g,k],X).
link(g,h).
link(h,X) :- choose([i,j],X).
link(i,_) :- fail_.
link(j,_) :- fail_.
link(k,l).
link(l,_) :- fail_.
link(m,_) :- fail_.


link(w,X) :- dist([0.75-x,0.25-y],X).
link(x,X) :- dist([0.5-v,0.5-z],X).
link(y,z).
link(z,X) :- dist([0.5-t, 0.5-u],X).
link(t,_) :- fail_.
link(u,_) :- fail_.
link(v,_) :- fail_.
% link(z,z).

bernoulli(P,X) :- NP is 1 - P, dist([NP-0,P-1],X).
id --> [].

% left and right recursive grammar
sent(S,L1,L2) :- choose([b,l,r],A), sentx(A,S,L1,L2).
sentx(b,_) --> word.
sentx(r,S) --> call(S), out(not).
sentx(l,S) --> out(really), call(S).

word --> {choose([cool,wicked],W)}, out(W).

out(_,[],_) :- !, fail_.
out(W,[X|T],T) :- W=X -> true; fail_.

% incomplete recursive form
pathr(P) --> link, {choose(['B','R'],Q)}, maybe_rec(Q,P).
pathl(P) --> {dist([0.6-'B',0.4-'R'],Q)}, maybe_rec(Q,P), link.
% pathl(P) --> link.

maybe_rec('B',_) --> [].
maybe_rec('R',P) --> call(P).

test_path(l, Start, End) :- test_path(pathl(P), P, Start, End).
test_path(r, Start, End) :- test_path(pathr(P), P, Start, End).
test_path(Inc, Complete, Start, End) :- 
   memo_prob(Inc, Complete), 
   call(Complete, Start, End).

test_left_grammar(In,Tail) :-
   memo_prob(sent(S),S),
   call(S,In,Tail).

user:portray(F) :- float(F), !, format('~3g',[F]).
