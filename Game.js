const outerBox = document.querySelectorAll('.outer-box');
const resultBoard = document.querySelector('.result-board');
const resetButton = document.querySelector('.reset-button');

const selectedColor = 'rgb(89, 89, 155)';
const defaultColor = 'rgb(2, 2, 48)';
let turn_o = true;
let selectedOuterBoxIndex = null;
let freeMove = false;

const winningPatterns = [
    [0,1,2],[3,4,5],[6,7,8],
    [0,3,6],[1,4,7],[2,5,8],
    [0,4,8],[2,4,6]
];

function saveGameState() {
    const gameState = {
        outerBox: Array.from(outerBox).map(oBox => ({
            innerHTML: oBox.innerHTML,
            backgroundColor: oBox.style.backgroundColor,
            transform: oBox.style.transform
        })),
        turn_o,
        selectedOuterBoxIndex,
        freeMove,
        resultBoard: resultBoard.innerHTML
    };
    localStorage.setItem('ticTacToeGameState', JSON.stringify(gameState));
}

function loadGameState() {
    const gameState = JSON.parse(localStorage.getItem('ticTacToeGameState'));
    if (gameState) {
        gameState.outerBox.forEach((boxState, index) => {
            outerBox[index].innerHTML = boxState.innerHTML;
            outerBox[index].style.backgroundColor = boxState.backgroundColor;
            outerBox[index].style.transform = boxState.transform;
        });
        turn_o = gameState.turn_o;
        selectedOuterBoxIndex = gameState.selectedOuterBoxIndex;
        freeMove = gameState.freeMove;
        resultBoard.innerHTML = gameState.resultBoard;
    }
}

function innerBoxWinCheck(innerBox, oIndex) {
    winningPatterns.forEach((pattern) => {
        const box1 = innerBox[pattern[0]].innerHTML;
        const box2 = innerBox[pattern[1]].innerHTML;
        const box3 = innerBox[pattern[2]].innerHTML;

        if (box1 !== '' && box1 === box2 && box2 === box3) {
            innerBox.forEach((iBox) => {
                iBox.style.pointerEvents = 'none';
            });

            innerBox[pattern[0]].style.backgroundColor = 'green';
            innerBox[pattern[1]].style.backgroundColor = 'green';
            innerBox[pattern[2]].style.backgroundColor = 'green';

            setTimeout(() => {
                outerBox[oIndex].innerHTML = box1;
                outerBoxWinCheck();
                saveGameState();
            }, 500);
        }
    });
}

function drawCheck(innerBox, oIndex) {
    if (Array.from(innerBox).every(box => box.innerHTML !== '')) {
        outerBox[oIndex].innerHTML = '⦻';
        outerBox[oIndex].style.backgroundColor = 'gray';
        outerBox[oIndex].style.color = 'red';
        saveGameState();
    }
}

function updateFreeMove() {
    if (selectedOuterBoxIndex === null || oBoxFilled(outerBox[selectedOuterBoxIndex])) {
        freeMove = true;
        resultBoard.innerHTML = 'Free Move!';
    } else {
        freeMove = false;
        resultBoard.innerHTML = '';
    }
    saveGameState();
}

function outerBoxWinCheck() {
    winningPatterns.forEach((pattern) => {
        const box1 = outerBox[pattern[0]].innerHTML;
        const box2 = outerBox[pattern[1]].innerHTML;
        const box3 = outerBox[pattern[2]].innerHTML;

        if ((box1 === '⭘' || box1 === '✘') && box1 === box2 && box2 === box3) {
            outerBox[pattern[0]].style.backgroundColor = 'green';
            outerBox[pattern[1]].style.backgroundColor = 'green';
            outerBox[pattern[2]].style.backgroundColor = 'green';
            resultBoard.innerHTML = `${box1} wins`;
            saveGameState();
        }
    });
}

resetButton.addEventListener('click', () => {
    outerBox.forEach((oBox) => {
        oBox.innerHTML = `
            <div class="small-grid-game">
              <div class="inner-box"></div>
              <div class="inner-box"></div>
              <div class="inner-box"></div>
              <div class="inner-box"></div>
              <div class="inner-box"></div>
              <div class="inner-box"></div>
              <div class="inner-box"></div>
              <div class="inner-box"></div>
              <div class="inner-box"></div>
            </div>
        `;
        oBox.style.backgroundColor = defaultColor;
        oBox.style.transform = 'scale(1)';
    });
    turn_o = true;
    resultBoard.innerHTML = '';
    selectedOuterBoxIndex = null;
    freeMove = false;
    localStorage.removeItem('ticTacToeGameState');
    Game();
});

function oBoxFilled(oBox) {
    return (oBox.innerHTML === '✘' || oBox.innerHTML === '⭘' || oBox.innerHTML === '⦻');
}

function Game() {
    outerBox.forEach((oBox, oIndex) => {
        const innerBox = oBox.querySelectorAll('.inner-box');
        innerBox.forEach((iBox, iIndex) => {
            iBox.addEventListener('click', () => {
                if (!freeMove && selectedOuterBoxIndex !== null && selectedOuterBoxIndex !== oIndex) {
                    return;
                }

                if (iBox.innerHTML !== '') {
                    return;
                }

                if (outerBox[oIndex].style.backgroundColor === selectedColor) {
                    outerBox[oIndex].style.backgroundColor = defaultColor;
                    outerBox[oIndex].style.transform = 'scale(1)';
                }
                if (turn_o) {
                    iBox.innerHTML = '⭘';
                    turn_o = false;
                } else {
                    iBox.innerHTML = '✘';
                    turn_o = true;
                }

                outerBox.forEach(box => box.style.backgroundColor = defaultColor);

                if (!oBoxFilled(outerBox[iIndex])) {
                    outerBox[iIndex].style.backgroundColor = selectedColor;
                    outerBox[iIndex].style.transform = 'scale(1.05)';
                    selectedOuterBoxIndex = iIndex;
                } else {
                    selectedOuterBoxIndex = null;
                }

                updateFreeMove();
                innerBoxWinCheck(innerBox, oIndex);
                outerBoxWinCheck();
                drawCheck(innerBox, oIndex);
                saveGameState();
            });
        });
    });
}

document.addEventListener('DOMContentLoaded', () => {
    loadGameState();
    Game();
});
