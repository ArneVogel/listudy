function createButton(text, btnClass, fn) {
    let button = document.createElement('button');
    button.innerText = text;
    button.className = btnClass;
    button.onclick = fn;
    return button;
}

function storeResponse(response) {
    localStorage.setItem('cookieConsent', response);
    localStorage.setItem('cookieConsentDate', new Date().toUTCString());
}

function askForConsent() {
    let cookieConsent = document.createElement('div');
    cookieConsent.id = 'cookieConsent';
    let question = document.createElement('b');
    let info = document.createElement('span');
    let br = document.createElement('br');
    
    infoAll = document.createElement('span');
    headerAll = document.createElement('b');
    headerAll.innerText = "All ads: ";
    
    infoAll.innerText = "Third party vendors, including Google, use cookies to serve ads based on your prior visits to our website or other websites, including interests, demographics, and location.";
    
    headerNP = document.createElement('b');
    headerNP.innerText = "Non-personalized ads: ";
    infoNonPersonalized = document.createElement('span');
    infoNonPersonalized.innerText = "Non-personalized ads are targeted using contextual information rather than the past behavior, but still use cookie for frequency capping, aggregated ad reporting, and to combat fraud and abuse.";
    question.innerText = "Please help support this site by enabling ads";
    
    let allAds = createButton('Allow all Ads', 'primary', () => {
        storeResponse('all');
        document.getElementById('cookieConsent').remove();
        updateSupport();
    });
    let nonPersonalizedAds = createButton('Allow non-personalized ads', 'secondary', () => {
        storeResponse('non-personalized');
        document.getElementById('cookieConsent').remove();
        updateSupport();
    });
    let disableAds = createButton('Disable Ads', 'tertiary', () => {
        storeResponse('disable');
        document.getElementById('cookieConsent').remove();
        updateSupport();
    });
    
    
    cookieConsent.appendChild(question);
    cookieConsent.appendChild(document.createElement('br'));
    cookieConsent.appendChild(headerAll);
    cookieConsent.appendChild(infoAll);
    cookieConsent.appendChild(document.createElement('br'));
    
    cookieConsent.appendChild(headerNP);
    cookieConsent.appendChild(infoNonPersonalized);
    
    cookieConsent.appendChild(document.createElement('br'));
    cookieConsent.appendChild(disableAds);
    cookieConsent.appendChild(nonPersonalizedAds);
    cookieConsent.appendChild(allAds);
    document.body.appendChild(cookieConsent);
}

if (localStorage.getItem('cookieConsent') === null) {
    askForConsent();
} else {
    updateSupport();
}

function updateSupport() {
    if (localStorage.getItem('cookieConsent') === 'disable') {
        console.log('Ads disabled');
    }
    if (localStorage.getItem('cookieConsent') === 'all') {
        (adsbygoogle=window.adsbygoogle||[]).requestNonPersonalizedAds=0;
    }
    if (localStorage.getItem('cookieConsent') === 'non-personalized') {
        (adsbygoogle=window.adsbygoogle||[]).requestNonPersonalizedAds=1;
    }
}
