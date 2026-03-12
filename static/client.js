const ws = new WebSocket("ws://" + location.host + "/ws")

ws.onmessage = (event) => {
  document.getElementById("view").innerHTML = event.data
}
