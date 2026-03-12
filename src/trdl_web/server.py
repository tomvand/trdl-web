import asyncio
import threading
import time

from fastapi import FastAPI, WebSocket
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from .simulation import Simulation


app = FastAPI()

# static assets (js, css)
app.mount("/static", StaticFiles(directory="static"), name="static")

clients = set()
sim = Simulation()


def simulation_loop():

    while True:
        svg = sim.generate_svg()

        for ws in list(clients):
            try:
                asyncio.run(ws.send_text(svg))
            except:
                clients.discard(ws)

        sim.step()

        time.sleep(0.1)


threading.Thread(target=simulation_loop, daemon=True).start()


@app.get("/")
def index():
    return FileResponse("static/index.html")


@app.websocket("/ws")
async def websocket(ws: WebSocket):

    await ws.accept()
    clients.add(ws)

    try:
        while True:
            await ws.receive_text()
    except:
        clients.discard(ws)
