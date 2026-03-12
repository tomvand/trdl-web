import asyncio
from queue import Empty

from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from .queues import sim_to_net, net_to_sim


clients = set()


@asynccontextmanager
async def lifespan(app: FastAPI):
    asyncio.create_task(broadcast_loop())
    yield  # application runs here
    # optional shutdown cleanup


app = FastAPI(lifespan=lifespan)
app.mount("/static", StaticFiles(directory="static"), name="static")


async def broadcast_loop():

    while True:
        try:
            svg = sim_to_net.get_nowait()
        except Empty:
            await asyncio.sleep(0.01)
            continue

        for ws in list(clients):
            await ws.send_text(svg)


@app.get("/")
def index():
    return FileResponse("static/index.html")


@app.websocket("/ws")
async def websocket(ws: WebSocket):

    await ws.accept()
    clients.add(ws)

    try:
        while True:
            msg = await ws.receive_text()
            net_to_sim.put(msg)
    except:
        clients.discard(ws)
