$(document).ready(function () {
    const mainContainer = $('.lootbox-container');
    const textContainer = $('#result-text-container');
    const reel = $('.reel');
    const resultLabel = $('#result-label');
    const itemWidthWithMargin = 170;

    const rollSound = new Audio('sounds/lootcase.ogg');
    const winSound = new Audio('sounds/win.ogg');
    rollSound.volume = 0.4;
    winSound.volume = 0.6;

    let isRolling = false;

    function post(event, data) {
        $.post(`https://henny_lootcase/${event}`, JSON.stringify(data || {}));
    }

    function createItemElement(item) {
        const itemEl = $(`<div class="item ${item.rarity || 'common'}"></div>`);
        const imageUrl = `nui://ox_inventory/web/images/${item.name}.png`;
        const imageEl = $(`<div class="item-image"></div>`).css('background-image', `url(${imageUrl})`);
        const labelEl = $(`<div class="item-label">${item.label}</div>`);
        itemEl.append(imageEl).append(labelEl);
        return itemEl;
    }

    function startRoll(winner, reelItems) {
        isRolling = true; 

        mainContainer.removeClass('uncommon-win rare-win epic-win legendary-win');
        reel.empty().removeClass('has-winner');
        $('.item.winner').removeClass('winner');
        textContainer.removeClass('visible');
        reel.css('transition', 'none').css('transform', 'translateX(0)');

        let roll = [];
        for (let i = 0; i < 100; i++) {
            roll.push(reelItems[Math.floor(Math.random() * reelItems.length)]);
        }
        const winnerIndex = 95;
        roll[winnerIndex] = winner;
        roll.forEach(item => reel.append(createItemElement(item)));

        const reelContainerWidth = mainContainer.width();
        const winnerCenter = (winnerIndex * itemWidthWithMargin) + (itemWidthWithMargin / 2);
        const finalPosition = winnerCenter - (reelContainerWidth / 2);

        void reel.width();
        rollSound.play().catch(e => {});

        reel.css('transition', 'transform 5s cubic-bezier(0.15, 0.5, 0.2, 1)');
        reel.css('transform', `translateX(-${finalPosition}px)`);

        setTimeout(() => {
            if(winner.rarity) {
                mainContainer.addClass(`${winner.rarity}-win`);
            }

            reel.addClass('has-winner');
            reel.children().eq(winnerIndex).addClass('winner');
            
            resultLabel.text(winner.label);
            resultLabel.removeClass().addClass(winner.rarity);
            textContainer.addClass('visible');

            post('animationFinished', { winner: winner });
            isRolling = false; 

        }, 5350);
    }

    window.addEventListener('message', function (event) {
        const data = event.data;
        switch (data.action) {
            case 'open':
                mainContainer.fadeIn(300);
                const playPromise = rollSound.play();
                if (playPromise !== undefined) {
                    playPromise.then(_ => {
                        rollSound.pause();
                        rollSound.currentTime = 0;
                    }).catch(error => {});
                }
                break;
            case 'result':
                textContainer.show();
                startRoll(data.winner, data.reel);
                break;
        }
    });

    document.onkeyup = function (data) {
        if (data.key === 'Escape' && !isRolling) {
            mainContainer.fadeOut(300);
            textContainer.fadeOut(300);
            post('close');
        }
    };
});