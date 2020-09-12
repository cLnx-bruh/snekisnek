(function () {
    const cvs = document.querySelector(".snake");
    const ctx = cvs.getContext("2d");

    // create the unit
    const box = 32;

    // load images
    const ground = new Image();
    ground.src = "img/ground.png";

    const foodImg = new Image();
    foodImg.src = "img/food.png";

    const head = new Image();
    head.src = "img/head.png";

    const tailO = new Image();
    tailO.src = "img/tailO.png";

    const tailL = new Image();
    tailL.src = "img/tailL.png";

    const tailV = new Image();
    tailV.src = "img/tailV.png";

    const snakeParts = {
        0: head,
        3: tailL,
        6: tailV
    }

    // load audio files
    const dead = new Audio();
    dead.src = "audio/dead.mp3";

    const eat = new Audio();
    eat.src = "audio/eat.mp3";

    const up = new Audio();
    up.src = "audio/up.mp3";

    const right = new Audio();
    right.src = "audio/right.mp3";

    const left = new Audio();
    left.src = "audio/left.mp3";

    const down = new Audio();
    down.src = "audio/down.mp3";

    // create the snake
    let snake = [];

    snake[0] = {
        x : 9 * box,
        y : 10 * box
    };

    // create the food
    let food = {
        x : Math.floor(Math.random()*17+1) * box,
        y : Math.floor(Math.random()*15+3) * box
    }

    let score = 0;
    let playerName = "";

    //control the snake
    let direction;

    document.addEventListener("keydown",keyDownHandler);

    function keyDownHandler(event){
        let key = event.keyCode;
        if( key == 37 && direction != "RIGHT"){
            left.play();
            direction = "LEFT";
        }else if(key == 38 && direction != "DOWN"){
            direction = "UP";
            up.play();
        }else if(key == 39 && direction != "LEFT"){
            direction = "RIGHT";
            right.play();
        }else if(key == 40 && direction != "UP"){
            direction = "DOWN";
            down.play();
        }
    }

    // cheack collision function
    function collision(head,array){
        for(let i = 0; i < array.length; i++){
            if(head.x == array[i].x && head.y == array[i].y){
                return true;
            }
        }
        return false;
    }

    // draw everything to the canvas
    function draw(){
        
        ctx.drawImage(ground,0,0);
        
        for( let i = 0; i < snake.length ; i++){
            const image = snakeParts[i];
            if (image) {
                ctx.drawImage(image, snake[i].x, snake[i].y);
            } else {
                ctx.drawImage(tailO, snake[i].x, snake[i].y);
            }
        }
        
        ctx.drawImage(foodImg, food.x, food.y);
        
        // old head position
        let snakeX = snake[0].x;
        let snakeY = snake[0].y;
        
        // which direction
        if( direction == "LEFT") snakeX -= box;
        if( direction == "UP") snakeY -= box;
        if( direction == "RIGHT") snakeX += box;
        if( direction == "DOWN") snakeY += box;
        
        // if the snake eats the food
        if(snakeX == food.x && snakeY == food.y){
            score++;
            eat.play();
            food = {
                x : Math.floor(Math.random()*17+1) * box,
                y : Math.floor(Math.random()*15+3) * box
            }
            // we don't remove the tail
        }else{
            // remove the tail
            snake.pop();
        }
        
        // add new Head
        
        let newHead = {
            x : snakeX,
            y : snakeY
        }
        
        // game over
        if(snakeX < box || snakeX > 17 * box || snakeY < 3*box || snakeY > 17*box || collision(newHead,snake)){
            clearInterval(game);
            dead.play();
            // timeout so we don't block the last draw call
            const timeout = setTimeout(() => {
                clearTimeout(timeout);
                const playerName = prompt(`You scored ${score}. Would you like to save it in the leaderboard?`);
                if ((playerName) && playerName.trim() !== "") {
                    fetch('http://localhost:3000/api/scores/', {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json"
                        },
                        body: JSON.stringify({name: playerName, score: score})
                    }).then(resposne => location.reload());
                } else {
                    location.reload();
                }
            }, 0);
        }
        
        snake.unshift(newHead);
        
        ctx.fillStyle = "white";
        ctx.font = "45px Changa one";
        ctx.fillText(score,2*box,1.6*box);
    }

    // call draw function every 100 ms
    let game = setInterval(draw, 100);
})();
















