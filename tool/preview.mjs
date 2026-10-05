import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
const root=path.resolve('build/web');
const types={'.html':'text/html','.js':'text/javascript','.json':'application/json','.wasm':'application/wasm','.png':'image/png','.ttf':'font/ttf','.otf':'font/otf'};
http.createServer((req,res)=>{
 const requested=path.resolve(root,'.'+decodeURIComponent(new URL(req.url,'http://localhost').pathname));
 if(requested!==root&&!requested.startsWith(root+path.sep)){res.writeHead(403);res.end();return;}
 const file=fs.existsSync(requested)&&fs.statSync(requested).isFile()?requested:path.join(root,'index.html');
 res.setHeader('Content-Type',types[path.extname(file)]||'application/octet-stream');fs.createReadStream(file).pipe(res);
}).listen(8787,'127.0.0.1',()=>console.log('VoltTech: http://127.0.0.1:8787'));
