(async function () {
    const scoreboard = document.querySelector(".scoreboard");

    function createScoreItem(playerScore, order) {
        const orderElement = document.createElement("span");
        orderElement.classList.add("order");
        orderElement.innerText = `${order}. `;

        const name = document.createElement("span");
        name.classList.add("name");
        name.innerText = playerScore.name;

        const score = document.createElement("span");
        score.classList.add("score");
        score.innerText = playerScore.score;

        const scoreItem = document.createElement("li");
        scoreItem.classList.add("scoreItem");
        scoreItem.appendChild(orderElement);
        scoreItem.appendChild(name);
        scoreItem.append(":");
        scoreItem.appendChild(score);

        return scoreItem;
    }

    async function getPlayerScores() {
        const response = await fetch(`https://${env.BACKEND_DOMAIN}/`);
        return response.json();
    }

    const playerScores = await getPlayerScores();
    const scoreItems = playerScores.map((playerScore, index) => createScoreItem(playerScore, index + 1));

    scoreItems.forEach(scoreItem => {
        scoreboard.appendChild(scoreItem);
    });

})();
