# Stable Roommate Problem
First, a little a history lesson:

The Stable Roommate Problem (SRP) is descended from another matching problem, the Stable Marriage Problem (SMP), which can be summarized as follows: 

> Given a set of n men, and a set of n women where each man has ranked each woman and each woman has ranked each man, create a stable matching with one man and one woman per pair.

A *stable matching* means that there are no people, x and y, where x and y are not paired, but prefer each other to their current parter. This problem has been extensively studied as it can applied in many situations, such as matching prospective students to colleges. David Gale and Lloyd Shapely presented their findings on this problem in the 1960s, not only proving that a stable matching is always possible, but also providing an algorithm to find one. 

While examining variants of SMP in the 1970s, Donald Knuth presented the idea of SRP, removing the bipartite aspect of SMP and generalizing it to any evenly sized graph. He uses an analagous definition for stability, the only real change being that x and y are from the same set. The problem is now posed as:

> *Given a set of 2n participants, where each strictly ranks the other members of the set, create a stable matching.*

In the 1980s, Robert Irving published an algorithm to find a solution to the problem, if it exists. This is a fairly imporant departure from SMP - *a stable matching may not always be possible*. It's not difficult to construct a circumstance where this would be the ase. Let's examine two configurations of a group of friends. 

Config 1 | Config2 |
--- | --- |
![imageWorking](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png)|![imageWorking](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png)|

In the first configuration, we can see that a stable matching will be possible, despite the fact that Joey seems to be everyone's least favorite (perhaps because he doesn't share). Monica and Rachel can be paired together, placing Chandler with Joey. Even though Chandler would prefer to live with one of the girls, the women are so happy together, that neither one would be willing to swap roommates.

In the second configuration, things get a little more dicey. Again, we can see that no matter who gets paired with Joey, that person will want to swap roommates. The important part in this example comes from examining the non-Joey pair, which could be Monica/Rachel, Monica/Chandler or Rachel/Chandler. If we pair the women together, we fail to get the same level of bliss: Rachel would be happy, but Monica would actually prefer to be paired with Chandler, and she would be able to convince him to swap. If Monica and Chandler move in togeher, we would see that Chandler would actually try to pursue Rachel as a roomate, and again, would be successful in organizing a swap. That would leave trying to have Rachel and Chandler live together, which also would not work, because Rachel would want to live with Monica more and try to organize a swap. No matter what configuration we have, one of the people in the non-Joey pair will prefer Joey's partner to their own and want to swap, so a stable matching is not possible. 

Irving's work focuses on eliminating any pairings that would not permit a stable matching. If a stable matching can be found, then the algorithm will terminate with each preference list containing a single entry, where x will be the only member of y's preference list iff y is the only member of x's preference list. At any point, if a participant's preference list becomes empty, that means that a stable matching does not exist, and the algorithm terminates.

The algorithm is broken into 2 phases. The first builds on Gale and Shapley's work, performing a series of prosals. Each participant goes through its preference list, proposing to each member until it is accepted. If a proposal is rejected, then both participants remove each other from their preference lists. A participant will reject a proposal from another person if they already hold a proposal from someone higher up in their preference list. Note that proposals may be rejected in later rounds; if that happens, we simply encourage the rejected party to get back out there and continue proposing.

In the second phase, Irving uses rotations. A rotation is defined as a series pairs, (x0, x0),(xi+1, yi+1),…,(xk-1, yk-1), where:
1. all x<sub>0</sub>...x<sub>i</sub> are distinct
2. y<sub>i</sub> is first on x<sub>(i+1 mod k)</sub>’s reduced list
3. y<sub>i</sub> is second on x<sub>i</sub>’s list

To find these rotations, simply start with any member who still has multiple entries on their preference list and construct these pairings until a member is repeated; this means we've found a cycle. Then reduce the rotation, by having x<sub>i</sub> reject y<sub>(i+1 mod k)</sub>, omitting any pairs not in the cycle. This process continues until no rotations can be detected; which either results in a stable matching, or at least one member with an empty preference list.

## Pseudocode for Irving's Algorithm
<pre>
<code>
// Phase 1: Proposals
set-proposed-to := [];
for person in X 
	begin
		proposer := person;
		repeat
		proposer proposes to his next-choice;
		if not rejected
		then if next-choice in set-proposed-to
			then proposer := next-choice’s reject
			until not (next-choice in set-proposed-to);
		set-proposed-to := set-proposed-to + [next-choice]
	end 

//trim the lists (this is sometime explained as its own phase)
for each x
	y := proposal x holds
	for all z that appear after y in x's preference list
		x rejects z

//Phase 2 - Rotation and Elimination	
next := any person in X with more than 2 entries in their list
while any preference list has multiple entries and there is no empty prefence list
	i = 1
	p<sub>1</sub> := x
	while p<sub>1</sub>...p<sub>i</sub> distinct
		q<sub>i</sub> := second person in p<sub>i</sub>'s preference list
		p<sub>i+1</sub> := last person's in q<sub>i</sub>'s reduced list
		i:= i+1
	cycle := remove any pairings in the sequence that occur before the first repeated p<sub>i</sub>
	for all pairs in cycle
	q<sub>i</sub> rejects p<sub>i+1</sub><super>**</super>
		
if no empty preference list
	for each x in X
		y := first in x's preference list
		if x less than y
			output x matched with y
else
	report no matching
	
Notes:
<super>*</super>rejections are mutual, so 'x rejects y' removes y from x's prefernce list x <b>and</b> removes x from y's preference list
<super>**</super>we will need to loop around, so the final q<sub>i</sub> will reject p<sub>1</sub>
</code>
</pre>

### How Fast This Works
This algorithm scales quadratically with the number of participants; _note that some sources claim this is a linear-time algorithm, but that in relation to the input, which is essentially an n*n table._ In a very handwavey summary, you could think of it like this: In each phase, the algorithm incurs a linear amount of overhead, and continually removes entries from the table; once an entry has been removed, it is never processed again_

To fill in a little more detail:

In the first phase of the algorithm, we're reducing pairs of elements in the preference lists. For each proposal, we can determine whether a rejection should occur in constant time, and if so, then perform the mutual rejection in constant time. If a participant's proposoal is initially accepted and then later rejected, we don't start over from the top of their preference list, we merely continue from where we left off. In the worst case, we would see a high number of rejections and need have all the participants go through a high number of rejections, which would still only cost us O(n<sup>2</sup>) work.

In the second phase of the algorithm, the driving factor for the amount of work is finding and reducing the preference cycles. We know that rotations are bounded by n, since we stop once an element is repeated in the top of the table. So the two worst case scenarios would be to either have a large number of rounds (but each rotation would be small), or we would have some very large rotations (but only a limited number of rounds).

If we had the smallest rotation each time, we'd be removing pairs. So we'd have n<sup>2</sup>/2 cycles, and then c\*2 work per cycle. We'd still end up with c\*n<sup>2</sup> operations to process the entire matrix. On the other hand, if we had a large rotation each time, we would have n<sup>2</sup>/n rounds, with n\*c work to reduce the rotation each round. Again, we'd end up with an O(n<sup>2</sup>) result in this scenario.

The important part here is that the preference lists are reduced in each round AND that in order to find and reduce rotations, we only process through a small number of elements at a time. 

## Extensions and Variants
### Incomplete Preference Lists and Ties


Note: there is a more recent result that claims it can perfom this in O(n\*m) time.
### Other Related Topics
- SM with triples: researchers in Japan have shown this to be an NP-complete problem/
- Stable Marriage Problem and its variants

## Sources
