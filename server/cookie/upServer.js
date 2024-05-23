const http = require('http');
const url = require('url');
const { exec } = require('child_process');

const executeCommand = (command, callback) => {
    exec(command, (error, stdout, stderr) => {
      console.log(`Executing command: ${command}`);
      console.log(`stdout: ${stdout}`);
      console.log(`stderr: ${stderr}`);
      if (error) {
        console.error(`exec error: ${error}`);
        callback(error.code);
      } else {
        callback(0);
      }
    });
  };

const server = http.createServer((req, res) => {
const parsedUrl = url.parse(req.url, true);
const parameterC = parsedUrl.query.c;

// Überprüfe, ob der Parameter c nur aus Buchstaben und Zahlen besteht
const isValid = /^[a-zA-Z0-9]+$/.test(parameterC);

if (!isValid) {
    // Wenn der Parameter ungültig ist, sende 403 Forbidden
    res.writeHead(403, { 'Content-Type': 'text/html' });
    res.end('<h1>403 Forbidden</h1><p>Invalid parameter value.</p>');
    return;
}


const repoUrl = `gitlab:ux-cookie-banner/uex-cookie-banner-website/${parameterC}?host=git.mylab.th-luebeck.de`;
const updateCommand = `cd /home/leonard/.config/nix-config && nix flake update --override-input uex ${repoUrl}`;
const rebuildCommand = 'nixos-rebuild switch --flake /home/leonard/.config/nix-config --impure';

executeCommand(`${updateCommand}`, (updateExitCode) => {
    if (updateExitCode === 0) {
    // Wenn der Update-Befehl erfolgreich war, führe den Rebuild-Befehl aus
    executeCommand(`${rebuildCommand}`, (rebuildExitCode) => {
        if (rebuildExitCode === 0) {
        // Wenn der Rebuild-Befehl erfolgreich war, sende 200 OK
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end('<h1>200 OK</h1><p>Update and rebuild successful.</p>');
        } else {
        // Wenn der Rebuild-Befehl fehlgeschlagen ist, sende 500 Internal Server Error
        res.writeHead(500, { 'Content-Type': 'text/html' });
        res.end('<h1>500 Internal Server Error</h1><p>Rebuild failed.</p>');
        }
    });
    } else {
    // Wenn der Update-Befehl fehlgeschlagen ist, sende 500 Internal Server Error
    res.writeHead(500, { 'Content-Type': 'text/html' });
    res.end('<h1>500 Internal Server Error</h1><p>Update failed.</p>');
    }
});
});

const PORT = 42971;
server.listen(PORT, () => {
console.log(`Server is listening on port ${PORT}`);
});