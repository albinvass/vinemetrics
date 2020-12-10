import vinescore_irc

let vScore = newVineScore("#unused")

assert vScore.currentScore == 0

vScore.add(1)
assert vScore.currentScore == 1
vScore.add(-1)
assert vScore.currentScore == 0
vScore.add(-1000)
assert vScore.currentScore == 0
vScore.add(1000)
assert vScore.currentScore == 0
