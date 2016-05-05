var fetch = require('isomorphic-fetch');

module.exports = function(gds) {
    gds.on('saved', function(fileName) {
        fetch('https://files.holderdeord.no/gdrive/' + fileName + '.json', {
            method: 'PURGE'
        }).then(console.log('purge', fileName, res.status, res.statusText));
    });

    gds.on('synced', function(state) {
        console.log(state.lastCheck);
    });
}