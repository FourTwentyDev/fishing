/**
 * FourTwenty Fish Market UI
 * Part of FourTwenty Fishing System
 * https://fourtwenty.dev | https://github.com/FourTwentyDev
 * 
 * Handles the fish market user interface including translations,
 * price updates, and selling functionality
 * Version: 1.0.0
 */

// State management
let translations = {};
let currentLocale = 'de';

/**
 * Fetches translations from the game client
 * Initializes the UI with the correct language
 */
async function fetchTranslations() {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/getTranslations`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
        
        const data = await response.json();
        translations = data.translations;
        currentLocale = data.locale;
        translateUI();
    } catch (error) {
        console.error('Failed to fetch translations:', error);
    }
}

/**
 * Updates all UI elements with their corresponding translations
 * Uses data-translate attributes to identify translatable elements
 */
function translateUI() {
    document.querySelectorAll('[data-translate]').forEach(element => {
        const key = element.getAttribute('data-translate');
        if (translations[key]) {
            element.textContent = translations[key];
        }
    });
}

/**
 * Formats a number as currency based on locale
 * @param {number} value - Amount to format
 * @returns {string} Formatted currency string
 */
function formatCurrency(value) {
    return new Intl.NumberFormat(currentLocale === 'de' ? 'de-DE' : 'en-US', {
        style: 'currency',
        currency: 'EUR',
        minimumFractionDigits: 0
    }).format(value);
}

/**
 * Formats milliseconds into MM:SS format
 * @param {number} ms - Time in milliseconds
 * @returns {string} Formatted time string
 */
function formatTime(ms) {
    const minutes = Math.floor(ms / 60000);
    const seconds = Math.floor((ms % 60000) / 1000);
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
}

/**
 * Updates the market UI with current inventory and prices
 * @param {Object} data - Market data including inventory and prices
 */
function updateUI(data) {
    const fishList = document.getElementById('fishList');
    const totalValue = document.getElementById('totalValue');
    let total = 0;

    // Clear existing list
    fishList.innerHTML = '';

    // Create elements for each fish type
    data.inventory.forEach(fish => {
        if (fish.count > 0) {
            const itemTotal = fish.currentPrice * fish.count;
            total += itemTotal;

            const fishElement = document.createElement('div');
            fishElement.className = 'fish-item';
            fishElement.innerHTML = `
                <div class="fish-info">
                    <h3>${fish.name}</h3>
                    <p>${translations.ui_quantity || 'Amount'}: ${fish.count}x</p>
                </div>
                <div class="price-info">
                    <div class="price-current">
                        ${formatCurrency(fish.currentPrice)}
                        ${getTrendIcon(fish.trend)}
                    </div>
                    <div class="price-total">
                        ${translations.ui_total || 'Total'}: ${formatCurrency(itemTotal)}
                    </div>
                </div>
            `;
            fishList.appendChild(fishElement);
        }
    });

    // Update totals and timer
    totalValue.textContent = formatCurrency(total);
    
    if (data.nextUpdate) {
        const timer = document.getElementById('timer');
        timer.textContent = formatTime(data.nextUpdate);
    }

    // Enable/disable sell button based on inventory
    document.getElementById('sellButton').disabled = total <= 0;
}

/**
 * Gets the appropriate trend icon
 * @param {string} trend - Price trend ('up', 'down', or other)
 * @returns {string} HTML for trend icon
 */
function getTrendIcon(trend) {
    if (trend === 'up') return '<span class="trend-up">↑</span>';
    if (trend === 'down') return '<span class="trend-down">↓</span>';
    return '';
}

/**
 * Sends a message to the game client
 * @param {string} endpoint - API endpoint
 * @param {Object} data - Data to send
 */
async function sendMessage(endpoint, data = {}) {
    try {
        await fetch(`https://${GetParentResourceName()}/${endpoint}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });
    } catch (error) {
        console.error(`Failed to send message to ${endpoint}:`, error);
    }
}

// Event Listeners
document.getElementById('closeButton').addEventListener('click', () => {
    sendMessage('closeUI');
});

document.getElementById('sellButton').addEventListener('click', () => {
    sendMessage('sellFish', { sellAll: true });
});

// Message handler for game events
window.addEventListener('message', (event) => {
    const { type, ...data } = event.data;

    switch (type) {
        case 'updateFishMarketUI':
            document.body.style.display = 'block';
            updateUI(data);
            break;
        case 'hideUI':
            document.body.style.display = 'none';
            break;
        case 'setTranslations':
            translations = data.translations;
            currentLocale = data.locale;
            translateUI();
            break;
    }
});

// Close UI on escape key
document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        sendMessage('closeUI');
    }
});

// Initialize the UI
fetchTranslations();