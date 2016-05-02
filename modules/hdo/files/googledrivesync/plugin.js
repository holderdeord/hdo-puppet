
module.exports = function(gds) {
    gds.on('saved', function(fileName) {
      console.log(fileName);
        // TODO: purge URL
    });

    gds.on('synced', function(state) {
      console.log(state.lastCheck);
    });
}