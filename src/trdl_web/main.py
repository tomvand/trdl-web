import uvicorn


def main():
    uvicorn.run("trdl_web.server:app", host="127.0.0.1", port=8080, reload=True)
