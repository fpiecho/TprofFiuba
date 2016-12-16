var io = require('socket.io'),
    http = require('http'),
    server = http.createServer(),
    io = io.listen(server);

io.on('connection', function(socket) {
    console.log('User Connected');
    socket.on('message', function(msg){
        io.emit('message', msg);
    });
});

server.listen(4567, function(){
    console.log('Server started');
})