import vinescore_irc

let vScore = newVineScore("#unused")

assert vScore.currentScore == 0

assert true == vScore.add(1)
assert vScore.currentScore == 1
assert true == vScore.add(-1)
assert vScore.currentScore == 0
assert false == vScore.add(-1000)
assert vScore.currentScore == 0
assert false == vScore.add(1000)
assert vScore.currentScore == 0
