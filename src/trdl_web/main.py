import logging
import uvicorn
import time
import threading

from .simulation import Simulation
from .queues import sim_to_net, net_to_sim

log = logging.getLogger(__name__)


def simulation_loop():
    sim = Simulation(input_queue=net_to_sim, output_queue=sim_to_net)
    while True:
        sim.step()
        time.sleep(0.1)


threading.Thread(target=simulation_loop, daemon=True).start()


def main():
    logging.basicConfig(level=logging.DEBUG)
    log.debug("Hello world!")

    uvicorn.run("trdl_web.server:app", host="127.0.0.1", port=8080, reload=True)
