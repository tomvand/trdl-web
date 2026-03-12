from queue import Queue
import logging

log = logging.getLogger(__name__)


class Simulation:
    def __init__(self, input_queue: Queue, output_queue: Queue):
        self.input_queue = input_queue
        self.output_queue = output_queue

        self.x = 0

    def generate_svg(self):
        return f"""
<svg width="200" height="80" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="40" width="180" height="10" fill="black"/>
  <circle cx="{10 + self.x}" cy="45" r="6" fill="red"/>
</svg>
"""

    def step(self):
        # Process incoming commands
        while not self.input_queue.empty():
            msg = self.input_queue.get()
            log.debug(f"Simulation received: {msg}")

        # Update simulation
        self.x += 2
        if self.x > 160:
            self.x = 0

        # Publish state
        self.output_queue.put(self.generate_svg())
