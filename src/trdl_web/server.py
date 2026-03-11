import asyncio
from fastapi import FastAPI, WebSocket
from fastapi.responses import HTMLResponse

app = FastAPI()

# ---- simple SVG generator ----


def generate_svg(x):
    return f"""
<svg width="200" height="80" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="40" width="180" height="10" fill="black"/>
  <circle cx="{10 + x}" cy="45" r="6" fill="red"/>
</svg>
"""


# ---- webpage ----

HTML_PAGE = """
<!DOCTYPE html>
<html>
<body>

<h3>Railway prototype</h3>

<div id="view"></div>

<script>

const ws = new WebSocket("ws://" + location.host + "/ws")

ws.onmessage = (event) => {
    document.getElementById("view").innerHTML = event.data
}

</script>

</body>
</html>
"""


@app.get("/")
async def index():
    return HTMLResponse(HTML_PAGE)


# ---- websocket ----


@app.websocket("/ws")
async def websocket(ws: WebSocket):

    await ws.accept()

    x = 0

    while True:
        svg = generate_svg(x)

        await ws.send_text(svg)

        x += 2
        if x > 160:
            x = 0

        await asyncio.sleep(0.1)
