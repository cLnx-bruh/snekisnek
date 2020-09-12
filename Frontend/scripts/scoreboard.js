(async function () {
    const scoreboard = document.querySelector(".scoreboard");

    function createScoreItem(playerScore) {
        const name = document.createElement("span");
        name.classList.add("name");
        name.innerText = playerScore.name;

        const score = document.createElement("span");
        score.classList.add("score");
        score.innerText = playerScore.score;

        const scoreItem = document.createElement("li");
        scoreItem.classList.add("scoreItem");
        scoreItem.appendChild(name);
        scoreItem.append(":");
        scoreItem.appendChild(score);

        return scoreItem;
    }

    async function getPlayerScores() {
        const response = await fetch('http://localhost:3000/api/scores/');
        return response.json();
    }

    const playerScores = await getPlayerScores();
    const scoreItems = playerScores.map(playerScore => createScoreItem(playerScore));

    scoreItems.forEach(scoreItem => {
        scoreboard.appendChild(scoreItem);
    });

})();
