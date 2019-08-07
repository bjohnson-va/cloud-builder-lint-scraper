function check() {
    const found = document.body.innerText.indexOf('Lint warnings found in the listed files.') + 1;
    if (found) {
        alert('All green');
    } else {
        alert('Not green!');
    }
}

window.preAdded = false;
window.lintParsed = false;

var observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
        if (lintParsed) {
            observer.disconnect();
            return;
        }
        mutation.addedNodes.forEach(node => {
            if (window.preAdded) {
                const logMaybe = document.getElementsByClassName('p6n-gcb-log');
                if (logMaybe.length > 0) {
                    if (logMaybe[0].innerText.indexOf('Lint warnings found in the listed files') + 1) {
                        window.lintParsed = true;
                        console.log('Warnings found');
                    } else {
                        debugger;
                    }
                }
            }
            if (node.nodeName === 'SECTION') {
                const logViewer = Array.from(node.childNodes.values()).find(v => v.nodeName === 'GCB-LOG-VIEWER');
                if (logViewer) {
                    window.preAdded = true;
                }
            }
        });
        return true;
    });
});
observer.observe(document, { childList: true, subtree: true });


